import 'package:app_store_shared/app_store_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/main.dart';
import 'package:smooth_app/pages/scan/smooth_barcode_scanner_type.dart';

void main() {
  testWidgets('App Starts', (WidgetTester tester) async {
    await tester.pumpWidget(
      const SmoothApp(
        SmoothBarcodeScannerType.mockup,
        MockedAppStore(),
      ),
    );
    expect(find.byType(SmoothApp), findsOneWidget);
  });
}
