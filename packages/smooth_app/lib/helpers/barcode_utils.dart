import 'package:smooth_app/helpers/gs1_helper.dart';

final RegExp _numericBarcodeRegExp = RegExp(r'^\d{8,}$');

/// Extension on String to check if it represents a barcode.
extension BarcodeExtension on String {
  /// Checks if this string represents a barcode.
  ///
  /// Supports:
  /// - Traditional numeric barcodes (digits only, length >= 8)
  /// - GS1 barcodes carrying a GTIN (AI 01): element strings, bracketed AI
  ///   format like (01)04044782317112(17)270101 and GS1 Digital Links, as
  ///   parsed by [tryParseGs1Barcode].
  ///
  /// GS1 barcodes without a GTIN (e.g. a bare `(10)ABC123` lot) are not
  /// treated as barcodes here: short search words like `100g` would
  /// otherwise parse as AI 10/21 and hijack text search into a barcode
  /// lookup.
  bool get isBarcode {
    final String query = trim();
    if (query.isEmpty) {
      return false;
    }

    // Traditional numeric barcode
    if (_numericBarcodeRegExp.hasMatch(query)) {
      return true;
    }

    // GS1 barcode carrying a GTIN
    return tryParseGs1Barcode(query)?.gtin != null;
  }
}
