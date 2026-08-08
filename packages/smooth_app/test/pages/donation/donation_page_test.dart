import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_model.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
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

/// The one string allowed to ellipsize - see the truncation probe.
const String _hint = 'Custom amount';
const List<String> _anchors = <String>[
  'pays for 800 scans',
  'pays for 1,300 scans',
  'pays for 2,700 scans',
];

final Finder _selectedCheckBox = find.byWidgetPredicate(
  (Widget widget) =>
      widget is icons.CheckBox &&
      widget.icon == const icons.CheckBox.filled().icon,
);

/// Serves one donation news item, so the feed-driven offer actually renders.
/// The real fetch stops on its own: `ProductQuery` has no language under the
/// test harness, which is the early return in [AppNewsProvider.loadLatestNews].
class _FeedNewsProvider extends AppNewsProvider {
  _FeedNewsProvider(super.preferences, this._donation);

  final AppNewsItem _donation;

  @override
  AppNewsState get state => AppNewsStateLoaded(
    AppNews(
      news: const AppNewsList(<String, AppNewsItem>{}),
      feed: AppNewsFeed(<AppNewsFeedItem>[AppNewsFeedItem(news: _donation)]),
    ),
    DateTime(2026),
  );
}

/// Records what `SmoothHapticFeedback` asks the platform for.
List<String> _recordHaptics() {
  final List<String> played = <String>[];
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, (
        MethodCall call,
      ) async {
        if (call.method == 'HapticFeedback.vibrate') {
          played.add(call.arguments as String? ?? '');
        }
        return null;
      });
  addTearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null),
  );
  return played;
}

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
  AppNewsItem? donation,
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

  Widget page = const DonationPage();
  if (donation != null) {
    final AppNewsProvider news = _FeedNewsProvider(userPreferences, donation);
    addTearDown(news.dispose);
    page = ChangeNotifierProvider<AppNewsProvider?>.value(
      value: news,
      child: page,
    );
  }

  await tester.pumpWidget(
    MockSmoothApp(
      userPreferences,
      UserManagementProvider(),
      productPreferences,
      ThemeProvider(userPreferences),
      TextContrastProvider(userPreferences),
      ColorProvider(userPreferences),
      page,
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

  testWidgets('DonationPage slider snaps across the tiers, with a haptic', (
    WidgetTester tester,
  ) async {
    final List<String> haptics = _recordHaptics();
    await _pumpDonationPage(tester);

    final Slider slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.divisions, 2);
    expect(slider.max, 2.0);
    expect(slider.value, 1.0);
    expect(slider.semanticFormatterCallback!(2.0), '€10');

    await tester.drag(find.byType(Slider), const Offset(500.0, 0.0));
    await tester.pumpAndSettle();

    expect(_selectedAmount(tester), _amounts.last);
    expect(haptics, <String>['HapticFeedbackType.selectionClick']);
  });

  testWidgets('DonationPage takes a custom amount over the tiers', (
    WidgetTester tester,
  ) async {
    await _pumpDonationPage(tester);

    await tester.enterText(find.byType(TextFormField), '7');
    await tester.pump();

    // 7 is not on the ladder, so no tier claims to be what the CTA will send.
    expect(_selectedCheckBox, findsNothing);

    await tester.enterText(find.byType(TextFormField), '10');
    await tester.pump();

    expect(_selectedAmount(tester), _amounts.last);

    await tester.tap(find.text(_amounts.first));
    await tester.pump();

    expect(_selectedAmount(tester), _amounts.first);
    expect(find.widgetWithText(TextFormField, '10'), findsNothing);
  });

  testWidgets('DonationPage renders the offer the feed declares', (
    WidgetTester tester,
  ) async {
    await _pumpDonationPage(
      tester,
      donation: const AppNewsItem(
        id: 'donation_campaign_2026',
        title: 'title',
        message: 'message',
        url: 'https://world.openfoodfacts.org/',
        currency: 'USD',
        donationAmounts: <num>[10, 5, 25, 50],
        donationScansPerUnit: 200,
        donationWhereItGoes: <String>['Servers', 'One engineer'],
      ),
    );

    // The feed's own categories, not the three translated ones.
    final Finder whereItGoesBlock = find.byKey(DonationPage.whereItGoesKey);
    expect(
      find.descendant(of: whereItGoesBlock, matching: find.byType(Text)),
      findsNWidgets(2),
    );
    expect(find.text('One engineer'), findsOneWidget);

    // Four tiers, in the feed's currency, sorted whatever order it sent.
    expect(find.byType(PreferenceTile), findsNWidgets(4));
    for (final String amount in <String>[
      r'$5 a month',
      r'$10 a month',
      r'$25 a month',
      r'$50 a month',
    ]) {
      expect(find.text(amount), findsOneWidget);
    }
    expect(find.text('pays for 1,000 scans'), findsOneWidget);
    expect(tester.widget<Slider>(find.byType(Slider)).divisions, 3);
    expect(_selectedAmount(tester), r'$25 a month');
  });

  testWidgets('DonationPage reads a custom amount in the locale digits', (
    WidgetTester tester,
  ) async {
    await _pumpDonationPage(tester, locale: const Locale('fa'));

    // Persian digits, which `int.tryParse` cannot read at all, and an ASCII 7,
    // which `NumberFormat.decimalPattern('fa')` cannot read either.
    for (final String seven in <String>['۷', '7']) {
      await tester.enterText(find.byType(TextFormField), seven);
      await tester.pump();

      expect(find.text('Enter an amount'), findsNothing);
      // 7 is on neither ladder, so no row claims to be what the CTA sends.
      expect(_selectedCheckBox, findsNothing);
    }

    await tester.enterText(find.byType(TextFormField), 'seven');
    await tester.pump();

    expect(find.text('Enter an amount'), findsOneWidget);
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
      int checked = 0;
      for (final Element element in paragraphs) {
        final RenderParagraph paragraph =
            element.renderObject! as RenderParagraph;
        // The custom-amount hint is the one string allowed to shorten. It sits
        // in a fixed-width field beside a currency suffix, `SmoothTextFormField`
        // gives every hint `TextOverflow.ellipsis` by design, and its content is
        // recoverable from the suffix and the section title. Every string that
        // carries a number the donor is charged is still covered below.
        if (paragraph.text.toPlainText() == _hint) {
          continue;
        }
        checked++;
        expect(
          paragraph.didExceedMaxLines,
          isFalse,
          reason: '"${paragraph.text.toPlainText()}" is truncated',
        );
      }
      // Guards the skip above: if the hint were ever the only paragraph found,
      // this test would pass while asserting nothing.
      expect(checked, greaterThan(5));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'the custom-amount hint shortens gracefully rather than clipping',
    (WidgetTester tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await _pumpDonationPage(tester);

      // The exemption above is only defensible while the hint really does
      // ellipsize, so pin that rather than trusting the shared widget.
      final TextField field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration!.hintText, _hint);
      expect(field.decoration!.hintStyle!.overflow, TextOverflow.ellipsis);
      expect(tester.takeException(), isNull);
    },
  );
}
