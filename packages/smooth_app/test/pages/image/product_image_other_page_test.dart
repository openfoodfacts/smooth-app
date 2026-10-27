import 'package:flutter/material.dart';
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
  testWidgets('the zoom button opens the full size photo', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(mockSharedPreferences());
    final UserPreferences prefs = await UserPreferences.getUserPreferences();
    ProductQuery.setQueryType(prefs);
    final ThemeProvider themeProvider = ThemeProvider(prefs);
    final ProductImage image = ProductImage.raw(
      imgid: '2',
      size: ImageSize.DISPLAY,
    );

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
}
