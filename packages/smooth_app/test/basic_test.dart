import 'package:app_store_shared/app_store_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/main.dart';

void main() {
  testWidgets('App Starts', (WidgetTester tester) async {
    await tester.pumpWidget(
      const SmoothApp(
        MockedAppStore(),
      ),
    );
    expect(find.byType(SmoothApp), findsOneWidget);
  });
}
