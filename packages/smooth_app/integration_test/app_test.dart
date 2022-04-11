import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/main.dart' as app;

Future<void> _initScreenshot(
  final IntegrationTestWidgetsFlutterBinding binding,
) async {
  if ((!kIsWeb) && Platform.isAndroid) {
    await binding.convertFlutterSurfaceToImage();
  }
}

Future<void> _takeScreenshot(
  final WidgetTester tester,
  final IntegrationTestWidgetsFlutterBinding binding,
  final String screenshotName,
) async {
  if ((!kIsWeb) && Platform.isAndroid) {
    await tester.pumpAndSettle();
  }
  await binding.takeScreenshot(screenshotName);
}

// flutter drive --driver=test_driver/screenshot_driver.dart --target=integration_test/app_test.dart

/// Onboarding screenshots.
void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized()
          as IntegrationTestWidgetsFlutterBinding;

  setUpAll(
    () => SharedPreferences.setMockInitialValues(
      const <String, Object>{
        'IMPORTANCE_AS_STRINGnutriscore': 'important',
        'IMPORTANCE_AS_STRINGnova': 'important',
        'IMPORTANCE_AS_STRINGecoscore': 'important',
      },
    ),
  );

  group('end-to-end test', () {
    testWidgets('just a single screenshot', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await _initScreenshot(binding);

        await app.main(screenshots: true);
        await tester.pumpAndSettle();

        sleep(const Duration(seconds: 30));
        await _takeScreenshot(
            tester, binding, 'test-screenshot-onboarding-home');
        sleep(const Duration(seconds: 10));

        await tester.tap(find.byKey(const Key('next')));
        await tester.pumpAndSettle();

        await _takeScreenshot(
            tester, binding, 'test-screenshot-onboarding-scan');
        sleep(const Duration(seconds: 10));

        await tester.tap(find.byKey(const Key('next')));
        await tester.pumpAndSettle();

        await _takeScreenshot(
            tester, binding, 'test-screenshot-onboarding-health');
        sleep(const Duration(seconds: 10));

        await tester.tap(find.byKey(const Key('next')));
        await tester.pumpAndSettle();

        await _takeScreenshot(
            tester, binding, 'test-screenshot-onboarding-eco');
        sleep(const Duration(seconds: 10));

        await tester.tap(find.byKey(const Key('next')));
        await tester.pumpAndSettle();

        await _takeScreenshot(
            tester, binding, 'test-screenshot-onboarding-prefs');
        sleep(const Duration(seconds: 10));
      });
    });
  });
}
