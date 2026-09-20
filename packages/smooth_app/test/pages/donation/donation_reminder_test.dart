import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_model.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/pages/donation/donation_offer.dart';
import 'package:smooth_app/pages/donation/donation_reminder.dart';
import 'package:smooth_app/pages/donation/donation_tier_row.dart';
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

AppNewsItem _donationItem({
  num? count,
  num? raised,
  num? goal,
  String? currency,
  DateTime? endDate,
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
);

/// Serves one donation news item, mirroring `donation_page_test.dart`'s
/// `_FeedNewsProvider`; the real fetch never starts under the test harness.
class _FeedNewsProvider extends AppNewsProvider {
  _FeedNewsProvider(super.preferences, this._donation);

  final AppNewsItem? _donation;

  @override
  AppNewsState get state => _donation == null
      ? const AppNewsStateLoading()
      : AppNewsStateLoaded(
          AppNews(
            news: const AppNewsList(<String, AppNewsItem>{}),
            feed: AppNewsFeed(<AppNewsFeedItem>[
              AppNewsFeedItem(news: _donation),
            ]),
          ),
          DateTime(2026),
        );
}

class _Marker extends StatelessWidget {
  const _Marker(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(label)));
  }
}

List<Map<String, String>> _eventsNamed(String name) => MatomoTracker
    .instance
    .queue
    .where((Map<String, String> event) => event['e_n'] == name)
    .toList();

/// Records what the `url_launcher` method channel is asked to open - the
/// platform-interface default under the test harness, since no plugin
/// registrant runs. Without this, a tier tap's future never completes.
List<Map<Object?, Object?>> _recordLaunches() {
  final List<Map<Object?, Object?>> launches = <Map<Object?, Object?>>[];
  const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/url_launcher',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall call) async {
        if (call.method == 'launch') {
          launches.add(
            Map<Object?, Object?>.from(call.arguments as Map<Object?, Object?>),
          );
          return true;
        }
        if (call.method == 'canLaunch') {
          return true;
        }
        return null;
      });
  addTearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );
  return launches;
}

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

/// Pumps `[home, filler]` already on the stack; the product route is pushed
/// separately so a test can assert on the state right before it.
Future<NavigatorState> _pumpHomeAndFiller(
  WidgetTester tester, {
  required UserPreferences userPreferences,
  required ProductPreferences productPreferences,
  AppNewsItem? donation,
}) async {
  tester.view.physicalSize = const Size(1080, 2424);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);

  Widget app = MockSmoothApp(
    userPreferences,
    UserManagementProvider(),
    productPreferences,
    ThemeProvider(userPreferences),
    TextContrastProvider(userPreferences),
    ColorProvider(userPreferences),
    const _Marker('HOME'),
    localDatabase: MockLocalDatabase(),
  );

  // Above `MockSmoothApp`, not below it: every route later pushed on its
  // single Navigator is a sibling subtree of `home`, not a descendant, so the
  // feed has to sit above the Navigator to reach them all.
  final AppNewsProvider news = _FeedNewsProvider(userPreferences, donation);
  addTearDown(news.dispose);
  app = ChangeNotifierProvider<AppNewsProvider?>.value(value: news, child: app);

  await tester.pumpWidget(app);
  await tester.pump();

  final NavigatorState navigator = Navigator.of(
    tester.element(find.text('HOME')),
  );
  navigator.push(
    MaterialPageRoute<void>(builder: (_) => const _Marker('FILLER')),
  );
  await tester.pumpAndSettle();
  return navigator;
}

Future<void> _pushProductPage(
  WidgetTester tester,
  NavigatorState navigator, {
  required String barcode,
  Widget child = const _Marker('PRODUCT'),
}) async {
  navigator.push(
    MaterialPageRoute<void>(
      builder: (_) => DonationReminderScope(barcode: barcode, child: child),
    ),
  );
  await tester.pumpAndSettle();
}

