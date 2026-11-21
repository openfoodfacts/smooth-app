import 'package:app_store_uri/app_store_uri.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:smooth_app/helpers/entry_points_helper.dart';
import 'package:smooth_app/main.dart';

/// Fast development entrypoint with:
/// - Mocked barcode scanner (no camera hardware / ML Kit / ZXing native overhead)
/// - URI app store (no Google Play / App Store SDK overhead)
/// - Fast startup and compatible with Desktop (macOS, Linux, Windows), Android, and iOS
///
/// Run on desktop (instant startup, no emulator required):
///   fvm flutter run -t lib/entrypoints/dev/main_dev.dart -d macos
///   fvm flutter run -t lib/entrypoints/dev/main_dev.dart -d linux
///   fvm flutter run -t lib/entrypoints/dev/main_dev.dart -d windows
///
/// Or run on a mobile device / emulator:
///   fvm flutter run -t lib/entrypoints/dev/main_dev.dart
void main() {
  launchSmoothApp(
    barcodeScanner: const MockedScanner(),
    appStore: URIAppStore(Uri.parse('https://openfoodfacts.org')),
    scannerLabel: ScannerLabel.Test,
    storeLabel: StoreLabel.Test,
  );
}
