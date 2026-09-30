import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScanProductCardNotFound Layout (NORMAL)', () {
    testWidgets(
      'does not overflow when constrained height is less than intrinsic height',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  height: 200.0,
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 100.0),
                            Spacer(),
                            SizedBox(height: 150.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(CustomScrollView), findsOneWidget);
      },
    );

    testWidgets(
      'expands correctly when constrained height is greater than intrinsic height',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  height: 500.0,
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 100.0),
                            Spacer(),
                            SizedBox(height: 150.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(CustomScrollView), findsOneWidget);
      },
    );
  });
}
