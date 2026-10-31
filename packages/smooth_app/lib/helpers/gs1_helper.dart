import 'package:gs1_barcode_parser_plus/gs1_barcode_parser.dart';

/// GS1 Application Identifier of the Global Trade Item Number (GTIN).
const String GS1_AI_GTIN = '01';

/// One `(AI)value` group of bracketed human-readable GS1 input, e.g.
/// `(17)270101`, capturing the AI and its value.
final RegExp _gs1BracketedGroupRegExp = RegExp(
  r'\((\d{2,4})\)((?!\(\d{2,4}\)|$).+?)(?=\(\d{2,4}\)|$)',
);

/// Converts well-formed bracketed human-readable GS1 input (e.g.
/// `(01)04044782317112(17)270101`) into a raw element string, returning null
/// when [input] is not fully covered by `(AI)value` groups.
///
/// Group boundaries reinsert the GS separator (`\x1D`) where a non-final
/// variable-length AI requires one; without it the parser would swallow the
/// following AIs into the variable-length value.
String? _bracketedHriToElementString(final String input) {
  final List<RegExpMatch> matches = _gs1BracketedGroupRegExp
      .allMatches(input)
      .toList();
  final StringBuffer buffer = StringBuffer();
  int position = 0;
  for (int i = 0; i < matches.length; i++) {
    final RegExpMatch match = matches[i];
    if (match.start != position) {
      return null;
    }
    position = match.end;
    final String? ai = match.group(1);
    final String? value = match.group(2);
    if (ai == null || value == null) {
      return null;
    }
    buffer.write(ai);
    buffer.write(value);
    if (i < matches.length - 1 && _isVariableLengthAi(ai)) {
      buffer.write('\x1D');
    }
  }
  if (matches.isEmpty || position != input.length) {
    return null;
  }
  return buffer.toString();
}

/// Whether the GS1 Application Identifier [ai] has a variable-length value,
/// requiring a GS separator before the next element (except in final
/// position). Unknown AIs are treated as fixed-length: the subsequent parse
/// rejects them anyway.
bool _isVariableLengthAi(final String ai) {
  final AIFormatType? type = AI.AIS[ai]?.type;
  return type == AIFormatType.VARIABLE_LENGTH ||
      type == AIFormatType.VARIABLE_LENGTH_WITH_ISO_NUMBERS ||
      type == AIFormatType.VARIABLE_LENGTH_WITH_ISO_CHARS ||
      type == AIFormatType.VARIABLE_LENGTH_MEASURE;
}

/// Cleans [input] for GS1 parsing, returning null for empty input.
///
/// This trims whitespace, converts well-formed bracketed human-readable input
/// into a raw element string (except for URLs, where parentheses are likely
/// part of a query) and normalizes FNC1 markers (leading carets, U+241D) to
/// the GS separator. Anything else, including raw element strings with
/// parentheses in AI values, is left unchanged.
String? _cleanGs1Input(final String input) {
  String normalized = input.trim();
  if (normalized.isEmpty) {
    return null;
  }

  final String lower = normalized.toLowerCase();
  if (!lower.startsWith('http://') && !lower.startsWith('https://')) {
    if (normalized.contains('(') || normalized.contains(')')) {
      final String? elementString = _bracketedHriToElementString(normalized);
      if (elementString != null) {
        normalized = elementString;
      }
    }
  }

  // Some scanners output a leading caret as the FNC1 character.
  while (normalized.startsWith('^')) {
    normalized = normalized.substring(1);
  }

  // Some scanners output U+241D ("symbol for FNC1") instead of the GS
  // separator: normalize it before parsing.
  normalized = normalized.replaceAll('\u241D', '\x1D');

  if (normalized.isEmpty) {
    return null;
  }
  return normalized;
}

/// Cached default GS1 parser: construction allocates element-parser maps,
/// so reuse a single instance instead of rebuilding it per barcode scanned
/// or per search keystroke.
final GS1BarcodeParser _gs1Parser = GS1BarcodeParser.defaultParser();

/// Tries to parse [input] as a GS1 barcode, returning null when it isn't one.
///
/// The underlying parser handles raw GS1 element strings (with optional FNC1
/// prefixes such as `]C1` or `]d2`), GS separators (`\x1D`) and GS1 Digital
/// Links. The input is cleaned before parsing, so well-formed bracketed
/// human-readable input and FNC1 markers are accepted as well.
///
/// Parsing must never break the scanning flow: any failure (invalid input,
/// unknown AI, ...) simply returns null.
GS1Barcode? tryParseGs1Barcode(final String input) =>
    _tryParseGs1WithCleanedInput(input)?.barcode;

/// Digits-only EAN-13 / EAN-8 guards.
///
/// `int.tryParse` accepts hex (`0x`), `+` and whitespace, and `int.parse`
/// on single characters below would then throw out of
/// [normalizeScannedBarcode]. A strict regex keeps validation total.
final RegExp _ean13RegExp = RegExp(r'^\d{13}$');
final RegExp _ean8RegExp = RegExp(r'^\d{8}$');

