import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/pages/scan/carousel/scan_carousel.dart';

void main() {
  group('ScanCardDensityExtension', () {
    testWidgets('density is DENSE for maxHeight <= 400', (WidgetTester tester) async {
      await tester.pumpWidget(Builder(builder: (BuildContext context) {
        final ScanCardDensity density = ScanCardDensityExtension.getDensity(
          context,
          const BoxConstraints(maxHeight: 400.0),
        );
        expect(density, ScanCardDensity.DENSE);
        return const SizedBox.shrink();
      }));
    });

    testWidgets('density is NORMAL for maxHeight > 400 at normal text scale', (WidgetTester tester) async {
      await tester.pumpWidget(Builder(builder: (BuildContext context) {
        final ScanCardDensity density = ScanCardDensityExtension.getDensity(
          context,
          const BoxConstraints(maxHeight: 401.0),
        );
        expect(density, ScanCardDensity.NORMAL);
        return const SizedBox.shrink();
      }));
    });

    testWidgets('density is DENSE for high text scale despite large maxHeight', (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: Builder(builder: (BuildContext context) {
            final ScanCardDensity density = ScanCardDensityExtension.getDensity(
              context,
              const BoxConstraints(maxHeight: 800.0),
            );
            expect(density, ScanCardDensity.DENSE);
            return const SizedBox.shrink();
          }),
        ),
      );
    });
  });
}
