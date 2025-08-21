import 'package:app_store_uri/app_store_uri.dart';
import 'package:scanner_web/scanner_web.dart';
import 'package:smooth_app/helpers/entry_points_helper.dart';
import 'package:smooth_app/main.dart';

/// Web version with:
/// - Barcode decoding algorithm: Web-compatible scanner with manual input
/// - URI-based app store (GitHub Pages)
void main() {
  launchSmoothApp(
    barcodeScanner: const ScannerWeb(),
    appStore: URIAppStore(
      Uri.parse(
        'https://openfoodfacts.github.io/smooth-app/',
      ),
    ),
    scannerLabel: ScannerLabel.Other,
    storeLabel: StoreLabel.Other,
  );
}