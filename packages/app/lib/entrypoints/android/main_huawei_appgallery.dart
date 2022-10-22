import 'package:scanner_mlkit/scanner_mlkit.dart';
import 'package:smooth_app/main.dart';

/// Huawei App Gallery version with:
/// - Barcode decoding algorithm: ZXing
/// - Intent to launch the review
void main() {
  launchSmoothApp(
    // TODO(g123k): Replace this when ZXing is ready
    scanner: MLKitCameraScanner(),
  );
}
