import 'package:scanner_zxing/scanner_zxing.dart';
import 'package:smooth_app/main.dart';

/// Amazon App Store version with:
/// - Barcode decoding algorithm: ZXing
/// - Intent to launch the review
void main() {
  launchSmoothApp(
    scanner: ZXingCameraScanner(),
  );
}