/// Normalizes a scanned barcode into a local key.
///
/// For GS1 barcodes it's the normalized GTIN (AI 01), so that barcodes
/// encoding the same product with different Application Identifiers are
/// deduplicated. For "traditional" barcodes it's the fixed barcode.
/// A GS1 barcode without a GTIN (e.g. a logistics label) falls back to the
/// cleaned value, so that different formatting of the same label still
/// deduplicates.
String normalizeScannedBarcode(final String code) {
  final String traditionalBarcode = fixTraditionalBarcode(code);
  if (_traditionalLengthRegExp.hasMatch(traditionalBarcode) &&
      _isValidEan13(traditionalBarcode.padLeft(13, '0'))) {
    return traditionalBarcode;
  }
  final _Gs1ParseResult? parsed = _tryParseGs1WithCleanedInput(code);
  if (parsed != null) {
    final String? gtin = parsed.barcode.normalizedGtin;
    if (gtin != null) {
      return gtin;
    }
    return parsed.cleanedInput;
  }
  return traditionalBarcode;
}

/// Result of parsing a GS1 barcode along with its cleaned input.
class _Gs1ParseResult {
  const _Gs1ParseResult({required this.barcode, required this.cleanedInput});

  final GS1Barcode barcode;
  final String cleanedInput;
}

/// Tries to parse [input] as a GS1 barcode, returning both the parsed barcode
/// and the cleaned input used for parsing. Returns null when [input] isn't a
/// GS1 barcode.
_Gs1ParseResult? _tryParseGs1WithCleanedInput(final String input) {
  final String? normalized = _cleanGs1Input(input);
  if (normalized == null) {
    return null;
  }

  try {
    final GS1Barcode barcode = _gs1Parser.parse(normalized);
    return _Gs1ParseResult(barcode: barcode, cleanedInput: normalized);
  } on GS1Exception catch (_) {
    // The parser throws GS1Exception subclasses (GS1ParseException,
    // GS1DataException) for invalid data.
    return null;
  } on RangeError catch (_) {
    // The parser does not guard short inputs when identifying AIs
    // (unconditional substring(0, 3) and substring(0, 4)): 2-3 character
    // inputs that are not barcodes throw a RangeError instead.
    return null;
  } catch (_) {
    // Safety net: parsing must never break the scanning flow, whatever a
    // (future) parser version throws.
    return null;
  }
}

/// Tries to parse [input] as a GS1 barcode, returning null when it isn't one.
/// numeric input, a UPC-A, EAN-8 or EAN-13 with a valid check digit takes
/// precedence over GS1 parsing. Explicit GS1 formatting (e.g. `(21)`, `]C1`
/// or FNC1) bypasses this rule. Length alone never selects a traditional code.
final RegExp _traditionalLengthRegExp = RegExp(
  r'^(?:[0-9]{8}|[0-9]{12}|[0-9]{13})$',
);

/// Fixes a "traditional" numeric barcode.
///
/// It trims the value and removes possible dashes, and pads UPC-A barcodes
/// (12 digits) to EAN-13 by adding a leading zero.
String fixTraditionalBarcode(final String code) {
  final String result = code.replaceAll('-', '').trim();
  if (result.length == 12) {
    return '0$result';
  }
  return result;
}

/// Convenient accessors to the GTIN (AI 01) of a parsed GS1 barcode.
extension GS1BarcodeHelper on GS1Barcode {
  /// The raw GTIN value (AI 01), or null if not present.
  String? get gtin => getAIRawData(GS1_AI_GTIN);

  /// The normalized barcode key derived from the GTIN (AI 01).
  ///
  /// The server normalizes GS1 barcodes: a GTIN-14 starting with `0` (i.e. an
  /// EAN-13/UPC-A wrapped in a GTIN-14) is returned without the leading zero,
  /// for example `0104260392550101` becomes `4260392550101`. Likewise a
  /// GTIN-14 starting with `000000` (i.e. an EAN-8 wrapped in a GTIN-14) is
  /// returned as the EAN-8, for example `00000021000003` becomes `21000003`.
  /// Leading zeros are only stripped when the remainder is a valid EAN-13
  /// resp. EAN-8, so that malformed values keep working as keys.
  String? get normalizedGtin {
    final String? value = gtin;
    if (value == null) {
      return null;
    }
    if (value.length == 14) {
      if (value.startsWith('000000') && _isValidEan8(value.substring(6))) {
        return value.substring(6);
      }
      if (value.startsWith('0') && _isValidEan13(value.substring(1))) {
        return value.substring(1);
      }
    }
    return value;
  }
}

/// Whether [code] is a valid EAN-13 (13 digits with a correct check digit).
bool _isValidEan13(final String code) {
  if (!_ean13RegExp.hasMatch(code)) {
    return false;
  }
  int sum = 0;
  for (int i = 0; i < 12; i++) {
    final int digit = int.parse(code[i]);
    sum += i.isEven ? digit : digit * 3;
  }
  return (10 - (sum % 10)) % 10 == int.parse(code[12]);
}

/// Whether [code] is a valid EAN-8 (8 digits with a correct check digit).
bool _isValidEan8(final String code) {
  if (!_ean8RegExp.hasMatch(code)) {
    return false;
  }
  int sum = 0;
  for (int i = 0; i < 7; i++) {
    final int digit = int.parse(code[i]);
    sum += i.isEven ? digit * 3 : digit;
  }
  return (10 - (sum % 10)) % 10 == int.parse(code[7]);
}