/// Simulates leaving the product page (system back, app-bar back or a swipe
/// all reach `PopScope` the same way) without depending on any one gesture.
Future<void> _leaveProductPage(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

/// Reaches the 10th product page (campaign live, 2nd launch, never shown)
/// and leaves it, so the reminder sheet is showing - the setup every test in
/// `group('leaving an eligible product page')` needs before its own
/// assertions. [extraSetup] runs after the products-looked-up counter is
/// seeded but before the product page is pushed.
Future<(UserPreferences, ProductPreferences, NavigatorState)>
_reachEligibleSheet(
  WidgetTester tester, {
  AppNewsItem? donation,
  Widget child = const _Marker('PRODUCT'),
  Future<void> Function(SharedPreferences prefs)? extraSetup,
}) async {
  final (
    UserPreferences userPreferences,
    ProductPreferences productPreferences,
  ) = await _preparePreferences();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_tagProductsLookedUp, 9);
  if (extraSetup != null) {
    await extraSetup(prefs);
  }

  final NavigatorState navigator = await _pumpHomeAndFiller(
    tester,
    userPreferences: userPreferences,
    productPreferences: productPreferences,
    donation: donation ?? _donationItem(),
  );
  await _pushProductPage(
    tester,
    navigator,
    barcode: 'barcode_10',
    child: child,
  );
  await _leaveProductPage(tester);

  return (userPreferences, productPreferences, navigator);
}

