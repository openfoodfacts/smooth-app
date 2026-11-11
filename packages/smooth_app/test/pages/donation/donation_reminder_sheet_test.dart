import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_model.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/pages/donation/donation_ladder_outline.dart';
import 'package:smooth_app/pages/donation/donation_offer.dart';
import 'package:smooth_app/pages/donation/donation_reminder_sheet.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../../tests_utils/local_database_mock.dart';
import '../../tests_utils/mocks.dart';

const String _tagMutedUntil = 'donationAsksMutedUntil';
const String _tagProductsLookedUp = 'productsLookedUpSinceAsk';
const String _tagLastCountedBarcode = 'lastCountedBarcode';
const String _tagLastReminderShownAt = 'lastReminderShownAt';
const String _tagAppLaunches = 'appLaunches';

const String _notNow = 'Not now';
const String _alreadyDonated = 'I already donated';

/// Every optional field set, so a probe covers the meter too.
AppNewsItem _fullDonationItem() => _donationItem(
  count: 768,
  raised: 47673,
  goal: 170000,
  currency: 'EUR',
  endDate: DateTime.now().add(const Duration(days: 122)),
);

AppNewsItem _donationItem({
  num? count,
  num? raised,
  num? goal,
  String? currency,
  DateTime? endDate,
  num? reminderEvery,
}) => AppNewsItem(
  id: 'donation_campaign_2026',
  title: 'title',
  message: 'message',
  url: 'https://world.openfoodfacts.org/',
  count: count,
  raised: raised,
  goal: goal,
  currency: currency,
  endDate: endDate,
  donationReminderEvery: reminderEvery,
);

Future<(UserPreferences, ProductPreferences)> _preparePreferences({
  String theme = 'Light',
  int appLaunches = 2,
}) async {
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
  await ProductQuery.initCountry(userPreferences);

  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  await sharedPreferences.setInt(_tagAppLaunches, appLaunches);

  return (userPreferences, productPreferences);
}

Future<Widget> _sheetOnly(
  WidgetTester tester, {
  required DonationOffer offer,
  String theme = 'Light',
}) async {
  tester.view.physicalSize = const Size(1080, 2424);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);

  final (
    UserPreferences userPreferences,
    ProductPreferences productPreferences,
  ) = await _preparePreferences(
    theme: theme,
  );

  return MockSmoothApp(
    userPreferences,
    UserManagementProvider(),
    productPreferences,
    ThemeProvider(userPreferences),
    TextContrastProvider(userPreferences),
    ColorProvider(userPreferences),
    Scaffold(body: DonationReminderSheet(offer: offer)),
    localDatabase: MockLocalDatabase(),
  );
}

