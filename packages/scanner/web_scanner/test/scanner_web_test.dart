import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanner_web/scanner_web.dart';

void main() {
  group('ScannerWeb', () {
    test('should return correct type', () {
      const ScannerWeb scanner = ScannerWeb();
      expect(scanner.getType(), 'Web');
    });

    test('should create scanner widget', () {
      const ScannerWeb scanner = ScannerWeb();
      final Widget widget = scanner.getScanner(
        onScan: (String barcode) async => true,
        hapticFeedback: () async {},
        onCameraFlashError: null,
        trackCustomEvent:
            (
              String msg,
              String category, {
              int? eventValue,
              String? barcode,
            }) {},
        hasMoreThanOneCamera: false,
      );
      expect(widget, isNotNull);
    });
  });
}