void _expectPoppedOnce(WidgetTester tester) {
  expect(find.text('PRODUCT'), findsNothing);
  expect(find.text('FILLER'), findsOneWidget);
  expect(find.text('HOME'), findsNothing);
  expect(find.byType(DonationReminderSheet), findsNothing);
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

  group('DonationReminderConditions.eligible', () {
    DonationReminderConditions base({
      bool campaignLive = true,
      int productsLookedUp = 10,
      int every = 10,
      bool muted = false,
      int appLaunches = 2,
      DateTime? lastShownAt,
      DateTime? now,
    }) => DonationReminderConditions(
      campaignLive: campaignLive,
      productsLookedUp: productsLookedUp,
      every: every,
      muted: muted,
      appLaunches: appLaunches,
      lastShownAt: lastShownAt,
      now: now ?? DateTime(2026, 9, 20),
    );

    test('true when every clause holds', () {
      expect(base().eligible, isTrue);
    });

    test('false when the campaign is not live', () {
      expect(base(campaignLive: false).eligible, isFalse);
    });

    test('false below the threshold, true at and above it', () {
      expect(base(productsLookedUp: 9, every: 10).eligible, isFalse);
      expect(base(productsLookedUp: 10, every: 10).eligible, isTrue);
      expect(base(productsLookedUp: 15, every: 10).eligible, isTrue);
    });

    test('false when muted', () {
      expect(base(muted: true).eligible, isFalse);
    });

    test('false in the install session, true from the second launch', () {
      expect(base(appLaunches: 1).eligible, isFalse);
      expect(base(appLaunches: 2).eligible, isTrue);
    });

    test('true when never shown', () {
      expect(base(lastShownAt: null).eligible, isTrue);
    });

    test('false 29 days after the last show, true at 30', () {
      final DateTime now = DateTime(2026, 9, 20);
      expect(
        base(
          lastShownAt: now.subtract(const Duration(days: 29)),
          now: now,
        ).eligible,
        isFalse,
      );
      expect(
        base(
          lastShownAt: now.subtract(const Duration(days: 30)),
          now: now,
        ).eligible,
        isTrue,
      );
    });
  });

  group('leaving an eligible product page', () {
    testWidgets('shows the sheet, prefs updated before it renders', (
      WidgetTester tester,
    ) async {
      final (UserPreferences userPreferences, _, _) = await _reachEligibleSheet(
        tester,
        donation: _donationItem(count: 768),
        extraSetup: (SharedPreferences prefs) =>
            prefs.setString(_tagLastCountedBarcode, 'barcode_9'),
      );

      expect(find.byType(DonationReminderSheet), findsOneWidget);
      // The 10th lookup landed and the reminder was marked shown before the
      // sheet was even asked to build.
      expect(userPreferences.productsLookedUpSinceAsk, 0);
      expect(userPreferences.lastReminderShownAt, isNotNull);

      final List<Map<String, String>> events = _eventsNamed(
        'donationReminderShown',
      );
      expect(events, hasLength(1));
      expect(events.single['e_v'], '10');
    });

    testWidgets('no product data leaks into the sheet', (
      WidgetTester tester,
    ) async {
      await _reachEligibleSheet(tester, child: const _Marker('Zzz Brand'));

      expect(
        find.descendant(
          of: find.byType(DonationReminderSheet),
          matching: find.textContaining('Zzz'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(DonationReminderSheet),
          matching: find.byType(Image),
        ),
        findsNothing,
      );
    });

    for (final String action in <String>[
      'close button',
      'scrim tap',
      'system back',
      'not now',
      'already donated',
    ]) {
      testWidgets('"$action" closes the sheet, product pops exactly once', (
        WidgetTester tester,
      ) async {
        await _reachEligibleSheet(tester);
        expect(find.byType(DonationReminderSheet), findsOneWidget);

        switch (action) {
          case 'close button':
            await tester.tap(find.byTooltip('Close'));
          case 'scrim tap':
            await tester.tapAt(const Offset(20.0, 20.0));
          case 'system back':
            await _leaveProductPage(tester);
          case 'not now':
            await tester.tap(find.text(_notNow));
          case 'already donated':
            await tester.tap(find.text(_alreadyDonated));
        }
        await tester.pumpAndSettle();

        _expectPoppedOnce(tester);
        if (action == 'close button' ||
            action == 'scrim tap' ||
            action == 'system back') {
          expect(_eventsNamed('donationReminderNotNow'), isEmpty);
          expect(_eventsNamed('donationAlreadyDonated'), isEmpty);
        }
      });
    }

    testWidgets('"Not now" changes nothing beyond the show itself', (
      WidgetTester tester,
    ) async {
      final (UserPreferences userPreferences, _, _) = await _reachEligibleSheet(
        tester,
      );

      await tester.tap(find.text(_notNow));
      await tester.pumpAndSettle();

      expect(_eventsNamed('donationReminderNotNow'), hasLength(1));
      expect(userPreferences.donationAsksMutedUntil, isNull);
    });

    testWidgets('"I already donated" mutes for a year, value 3', (
      WidgetTester tester,
    ) async {
      final (UserPreferences userPreferences, _, _) = await _reachEligibleSheet(
        tester,
      );

      final DateTime before = DateTime.now();
      await tester.tap(find.text(_alreadyDonated));
      await tester.pumpAndSettle();

      final List<Map<String, String>> events = _eventsNamed(
        'donationAlreadyDonated',
      );
      expect(events, hasLength(1));
      expect(events.single['e_v'], '3');
      expect(
        userPreferences.donationAsksMutedUntil!
            .difference(before.add(const Duration(days: 365)))
            .abs(),
        lessThan(const Duration(seconds: 5)),
      );
    });

    testWidgets('a tier tap hands off with the reminder URL and mutes 90d', (
      WidgetTester tester,
    ) async {
      final List<Map<Object?, Object?>> launches = _recordLaunches();
      final (UserPreferences userPreferences, _, _) = await _reachEligibleSheet(
        tester,
      );

      final DateTime before = DateTime.now();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      _expectPoppedOnce(tester);

      final List<Map<String, String>> handoffEvents = _eventsNamed(
        'donationReminderHandoff',
      );
      expect(handoffEvents, hasLength(1));
      expect(handoffEvents.single['e_v'], '5');
      expect(_eventsNamed('donationHandoff'), isEmpty);

      expect(launches, hasLength(1));
      expect(
        launches.single['url'],
        endsWith('utm_content=donation-screen-reminder'),
      );
      expect(
        userPreferences.donationAsksMutedUntil!
            .difference(before.add(const Duration(days: 90)))
            .abs(),
        lessThan(const Duration(seconds: 5)),
      );
    });
  });

  group('not eligible', () {
    testWidgets('muted -> plain pop, no sheet', (WidgetTester tester) async {
      final (
        UserPreferences userPreferences,
        ProductPreferences productPreferences,
      ) = await _preparePreferences();
      await userPreferences.muteDonationAsks(const Duration(days: 365));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_tagProductsLookedUp, 9);

      final NavigatorState navigator = await _pumpHomeAndFiller(
        tester,
        userPreferences: userPreferences,
        productPreferences: productPreferences,
        donation: _donationItem(),
      );
      await _pushProductPage(tester, navigator, barcode: 'barcode_10');

      await _leaveProductPage(tester);

      _expectPoppedOnce(tester);
    });

    testWidgets('campaign not live -> plain pop, no sheet', (
      WidgetTester tester,
    ) async {
      final (
        UserPreferences userPreferences,
        ProductPreferences productPreferences,
      ) = await _preparePreferences();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_tagProductsLookedUp, 20);

      final NavigatorState navigator = await _pumpHomeAndFiller(
        tester,
        userPreferences: userPreferences,
        productPreferences: productPreferences,
        donation: null,
      );
      await _pushProductPage(tester, navigator, barcode: 'barcode_10');

      await _leaveProductPage(tester);

      _expectPoppedOnce(tester);
    });

    testWidgets('a forward push does not trigger it; the eventual back does', (
      WidgetTester tester,
    ) async {
      final (
        UserPreferences userPreferences,
        ProductPreferences productPreferences,
      ) = await _preparePreferences();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_tagProductsLookedUp, 9);

      final NavigatorState navigator = await _pumpHomeAndFiller(
        tester,
        userPreferences: userPreferences,
        productPreferences: productPreferences,
        donation: _donationItem(),
      );
      await _pushProductPage(tester, navigator, barcode: 'barcode_10');

      navigator.push(
        MaterialPageRoute<void>(builder: (_) => const _Marker('EDIT')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DonationReminderSheet), findsNothing);

      await _leaveProductPage(tester);
      expect(find.text('PRODUCT'), findsOneWidget);
      expect(find.byType(DonationReminderSheet), findsNothing);

      await _leaveProductPage(tester);
      expect(find.byType(DonationReminderSheet), findsOneWidget);
    });
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
      // One row of three, left to right.
      expect(tierOrigins[1].dy, tierOrigins[0].dy);
      expect(tierOrigins[2].dy, tierOrigins[0].dy);
      expect(tierOrigins[0].dx, lessThan(tierOrigins[1].dx));
      expect(tierOrigins[1].dx, lessThan(tierOrigins[2].dx));
      expect(tierOrigins[0].dy, lessThan(cta));
      expect(cta, lessThan(alreadyDonated));
      // One row of two links, "I already donated" first.
      expect(notNow, alreadyDonated);
      expect(
        tester.getTopLeft(find.text(_alreadyDonated)).dx,
        lessThan(tester.getTopLeft(find.text(_notNow)).dx),
      );
    });

    testWidgets('a feed with figures renders the campaign meter', (
      WidgetTester tester,
    ) async {
      final DonationOffer offer = DonationOffer.fromNews(
        _donationItem(
          count: 768,
          raised: 47673,
          goal: 170000,
          currency: 'EUR',
          endDate: DateTime.now().add(const Duration(days: 122)),
        ),
      );
      await tester.pumpWidget(await _sheetOnly(tester, offer: offer));
      await tester.pump();

      expect(find.text('€47,673'), findsOneWidget);
      expect(find.text('of €170,000'), findsOneWidget);
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

      await tester.tap(find.text('€10 /month'));
      await tester.pump();

      expect(find.text('Give €10 a month'), findsOneWidget);
      expect(find.text('Give €5 a month'), findsNothing);
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
          matching: find.text('€5 /month'),
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
      final DonationOffer offer = DonationOffer.fromNews(
        _donationItem(count: 768),
      );
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

      final DonationOffer offer = DonationOffer.fromNews(
        _donationItem(count: 768),
      );
      await tester.pumpWidget(await _sheetOnly(tester, offer: offer));
      await tester.pump();

      // Scoped to the scrollable body, not the whole sheet: the header bar
      // above it is `SmoothModalSheetHeader`, shared by a dozen other
      // screens, with its own `maxLines: 2` + ellipsis contract - it
      // gracefully clips by design and is outside this file's control, so
      // AC10's "scrolls rather than overflows" claim is about the body only.
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
