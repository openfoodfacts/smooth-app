import 'package:app_store_apple_store/app_store_apple.dart';
import 'package:scanner_ml_kit/scanner_ml_kit.dart';
import 'package:smooth_app/helpers/entry_points_helper.dart';
import 'package:smooth_app/main.dart';

/// App Store/TestFlight version with:
/// - Barcode decoding algorithm: MLKit
/// - iOS/macOS SDK to open the store
///
/// This version is compatible both with iOS and macOS
void main() {
  launchSmoothApp(
    barcodeScanner: const ScannerMLKit(),
    appStore: AppleAppStore('588797948'),
    storeLabel: StoreLabel.AppleAppStore,
    scannerLabel: ScannerLabel.MLKit,
  );
}
