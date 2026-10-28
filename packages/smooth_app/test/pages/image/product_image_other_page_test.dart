import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/image/product_image_other_page.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_interactive_viewer.dart';

import '../../tests_utils/mocks.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester, final ProductImage image) async {
    SharedPreferences.setMockInitialValues(mockSharedPreferences());
    final UserPreferences prefs = await UserPreferences.getUserPreferences();
    ProductQuery.setQueryType(prefs);
    final ThemeProvider themeProvider = ThemeProvider(prefs);

    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeProvider>.value(
        value: themeProvider,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: SmoothTheme.getThemeData(
            Brightness.light,
            themeProvider,
            () => ColorProvider(prefs),
            () => TextContrastProvider(prefs),
          ),
          home: ProductImageOtherPage(
            product: Product(barcode: '123'),
            language: OpenFoodFactsLanguage.ENGLISH,
            images: <ProductImage>[image],
            currentImage: image,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('the zoom button opens the full size photo', (
    WidgetTester tester,
  ) async {
    await pumpPage(
      tester,
      ProductImage.raw(imgid: '2', size: ImageSize.DISPLAY),
    );

    await tester.tap(find.byTooltip('Zoom in on the full size photo'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final Image fullSize = tester.widget<Image>(
      find.descendant(
        of: find.byType(SmoothInteractiveViewer),
        matching: find.byType(Image),
      ),
    );
    expect((fullSize.image as NetworkImage).url, endsWith('/0123/2.jpg'));
  });

  testWidgets('the full size photo page copies the photo URL', (
    WidgetTester tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (final MethodCall call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await pumpPage(
      tester,
      ProductImage.raw(imgid: '2', size: ImageSize.DISPLAY),
    );
    await tester.tap(find.byTooltip('Zoom in on the full size photo'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byTooltip('Copy the photo URL'));
    await tester.pump();

    expect(copied, endsWith('/0123/2.jpg'));
    expect(find.text('Photo URL copied to the clipboard!'), findsOneWidget);
  });

  for (final double textScale in <double>[1.0, 1.3]) {
    testWidgets('an outdated photo fits a small screen at $textScale', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080.0, 2400.0);
      tester.view.devicePixelRatio = 3.0;
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpPage(
        tester,
        ProductImage.raw(
          imgid: '2',
          size: ImageSize.DISPLAY,
          uploaded: DateTime(2020),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  }
}
