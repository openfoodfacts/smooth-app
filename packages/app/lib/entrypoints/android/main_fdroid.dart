import 'package:app_store_uri/app_store_uri.dart';
import 'package:scanner_zxing/scanner_zxing.dart';
import 'package:smooth_app/main.dart';

/// Fdroid version with:
/// - Barcode decoding algorithm: ZXing
/// - Intent to launch the review
void main() {
  launchSmoothApp(
    scanner: ZXingCameraScanner(),
    appStore: URIAppStore(
      Uri.parse(
        'https://f-droid.org/fr/packages/openfoodfacts.github.scrachx.openfood/',
      ),
    ),
    appFlavour: 'zxing-uri',
  );
}
