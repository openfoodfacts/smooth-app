import 'package:flutter_test/flutter_test.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:smooth_app/main.dart';

void main() {
  testWidgets('App Starts', (WidgetTester tester) async {
    await tester.pumpWidget(SmoothApp(MockedCameraScanner()));
    expect(find.byType(SmoothApp), findsOneWidget);
  });
}
