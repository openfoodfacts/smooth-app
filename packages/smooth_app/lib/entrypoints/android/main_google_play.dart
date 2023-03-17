import 'package:app_store_google_play/app_store_google.dart';
import 'package:smooth_app/main.dart';
import 'package:smooth_app/pages/scan/smooth_barcode_scanner_type.dart';

/// Google Play version with:
/// - Barcode decoding algorithm: MLKit
/// - Google Play app review SDK
void main() {
  launchSmoothApp(
    scanner: SmoothBarcodeScannerType.awesome,
    appStore: GooglePlayStore(),
    appFlavour: 'ml-play',
  );
}
