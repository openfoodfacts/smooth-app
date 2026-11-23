import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';

void main() {
  testWidgets('Alert dialog can be created', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SmoothAlertDialog(body: Placeholder())),
    );
    expect(find.byType(SmoothAlertDialog), findsOneWidget);
  });
}
