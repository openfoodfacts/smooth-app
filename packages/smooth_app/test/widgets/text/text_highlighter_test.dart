import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/widgets/text/text_highlighter.dart';

// Nonlinear at every size: small text grows more than large text.
class _PlusTenScaler extends TextScaler {
  const _PlusTenScaler();

  @override
  double scale(double fontSize) => fontSize + 10;

  @override
  double get textScaleFactor => 1.0;
}

void main() {
  testWidgets('a bubble is scaled at its own font size', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: _PlusTenScaler()),
          child: Material(
            child: TextWithBubbleParts(
              text: 'text **bubble**',
              backgroundColor: Colors.orange,
              textStyle: TextStyle(fontSize: 26, height: 1.0),
              bubbleTextStyle: TextStyle(fontSize: 22, height: 1.0),
              bubblePadding: EdgeInsetsDirectional.zero,
            ),
          ),
        ),
      ),
    );

    final Rect bubble = tester.getRect(find.text('bubble'));
    expect(bubble.height, moreOrLessEquals(22 + 10, epsilon: 0.5));
  });
}
