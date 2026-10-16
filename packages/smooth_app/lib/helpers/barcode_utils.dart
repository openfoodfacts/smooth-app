import 'package:smooth_app/helpers/gs1_helper.dart';

final RegExp _numericBarcodeRegExp = RegExp(r'^\d{8,}$');

/// Extension on String to check if it represents a barcode.
extension BarcodeExtension on String {
  /// Checks if this string represents a barcode.
  ///
  /// Supports:
  /// - Traditional numeric barcodes (digits only, length >= 8)
  /// - GS1 barcodes (element strings, bracketed AI format like
  ///   (01)04044782317112(17)270101 and GS1 Digital Links), as parsed by
  ///   [tryParseGs1Barcode].
  bool get isBarcode {
    final String query = trim();
    if (query.isEmpty) {
      return false;
    }

    // Traditional numeric barcode
    if (_numericBarcodeRegExp.hasMatch(query)) {
      return true;
    }

    // GS1 barcode
    return tryParseGs1Barcode(query) != null;
  }
}
