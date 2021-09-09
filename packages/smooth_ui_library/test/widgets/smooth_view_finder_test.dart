import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_ui_library/widgets/smooth_view_finder.dart';

void main() {
  testWidgets('SmoothViewFinder looks as expected',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Container(
          // Add background to make it easier to inspect the golden file.
          color: Colors.lightGreen,
          child: const SmoothViewFinder(
            boxSize: Size(200, 150),
            lineLength: 250,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(
      find.byType(SmoothViewFinder),
      matchesGoldenFile('goldens/smooth_view_finder.png'),
    );
  });
}
