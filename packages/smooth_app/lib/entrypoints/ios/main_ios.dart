import 'package:app_store_apple_store/app_store_apple.dart';
import 'package:smooth_app/main.dart';
import 'package:smooth_app/pages/scan/smooth_barcode_scanner_type.dart';

/// App Store/TestFlight version with:
/// - Barcode decoding algorithm: MLKit
/// - iOS SDK to open the store
void main() {
  launchSmoothApp(
    scanner: SmoothBarcodeScannerType.mlkit,
    appStore: AppleAppStore('588797948'),
    appFlavour: 'ml-ios',
  );
}
