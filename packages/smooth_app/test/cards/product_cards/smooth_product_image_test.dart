import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_image.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../../tests_utils/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // A tiny, valid PNG. We inspect the decoding configuration, not the visual
  // size of this fixture, so no network request or large image is necessary.
  final MemoryImage source = MemoryImage(
    base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAQAAAADCAIAAAA7ljmR'
      'AAAAEElEQVR4nGP8z4AATAy4OAAmdgEF5PO41QAAAABJRU5ErkJggg==',
    ),
  );

  late ThemeProvider themeProvider;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(mockSharedPreferences());
    final UserPreferences preferences =
        await UserPreferences.getUserPreferences();
    themeProvider = ThemeProvider(preferences);
  });

  tearDownAll(() => themeProvider.dispose());

  Future<void> pumpPicture(
    WidgetTester tester, {
    Size size = const Size(120, 80),
    double devicePixelRatio = 2,
    String? heroTag,
  }) async {
    tester.view.devicePixelRatio = devicePixelRatio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeProvider>.value(
        value: themeProvider,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Center(
              child: ProductPicture.fromImageProvider(
                imageProvider: source,
                size: size,
                heroTag: heroTag,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<ResizeImage> resizedProviders(WidgetTester tester) {
    final Iterable<Image> images = tester.widgetList<Image>(
      find.descendant(
        of: find.byType(ProductPicture),
        matching: find.byType(Image),
      ),
    );

    // One foreground image and one blurred/background image.
    expect(images, hasLength(2));

    return images.map((Image image) {
      expect(image.image, isA<ResizeImage>());
      return image.image as ResizeImage;
    }).toList();
  }

  testWidgets('resizes both image layers with aspect-ratio preservation', (
    WidgetTester tester,
  ) async {
    await pumpPicture(tester);

    final List<ResizeImage> providers = resizedProviders(tester);
    for (final ResizeImage resized in providers) {
      expect(resized.imageProvider, same(source));
      expect(resized.width, 240);
      expect(resized.height, 160);
      expect(resized.policy, ResizeImagePolicy.fit);
    }

    // Both layers must use a compatible cache configuration; optimizing only
    // the foreground would still leave the background at full resolution.
    expect(providers[0].width, providers[1].width);
    expect(providers[0].height, providers[1].height);
  });

  for (final (double ratio, int width, int height) in <(double, int, int)>[
    (1, 120, 80),
    (2, 240, 160),
    (3, 360, 240),
  ]) {
    testWidgets('uses physical-pixel cache dimensions at DPR $ratio', (
      WidgetTester tester,
    ) async {
      await pumpPicture(tester, devicePixelRatio: ratio);

      for (final ResizeImage resized in resizedProviders(tester)) {
        expect(resized.width, width);
        expect(resized.height, height);
      }
    });
  }

  testWidgets('preserves the Hero animation wrapper', (
    WidgetTester tester,
  ) async {
    await pumpPicture(tester, heroTag: 'product-front');

    final Finder hero = find.descendant(
      of: find.byType(ProductPicture),
      matching: find.byType(Hero),
    );
    expect(hero, findsOneWidget);
    expect(tester.widget<Hero>(hero).tag, 'product-front');
    expect(resizedProviders(tester), hasLength(2));
  });
}
