import 'package:zxing_js/library.dart';

class WebScannerHelper {
  late ZXingScanner _scanner;

  Future<void> initialize() async {
    _scanner = ZXingScanner();
    await _scanner.initialize();
  }

  Future<String?> scanBarcode() async {
    final result = await _scanner.scan();
    return result?.text;
  }
}
