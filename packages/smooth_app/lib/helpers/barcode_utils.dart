/// Checks if a URL contains GS1 Application Identifiers
bool _containsGs1AIs(String url) {
  final Uri? uri = Uri.tryParse(url);
  if (uri == null) {
    return false;
  }

  final RegExp aiPattern = RegExp(r'^\d{2,4}$');

  // Check path segments for AI patterns (2-4 digits followed by value)
  final List<String> segments = uri.pathSegments;
  for (int i = 0; i < segments.length - 1; i++) {
    if (aiPattern.hasMatch(segments[i]) && segments[i + 1].isNotEmpty) {
      return true;
    }
  }

  // Check query parameters for AI patterns
  for (final String key in uri.queryParameters.keys) {
    if (aiPattern.hasMatch(key)) {
      return true;
    }
  }

  return false;
}

/// Extension on String to check if it represents a barcode
///
/// GS1 support can be replaced with `gs1_barcode_parser`
/// if https://github.com/mobui/gs1_barcode_parser/pull/14 is merged.
extension BarcodeExtension on String {
  /// Checks if this string represents a barcode.
  ///
  /// Supports:
  /// - Traditional numeric barcodes (digits only, length >= 8)
  /// - GS1 barcodes with FNC1 character (\x1D or \x241D)
  /// - GS1 bracketed AI format like (01)04044782317112(17)270101
  /// - GS1 Digital Links (https:// URLs containing GS1 AIs like /01/)
  bool get isBarcode {
    final String query = trim();
    if (query.isEmpty) {
      return false;
    }

    // GS1 Digital Link (URLs with GS1 AIs)
    if ((query.startsWith('http://') || query.startsWith('https://')) &&
        _containsGs1AIs(query)) {
      return true;
    }

    // GS1 barcode with FNC1
    if (query.contains('\x1D') || query.contains('\u241D')) {
      return true;
    }

    // GS1 bracketed AI format like (01)04044782317112(17)270101
    // Require at least one character as the AI value to avoid empty values like (01)(17)...
    if (RegExp(r'^(\(\d{2,4}\)[^()]+)+$').hasMatch(query)) {
      return true;
    }

    // Traditional numeric barcode
    if (RegExp(r'^\d{8,}$').hasMatch(query)) {
      return true;
    }

    return false;
  }
}
