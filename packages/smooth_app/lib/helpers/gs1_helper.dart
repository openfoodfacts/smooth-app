import 'package:gs1_barcode_parser_plus/gs1_barcode_parser.dart';

/// GS1 Application Identifier of the Global Trade Item Number (GTIN).
const String GS1_AI_GTIN = '01';

/// Tries to parse [input] as a GS1 barcode, returning null when it isn't one.
///
/// The underlying parser handles raw GS1 element strings (with optional FNC1
/// prefixes such as `]C1` or `]d2`), GS separators (`\x1D`) and GS1 Digital
/// Links. It doesn't handle the bracketed human-readable format
/// `(01)04044782317112(17)270101` nor a leading caret (`^`) character, so we
/// normalize them before parsing.
///
/// Parsing must never break the scanning flow: any failure (invalid input,
/// unknown AI, ...) simply returns null.
GS1Barcode? tryParseGs1Barcode(final String input) {
  String normalized = input.trim();
  if (normalized.isEmpty) {
    return null;
  }

  // The bracketed AI format is the "human readable" representation: removing
  // the parentheses turns it back into a raw GS1 element string. We don't do
  // it for URLs, where parentheses are likely part of a query.
  if (!normalized.startsWith('http://') && !normalized.startsWith('https://')) {
    normalized = normalized.replaceAll('(', '').replaceAll(')', '');
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

  try {
    return GS1BarcodeParser.defaultParser().parse(normalized);
  } on GS1Exception catch (_) {
    // The parser only throws GS1Exception subclasses (GS1ParseException,
    // GS1DataException) for invalid data. We return null for any failure.
    return null;
  } on RangeError catch (_) {
    // The parser does not guard short inputs when identifying AIs
    // (unconditional substring(0, 3) and substring(0, 4)): 2-3 character
    // inputs that are not barcodes throw a RangeError instead.
    return null;
  }
}

/// The result of normalizing a scanned barcode into a local key and an API
/// barcode.
class NormalizedBarcode {
  const NormalizedBarcode({
    required this.key,
    required this.apiBarcode,
    this.gs1Barcode,
  });

  /// Barcode used as the local key: session deduplication, scan lists and
  /// local database lookups.
  ///
  /// For GS1 barcodes it's the normalized GTIN (AI 01), so that barcodes
  /// encoding the same product with different Application Identifiers are
  /// deduplicated. For "traditional" barcodes it's the fixed barcode.
  final String key;

  /// Barcode sent to the API.
  ///
  /// For GS1 barcodes we deliberately send the full raw string, so that the
  /// server can process the additional Application Identifiers. For
  /// "traditional" barcodes it's the same as [key].
  final String apiBarcode;

  /// The parsed GS1 barcode, when the scanned value was a GS1 barcode.
  final GS1Barcode? gs1Barcode;
}

/// Normalizes a scanned [code] into a [NormalizedBarcode].
NormalizedBarcode normalizeScannedBarcode(final String code) {
  final GS1Barcode? gs1Barcode = tryParseGs1Barcode(code);
  if (gs1Barcode != null) {
    final String? gtin = gs1Barcode.normalizedGtin;
    if (gtin != null) {
      return NormalizedBarcode(
        key: gtin,
        apiBarcode: code,
        gs1Barcode: gs1Barcode,
      );
    }
    // A GS1 barcode without a GTIN (e.g. a logistics label): keep the raw
    // value untouched.
    return NormalizedBarcode(
      key: code,
      apiBarcode: code,
      gs1Barcode: gs1Barcode,
    );
  }
  final String key = fixTraditionalBarcode(code);
  return NormalizedBarcode(key: key, apiBarcode: key);
}

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
  /// for example `0104260392550101` becomes `4260392550101`.
  String? get normalizedGtin {
    final String? value = gtin;
    if (value == null) {
      return null;
    }
    if (value.length == 14 && value.startsWith('0')) {
      return value.substring(1);
    }
    return value;
  }
}
