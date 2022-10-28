import 'package:scanner_mlkit/scanner_mlkit.dart';
import 'package:smooth_app/main.dart';

/// Samsung Gallery version with:
/// - Barcode decoding algorithm: MLKit
/// - Intent to launch the review
void main() {
  launchSmoothApp(
    scanner: MLKitCameraScanner(),
  );
}
