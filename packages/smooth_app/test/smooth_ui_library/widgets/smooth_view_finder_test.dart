import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_view_finder.dart';

void main() {
  group('SmoothViewFinder', () {
    const Widget widget = Material(
      // Add background to make it easier to inspect the golden file.
      color: Colors.lightGreen,
      child: SmoothViewFinder(
        boxSize: Size(200, 150),
        lineLength: 250,
      ),
    );

    testWidgets('looks as expected', (WidgetTester tester) async {
      await tester.pumpWidget(widget);
      expect(
        find.byType(SmoothViewFinder),
        matchesGoldenFile('goldens/smooth_view_finder.png'),
      );
    });

    testWidgets('pulsates', (WidgetTester tester) async {
      final AnimationSheetBuilder animationSheet =
          AnimationSheetBuilder(frameSize: const Size(300, 300));
      await tester.pumpFrames(
        animationSheet.record(widget),
        const Duration(seconds: 3),
        const Duration(seconds: 1),
      );
      expect(
        animationSheet.collate(1),
        matchesGoldenFile('goldens/smooth_view_finder-animation.png'),
      );
    });
  });
}