/// [TextWithBoldParts] gives each span a placeholder semantics label, so
/// `find.text(findRichText: true)` cannot match it.
Finder _findRichText(String text) => find.byWidgetPredicate(
  (Widget widget) =>
      widget is RichText &&
      widget.text.toPlainText(includeSemanticsLabels: false) == text,
);

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues(mockSharedPreferences());
    await mockMatomo();
  });

  setUp(() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tagMutedUntil);
    await prefs.remove(_tagProductsLookedUp);
    await prefs.remove(_tagLastCountedBarcode);
    await prefs.remove(_tagLastReminderShownAt);
    await prefs.remove(_tagAppLaunches);
    MatomoTracker.instance.dropActions();
  });

  group('sheet content', () {
    testWidgets('every block renders top to bottom in AC order', (
      WidgetTester tester,
    ) async {
      final DonationOffer offer = DonationOffer.fromNews(
        _donationItem(count: 768),
      );
      await tester.pumpWidget(await _sheetOnly(tester, offer: offer));
      await tester.pump();

      final double header = tester
          .getTopLeft(find.text('Donate to Open Food Facts'))
          .dy;
      final double headline = tester
          .getTopLeft(
            find.text('Join the 768 people keeping Open Food Facts free.'),
          )
          .dy;
      final double body = tester
          .getTopLeft(
            find.text(
              'A non-profit, built by volunteers, with no ads and no '
              'investors. A small monthly gift keeps it free for everyone.',
            ),
          )
          .dy;
      final Finder tiers = find.byType(DonationLadderOutline);
      expect(tiers, findsNWidgets(3));
      final List<Offset> tierOrigins = <Offset>[
        tester.getTopLeft(tiers.at(0)),
        tester.getTopLeft(tiers.at(1)),
        tester.getTopLeft(tiers.at(2)),
      ];
      final double cta = tester.getTopLeft(find.byType(ElevatedButton)).dy;
      final double notNow = tester.getCenter(find.text(_notNow)).dy;
      final double alreadyDonated = tester
          .getCenter(find.text(_alreadyDonated))
          .dy;

      expect(header, lessThan(headline));
      expect(headline, lessThan(body));
      expect(body, lessThan(tierOrigins[0].dy));
      expect(tierOrigins[1].dy, tierOrigins[0].dy);
      expect(tierOrigins[2].dy, tierOrigins[0].dy);
      expect(tierOrigins[0].dx, lessThan(tierOrigins[1].dx));
      expect(tierOrigins[1].dx, lessThan(tierOrigins[2].dx));
      expect(tierOrigins[0].dy, lessThan(cta));
      expect(cta, lessThan(alreadyDonated));
      expect(notNow, alreadyDonated);
      expect(
        tester.getTopLeft(find.text(_alreadyDonated)).dx,
        lessThan(tester.getTopLeft(find.text(_notNow)).dx),
      );
    });

    testWidgets('a feed with figures renders the campaign meter', (
      WidgetTester tester,
    ) async {
      final DonationOffer offer = DonationOffer.fromNews(_fullDonationItem());
      await tester.pumpWidget(await _sheetOnly(tester, offer: offer));
      await tester.pump();

      expect(_findRichText('€47,673 of €170,000'), findsOneWidget);
      expect(find.text('4 months left'), findsOneWidget);
      final LinearProgressIndicator bar = tester.widget(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, closeTo(0.28, 0.001));
    });

    testWidgets('a feed without figures renders no meter', (
      WidgetTester tester,
    ) async {
      final DonationOffer offer = DonationOffer.fromNews(
        _donationItem(count: 768),
      );
      await tester.pumpWidget(await _sheetOnly(tester, offer: offer));
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('the button carries the selected amount', (
      WidgetTester tester,
    ) async {
      final DonationOffer offer = DonationOffer.fromNews(null);
      await tester.pumpWidget(await _sheetOnly(tester, offer: offer));
      await tester.pump();

      expect(find.text('Give €5 a month'), findsOneWidget);

      await tester.tap(_findRichText('€10 /month'));
      await tester.pump();

      expect(find.text('Give €10 a month'), findsOneWidget);
      expect(find.text('Give €5 a month'), findsNothing);
    });

    testWidgets('a tier chip is a tappable, selectable button to a reader', (
      WidgetTester tester,
    ) async {
      final DonationOffer offer = DonationOffer.fromNews(null);
      await tester.pumpWidget(await _sheetOnly(tester, offer: offer));
      await tester.pump();

      expect(
        tester.getSemantics(find.bySemanticsLabel('€10 a month')),
        matchesSemantics(
          label: '€10 a month',
          isButton: true,
          hasTapAction: true,
          hasSelectedState: true,
          isSelected: false,
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('€5 a month')),
        matchesSemantics(
          label: '€5 a month',
          isButton: true,
          hasTapAction: true,
          hasSelectedState: true,
          isSelected: true,
        ),
      );
      expect(find.bySemanticsLabel('·'), findsNothing);
    });

    testWidgets('a usable donor count renders the plural headline', (
      WidgetTester tester,
    ) async {
      final DonationOffer offer = DonationOffer.fromNews(
        _donationItem(count: 768),
      );
      await tester.pumpWidget(await _sheetOnly(tester, offer: offer));
      await tester.pump();

      expect(
        find.text('Join the 768 people keeping Open Food Facts free.'),
        findsOneWidget,
      );
      expect(find.textContaining('768.0'), findsNothing);
    });

    testWidgets('donor count of 1 renders the singular form', (
      WidgetTester tester,
    ) async {
      final DonationOffer offer = DonationOffer.fromNews(
        _donationItem(count: 1),
      );
      await tester.pumpWidget(await _sheetOnly(tester, offer: offer));
      await tester.pump();

      expect(
        find.text('Join the 1 person keeping Open Food Facts free.'),
        findsOneWidget,
      );
    });

    for (final num? count in <num?>[null, 0, -1, double.infinity]) {
      testWidgets('an unusable donor count ($count) falls back to generic', (
        WidgetTester tester,
      ) async {
        final DonationOffer offer = DonationOffer.fromNews(
          _donationItem(count: count),
        );
        await tester.pumpWidget(await _sheetOnly(tester, offer: offer));
        await tester.pump();

        // The generic headline itself carries no digit; the tiers below it
        // legitimately do (amounts, scan counts), so only the headline is
        // asserted here.
        expect(
          find.text('Join the people keeping Open Food Facts free.'),
          findsOneWidget,
        );
      });
    }

    testWidgets('the middle tier is preselected and exactly 3 tiers show', (
      WidgetTester tester,
    ) async {
      final DonationOffer offer = DonationOffer.fromNews(null);
      await tester.pumpWidget(await _sheetOnly(tester, offer: offer));
      await tester.pump();

      final List<DonationLadderOutline> tiers = tester
          .widgetList<DonationLadderOutline>(find.byType(DonationLadderOutline))
          .toList();
      expect(tiers, hasLength(3));
      expect(
        tiers.where((DonationLadderOutline tier) => tier.active),
        hasLength(1),
      );
      expect(
        find.descendant(
          of: find.byWidget(
            tiers.singleWhere((DonationLadderOutline tier) => tier.active),
          ),
          matching: _findRichText('€5 /month'),
        ),
        findsOneWidget,
      );
      expect(find.text('1,300 scans'), findsOneWidget);
    });
  });

  for (final String theme in <String>['Light', 'Dark', 'AMOLED']) {
    testWidgets('the sheet meets accessibility guidelines in $theme', (
      WidgetTester tester,
    ) async {
      final DonationOffer offer = DonationOffer.fromNews(_fullDonationItem());
      await tester.pumpWidget(
        await _sheetOnly(tester, offer: offer, theme: theme),
      );
      await tester.pump();

      expect(tester, meetsGuideline(textContrastGuideline));
      expect(tester, meetsGuideline(labeledTapTargetGuideline));
    });
  }

  for (final double textScale in <double>[1.3, 2.0]) {
    testWidgets('the sheet does not truncate at textScaler $textScale', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final DonationOffer offer = DonationOffer.fromNews(_fullDonationItem());
      await tester.pumpWidget(await _sheetOnly(tester, offer: offer));
      await tester.pump();

      // The header bar above the body is `SmoothModalSheetHeader`, shared by
      // other sheets, with its own `maxLines: 2` + ellipsis; only the body is
      // this file's.
      for (final Element element
          in find
              .descendant(
                of: find.byType(SingleChildScrollView),
                matching: find.byType(RichText),
              )
              .evaluate()) {
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
