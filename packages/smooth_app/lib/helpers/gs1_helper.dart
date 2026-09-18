import 'package:gs1_barcode_parser_plus/gs1_barcode_parser.dart';

/// GS1 Application Identifier of the Global Trade Item Number (GTIN).
const String GS1_AI_GTIN = '01';

/// GS1 Application Identifier of the batch/lot number.
const String GS1_AI_BATCH_LOT = '10';

/// GS1 Application Identifier of the production date.
const String GS1_AI_PRODUCTION_DATE = '11';

/// GS1 Application Identifier of the best-before date.
const String GS1_AI_BEST_BEFORE = '15';

/// GS1 Application Identifier of the expiry date.
const String GS1_AI_EXPIRY = '17';

/// GS1 Application Identifier of the serial number.
const String GS1_AI_SERIAL = '21';

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

  if (normalized.isEmpty) {
    return null;
  }

  try {
    return GS1BarcodeParser.defaultParser().parse(normalized);
  } on GS1Exception catch (_) {
    // The parser only throws GS1Exception subclasses (GS1ParseException,
    // GS1DataException). We return null for any parsing failure.
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

/// Convenient accessors to the GS1 Application Identifiers most relevant to
/// the app.
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

  /// The batch/lot number (AI 10), or null if not present.
  String? get batchLot => getAIRawData(GS1_AI_BATCH_LOT);

  /// The serial number (AI 21), or null if not present.
  String? get serial => getAIRawData(GS1_AI_SERIAL);

  /// The production date (AI 11), or null if not present.
  DateTime? get productionDate => _data(GS1_AI_PRODUCTION_DATE);

  /// The best-before date (AI 15), or null if not present.
  DateTime? get bestBefore => _data(GS1_AI_BEST_BEFORE);

  /// The expiry date (AI 17), or null if not present.
  DateTime? get expiry => _data(GS1_AI_EXPIRY);

  /// The net weight in kilograms (AI 3100-3105), or null if not present.
  double? get netWeightKg {
    for (int decimals = 0; decimals <= 5; decimals++) {
      final dynamic value = getAIData('310$decimals');
      if (value is double) {
        return value;
      }
    }
    return null;
  }

  DateTime? _data(final String ai) {
    final dynamic value = getAIData(ai);
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}

/// Extensions to detect and access GS1 barcodes from a raw string.
extension GS1StringHelper on String {
  /// The parsed GS1 barcode, or null if this string is not a GS1 barcode.
  GS1Barcode? get gs1Barcode => tryParseGs1Barcode(this);

  /// Whether this string is a parseable GS1 barcode.
  bool get isGs1Barcode => gs1Barcode != null;
}
