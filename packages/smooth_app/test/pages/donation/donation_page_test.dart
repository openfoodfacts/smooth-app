import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/pages/donation/donation_page.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../../tests_utils/local_database_mock.dart';
import '../../tests_utils/mocks.dart';

const String _headline = 'Open Food Facts is funded by the people who use it';
const String _whereItGoesTitle = 'Where it goes';
const String _tiersTitle = 'Monthly, cancel any time';
const String _ctaMonthly = 'Support monthly';
const String _ctaOneOff = 'Give once instead';

/// Pinned formats: whole euros, and a grouped scan count.
const List<String> _amounts = <String>[
  '€3 a month',
  '€5 a month',
  '€10 a month',
];
const List<String> _anchors = <String>[
  'about 800 scans',
  'about 1,300 scans',
  'about 2,700 scans',
];

final Finder _selectedCheckBox = find.byWidgetPredicate(
  (Widget widget) =>
      widget is icons.CheckBox &&
      widget.icon == const icons.CheckBox.filled().icon,
);

String _selectedAmount(WidgetTester tester) => tester
    .widget<PreferenceTile>(
      find.ancestor(
        of: _selectedCheckBox,
        matching: find.byType(PreferenceTile),
      ),
    )
    .title;

Future<void> _pumpDonationPage(
  WidgetTester tester, {
  String theme = 'Light',
  Locale? locale,
}) async {
  tester.view.physicalSize = const Size(1080, 2424);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);

  if (locale != null) {
    tester.platformDispatcher.localesTestValue = <Locale>[locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  }

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
  // The page's analytics event reads the query country, which the real app
  // initializes during onboarding.
  await ProductQuery.initCountry(userPreferences);

  await tester.pumpWidget(
    MockSmoothApp(
      userPreferences,
      UserManagementProvider(),
      productPreferences,
      ThemeProvider(userPreferences),
      TextContrastProvider(userPreferences),
      ColorProvider(userPreferences),
      const DonationPage(),
      localDatabase: MockLocalDatabase(),
    ),
  );
  await tester.pump();
}

void main() {
  for (final String theme in <String>['Light', 'Dark', 'AMOLED']) {
    testWidgets('DonationPage is complete in $theme', (
      WidgetTester tester,
    ) async {
      await _pumpDonationPage(tester, theme: theme);

      // Every block, top to bottom.
      final double headline = tester.getTopLeft(find.text(_headline)).dy;
      final double whereItGoes = tester
          .getTopLeft(find.text(_whereItGoesTitle))
          .dy;
      final double tiers = tester.getTopLeft(find.text(_tiersTitle)).dy;
      final double primaryCta = tester
          .getTopLeft(find.byType(SmoothLargeButtonWithIcon))
          .dy;
      final double secondaryCta = tester.getTopLeft(find.text(_ctaOneOff)).dy;

      expect(headline, lessThan(whereItGoes));
      expect(whereItGoes, lessThan(tiers));
      expect(tiers, lessThan(primaryCta));
      expect(primaryCta, lessThan(secondaryCta));

      // Three categories, and not a single euro figure among them.
      final Finder whereItGoesBlock = find.byKey(DonationPage.whereItGoesKey);
      expect(
        find.descendant(of: whereItGoesBlock, matching: find.byType(Text)),
        findsNWidgets(3),
      );
      for (final String forbidden in <String>['€', '74', '68', '30']) {
        expect(
          find.descendant(
            of: whereItGoesBlock,
            matching: find.textContaining(forbidden),
          ),
          findsNothing,
          reason: 'the "where it goes" block must not name amounts',
        );
      }

      // Three tiers.
      expect(find.byType(PreferenceTile), findsNWidgets(3));

      // Both calls to action, the second one deliberately quieter.
      expect(
        tester
            .widget<SmoothLargeButtonWithIcon>(
              find.byType(SmoothLargeButtonWithIcon),
            )
            .text,
        _ctaMonthly,
      );
      expect(find.widgetWithText(TextButton, _ctaOneOff), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, _ctaOneOff), findsNothing);

      expect(tester, meetsGuideline(textContrastGuideline));
      expect(tester, meetsGuideline(labeledTapTargetGuideline));
    });
  }

  testWidgets('DonationPage preselects 5 EUR and moves the selection on tap', (
    WidgetTester tester,
  ) async {
    await _pumpDonationPage(tester);

    expect(_selectedCheckBox, findsOneWidget);
    expect(_selectedAmount(tester), _amounts[1]);

    await tester.tap(find.text(_amounts.last));
    await tester.pump();

    expect(_selectedCheckBox, findsOneWidget);
    expect(_selectedAmount(tester), _amounts.last);
  });

  testWidgets('DonationPage formats the amounts and the scan anchors', (
    WidgetTester tester,
  ) async {
    await _pumpDonationPage(tester);

    for (final String amount in _amounts) {
      expect(find.text(amount), findsOneWidget);
    }
    for (final String anchor in _anchors) {
      expect(find.text(anchor), findsOneWidget);
    }
    expect(find.textContaining(',00'), findsNothing);
    expect(find.textContaining('.00'), findsNothing);
  });

  // `intl` ships no number symbols for 46 of the app's 128 locales; before the
  // fallback, both NumberFormat constructors threw and the tier list - the
  // screen's only interaction - was replaced by an ErrorWidget.
  for (final String locale in <String>['nn', 'lb', 'gd']) {
    testWidgets('DonationPage keeps its tiers in $locale', (
      WidgetTester tester,
    ) async {
      await _pumpDonationPage(tester, locale: Locale(locale));

      // Flutter ships no Material or Cupertino delegates for these locales, so
      // the pumped tree says so and then cannot lay the top bar out. That is
      // app-wide and pre-existing; an `intl` ArgumentError would not be, and
      // is what this test exists to catch.
      for (
        Object? exception = tester.takeException();
        exception != null;
        exception = tester.takeException()
      ) {
        expect(exception, isNot(isA<ArgumentError>()), reason: '$exception');
      }

      expect(find.byType(PreferenceTile), findsNWidgets(3));
      // Formatting falls back to `en`, so the numbers still render grouped
      // even though the sentence around them is translated.
      for (final String number in <String>['800', '1,300', '2,700']) {
        expect(find.textContaining(number), findsOneWidget);
      }
    });
  }

  for (final double textScale in <double>[1.3, 2.0]) {
    testWidgets('DonationPage does not truncate at textScaler $textScale', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await _pumpDonationPage(tester);

      final Iterable<Element> paragraphs = find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(RichText),
          )
          .evaluate();

      expect(paragraphs, isNotEmpty);
      for (final Element element in paragraphs) {
        final RenderParagraph paragraph =
            element.renderObject! as RenderParagraph;
        expect(
          paragraph.didExceedMaxLines,
          isFalse,
          reason: '"${paragraph.text.toPlainText()}" is truncated',
        );
      }
      expect(tester.takeException(), isNull);
    });
  }
}
