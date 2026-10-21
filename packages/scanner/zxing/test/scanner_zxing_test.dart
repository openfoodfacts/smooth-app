import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:scanner_zxing/scanner_zxing.dart';

Future<void> pumpScanner(
  WidgetTester tester, {
  required bool hasMoreThanOneCamera,
  Future<void> Function()? hapticFeedback,
}) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: const ScannerZXing().getScanner(
        onScan: (_) async => true,
        hapticFeedback: hapticFeedback ?? () async {},
        onCameraFlashError: null,
        trackCustomEvent: (_, _, {int? eventValue, String? barcode}) {},
        hasMoreThanOneCamera: hasMoreThanOneCamera,
        barcodeScannerIcon: const Icon(Icons.qr_code),
        torchOnIcon: const Icon(Icons.flash_on),
        torchOffIcon: const Icon(Icons.flash_off),
        toggleCameraModeTooltip: 'Toggle camera',
      ),
    ),
  ),
);

// The detector's pending timer fires after removal; the state ignores it.
// The reader (native library) is never mounted: that needs a visibility
// update, which takes longer than these tests pump.
Future<void> tearDownScanner(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  test('getType', () {
    expect(const ScannerZXing().getType(), 'ZXing');
  });

  for (final bool twoCameras in <bool>[false, true]) {
    testWidgets('visor and buttons, two cameras: $twoCameras', (
      WidgetTester tester,
    ) async {
      int haptics = 0;
      await pumpScanner(
        tester,
        hasMoreThanOneCamera: twoCameras,
        hapticFeedback: () async => haptics++,
      );

      expect(find.byType(SmoothBarcodeScannerVisor), findsOneWidget);
      expect(find.byType(ReaderWidget), findsNothing);
      expect(find.byType(VisorButton), findsNWidgets(twoCameras ? 1 : 0));

      if (twoCameras) {
        expect(find.byTooltip('Toggle camera'), findsOneWidget);
        expect(find.byIcon(Icons.camera_rear), findsOneWidget);
        await tester.tap(find.byType(VisorButton));
        await tester.pump();
        expect(haptics, 1);
        expect(find.byIcon(Icons.camera_front), findsOneWidget);
        expect(find.byIcon(Icons.camera_rear), findsNothing);
      }

      await tearDownScanner(tester);
    });
  }

  group('getController', () {
    test('is not a Listenable', () {
      expect(const ScannerZXing().getController(), isNot(isA<Listenable>()));
    });

    test('starts stopped and notifies once per change', () async {
      final CustomScannerController controller = const ScannerZXing()
          .getController();
      int notifications = 0;
      controller.hasTorchState.addListener(() => notifications++);

      expect(controller.isStarted, isFalse);
      expect(controller.hasTorch, isFalse);

      await controller.start();
      await controller.start();
      expect(controller.isStarted, isTrue);
      expect(notifications, 1);

      await controller.stop();
      await controller.stop();
      expect(controller.isStarted, isFalse);
      expect(notifications, 2);

      controller.toggleCamera();
      expect(notifications, 3);
    });

    testWidgets(
      'camera view forwards non-empty scans and mounts the reader only while started',
      (WidgetTester tester) async {
        final CustomScannerController controller = const ScannerZXing()
            .getController();
        final List<String> scanned = <String>[];
        await tester.pumpWidget(
          MaterialApp(home: controller.buildCameraView(onScan: scanned.add)),
        );
        expect(find.byType(ReaderWidget), findsNothing);

        await controller.start();
        await tester.pump();
        final ReaderWidget reader = tester.widget<ReaderWidget>(
          find.byType(ReaderWidget),
        );

        reader.onScan!(Code(text: '3017620422003', isValid: true));
        reader.onScan!(Code(text: '', isValid: true));
        expect(scanned, <String>['3017620422003']);

        await controller.stop();
        await tester.pump();
        expect(find.byType(ReaderWidget), findsNothing);
      },
    );
  });
}
