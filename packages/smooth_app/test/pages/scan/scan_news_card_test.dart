import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_model.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/pages/scan/carousel/main_card/bottom_cards/news/scan_news_card.dart';
import 'package:smooth_app/pages/scan/carousel/main_card/bottom_cards/scan_bottom_card.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../../tests_utils/local_database_mock.dart';
import '../../tests_utils/mocks.dart';

/// Five calendar months ahead, whatever the day the test runs on.
DateTime _fiveMonthsFromNow() {
  final DateTime now = DateTime.now();
  return DateTime(now.year, now.month + 5, now.day, 23, 59, 59);
}

AppNewsItem _newsItem({
  num? raised,
  num? goal,
  String? currency,
  AppNewsStyle? style,
  DateTime? endDate,
}) => AppNewsItem(
  id: 'donation_campaign_2026',
  title: 'Our application needs you!',
  message: 'Help us inform millions of consumers on what they eat!',
  url: 'https://world.openfoodfacts.org/donate-to-open-food-facts',
  endDate: endDate ?? _fiveMonthsFromNow(),
  raised: raised,
  goal: goal,
  currency: currency,
  style: style,
);

Future<void> _pumpCard(
  WidgetTester tester,
  String theme,
  AppNewsItem item, {
  double? textScaler,
}) async {
  tester.view.physicalSize = const Size(1080, 2424);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues(mockSharedPreferences());

  final UserPreferences userPreferences =
      await UserPreferences.getUserPreferences();
  userPreferences.setTheme(theme);

  late ProductPreferences productPreferences;
  productPreferences = ProductPreferences(
    ProductPreferencesSelection(
      setImportance: userPreferences.setImportance,
      getImportance: userPreferences.getImportance,
      notify: () => productPreferences.notifyListeners(),
    ),
  );
  await productPreferences.init(PlatformAssetBundle());
  await userPreferences.init(productPreferences);

  // Both are needed: `ProductQuery.getLocaleString()` reads the language and
  // the country, and `_country` is a bare `late` field.
  ProductQuery.setLanguage(null, userPreferences, languageCode: 'en');
  await ProductQuery.setCountry(userPreferences, 'fr');

  final Widget cardWidget = ScanNewsCard(news: <AppNewsItem>[item]);
  final double? scaler = textScaler;
  final Widget card = scaler == null
      ? cardWidget
      : Builder(
          builder: (BuildContext context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scaler)),
            child: cardWidget,
          ),
        );

  await tester.pumpWidget(
    MockSmoothApp(
      userPreferences,
      UserManagementProvider(),
      productPreferences,
      ThemeProvider(userPreferences),
      TextContrastProvider(userPreferences),
      ColorProvider(userPreferences),
      Provider<ScanBottomCardDensity>.value(
        value: ScanBottomCardDensity.dense,
        child: SingleChildScrollView(child: card),
      ),
      localDatabase: MockLocalDatabase(),
    ),
  );
  await tester.pump();
}

void main() {
  group('ScanNewsCard with campaign figures', () {
    for (final String theme in <String>['Light', 'Dark', 'AMOLED']) {
      testWidgets(theme, (WidgetTester tester) async {
        await _pumpCard(
          tester,
          theme,
          _newsItem(raised: 44059.47, goal: 170000.0, currency: 'EUR'),
        );

        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        // Whole euros, so the amounts fit the row the design draws.
        expect(find.textContaining('.47'), findsNothing);
        // Both funding lines carry the separator the app joins in code.
        expect(find.textContaining('·'), findsNWidgets(2));
        expect(tester, meetsGuideline(textContrastGuideline));
        expect(tester, meetsGuideline(labeledTapTargetGuideline));
      });
    }
  });

  group('ScanNewsCard without campaign figures', () {
    for (final String theme in <String>['Light', 'Dark', 'AMOLED']) {
      testWidgets(theme, (WidgetTester tester) async {
        await _pumpCard(tester, theme, _newsItem());

        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(tester, meetsGuideline(textContrastGuideline));
        expect(tester, meetsGuideline(labeledTapTargetGuideline));
      });
    }
  });

  // Money must never be truncated: a clipped amount is a wrong amount, and the
  // row has to survive a long locale and an enlarged system font.
  group('The funding amounts are not clipped', () {
    for (final double scaler in <double>[1.3, 2.0]) {
      testWidgets('at a text scale of $scaler', (WidgetTester tester) async {
        await _pumpCard(
          tester,
          'Light',
          _newsItem(raised: 44059.47, goal: 170000.0, currency: 'EUR'),
          textScaler: scaler,
        );

        final Iterable<RenderParagraph> amounts = tester
            .renderObjectList<RenderParagraph>(
              find.descendant(
                of: find
                    .ancestor(
                      of: find.byType(LinearProgressIndicator),
                      matching: find.byType(Column),
                    )
                    .first,
                matching: find.byType(RichText),
              ),
            );

        expect(amounts.length, 3);
        for (final RenderParagraph amount in amounts) {
          expect(
            amount.didExceedMaxLines,
            isFalse,
            reason: amount.text.toPlainText(),
          );
        }
      });
    }
  });

  testWidgets('A deadline beyond a year is not shown as time left', (
    WidgetTester tester,
  ) async {
    await _pumpCard(
      tester,
      'Light',
      _newsItem(
        raised: 44059.47,
        goal: 170000.0,
        currency: 'EUR',
        endDate: DateTime(DateTime.now().year + 2, 1, 31),
      ),
    );

    expect(find.textContaining('short'), findsOneWidget);
    expect(find.textContaining('left'), findsNothing);
  });

  testWidgets('The feed style drives the meter colours', (
    WidgetTester tester,
  ) async {
    const Color messageTextColor = Color(0xFFEEEEEE);
    const Color titleIndicatorColor = Color(0xFF00FF00);

    await _pumpCard(
      tester,
      'Light',
      _newsItem(
        raised: 44059.47,
        goal: 170000.0,
        currency: 'EUR',
        style: const AppNewsStyle(
          messageTextColor: messageTextColor,
          titleIndicatorColor: titleIndicatorColor,
        ),
      ),
    );

    final LinearProgressIndicator bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );

    expect(bar.color, titleIndicatorColor);
    expect(bar.backgroundColor, messageTextColor.withValues(alpha: 0.2));
    expect(bar.semanticsValue, '26');
  });
}
