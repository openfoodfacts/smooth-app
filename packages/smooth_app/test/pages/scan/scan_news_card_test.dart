import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
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
import 'package:smooth_app/widgets/autosize_text.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../tests_utils/local_database_mock.dart';
import '../../tests_utils/mocks.dart';

// `UserPreferences.getUserPreferences()` memoizes a single instance for the
// whole isolate (`user_preferences.dart:50-60`), and the legacy
// `SharedPreferences` plugin memoizes its own instance the same way - so
// `SharedPreferences.setMockInitialValues` only has effect before the very
// first `getInstance()` call. These are the two tagline-feed keys
// (`user_preferences.dart:139-141`); clearing them directly on the shared
// cached instance is what actually isolates each test.
const String _tagDisplayed = 'taglineFeedNewsDisplayed';
const String _tagClicked = 'taglineFeedNewsClicked';

const AppNewsItem _item0 = AppNewsItem(
  id: 'news-0',
  title: 'First news',
  message: 'First message',
  url: 'https://example.com/0',
);

const AppNewsItem _item1 = AppNewsItem(
  id: 'news-1',
  title: 'Second news',
  message: 'Second message',
  url: 'https://example.com/1',
);

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

/// Pumps a [ScanNewsCard] behind everything the widget reads from context.
///
/// [offstage], when given, drives an [Offstage] wrapper so a test can flip
/// visibility mid-run without losing the card's [State] (same [Element],
/// same position in the tree).
Future<UserPreferences> _pumpCard(
  WidgetTester tester,
  String theme,
  List<AppNewsItem> news, {
  double? textScaler,
  ValueListenable<bool>? offstage,
}) async {
  tester.view.physicalSize = const Size(1080, 2424);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);

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

  final Widget cardWidget = ScanNewsCard(news: news);
  final double? scaler = textScaler;
  final Widget scaled = scaler == null
      ? cardWidget
      : Builder(
          builder: (BuildContext context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scaler)),
            child: cardWidget,
          ),
        );

  final Widget card = Provider<ScanBottomCardDensity>.value(
    value: ScanBottomCardDensity.dense,
    child: SingleChildScrollView(child: scaled),
  );

  final Widget body = offstage == null
      ? card
      : ValueListenableBuilder<bool>(
          valueListenable: offstage,
          builder: (BuildContext context, bool hidden, Widget? child) {
            return Offstage(offstage: hidden, child: child);
          },
          child: card,
        );

  await tester.pumpWidget(
    MockSmoothApp(
      userPreferences,
      UserManagementProvider(),
      productPreferences,
      ThemeProvider(userPreferences),
      TextContrastProvider(userPreferences),
      ColorProvider(userPreferences),
      body,
      localDatabase: MockLocalDatabase(),
    ),
  );
  await tester.pump();

  return userPreferences;
}

// The card title renders via `AutoSizeText`, a custom `LeafRenderObjectWidget`
// with no `Text`/`RichText` descendant, so `find.text()` cannot see it.
Finder _titleFinder(String title) => find.byWidgetPredicate(
  (Widget widget) => widget is AutoSizeText && widget.text == title,
);

List<Map<String, String>> _eventsNamed(String name) => MatomoTracker
    .instance
    .queue
    .where((Map<String, String> event) => event['e_n'] == name)
    .toList();

void main() {
  // `setMockInitialValues` resets the `SharedPreferences` completer, so calling
  // it per test would hand `setUp` a different instance from the memoized one
  // `UserPreferences` holds - and the per-test cleanup below would clear the
  // wrong store. It belongs here, once, before anything reads a preference.
  setUpAll(() async {
    SharedPreferences.setMockInitialValues(mockSharedPreferences());
    await mockMatomo();
    final UserPreferences bootstrapPreferences =
        await UserPreferences.getUserPreferences();
    await ProductQuery.setCountry(bootstrapPreferences, 'fr');
  });

  setUp(() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_tagDisplayed, <String>[]);
    await prefs.setStringList(_tagClicked, <String>[]);

    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    MatomoTracker.instance.dropActions();
  });

  // No `forget()` in `tearDown`: the widget does it in `dispose()`, which is
  // what keeps a remounted card from inheriting a stale visibility entry.

  group('ScanNewsCard with campaign figures', () {
    for (final String theme in <String>['Light', 'Dark', 'AMOLED']) {
      testWidgets(theme, (WidgetTester tester) async {
        await _pumpCard(tester, theme, <AppNewsItem>[
          _newsItem(raised: 44059.47, goal: 170000.0, currency: 'EUR'),
        ]);

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
        await _pumpCard(tester, theme, <AppNewsItem>[_newsItem()]);

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
        await _pumpCard(tester, 'Light', <AppNewsItem>[
          _newsItem(raised: 44059.47, goal: 170000.0, currency: 'EUR'),
        ], textScaler: scaler);

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
    await _pumpCard(tester, 'Light', <AppNewsItem>[
      _newsItem(
        raised: 44059.47,
        goal: 170000.0,
        currency: 'EUR',
        endDate: DateTime(DateTime.now().year + 2, 1, 31),
      ),
    ]);

    expect(find.textContaining('short'), findsOneWidget);
    expect(find.textContaining('left'), findsNothing);
  });

  testWidgets('The feed style drives the meter colours', (
    WidgetTester tester,
  ) async {
    const Color messageTextColor = Color(0xFFEEEEEE);
    const Color titleIndicatorColor = Color(0xFF00FF00);

    await _pumpCard(tester, 'Light', <AppNewsItem>[
      _newsItem(
        raised: 44059.47,
        goal: 170000.0,
        currency: 'EUR',
        style: const AppNewsStyle(
          messageTextColor: messageTextColor,
          titleIndicatorColor: titleIndicatorColor,
        ),
      ),
    ]);

    final LinearProgressIndicator bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );

    expect(bar.color, titleIndicatorColor);
    expect(bar.backgroundColor, messageTextColor.withValues(alpha: 0.2));
    expect(bar.semanticsValue, '26');
  });

  testWidgets('impression fires on the first visible frame', (
    WidgetTester tester,
  ) async {
    final UserPreferences prefs = await _pumpCard(
      tester,
      'Light',
      <AppNewsItem>[_item0, _item1],
    );

    expect(prefs.taglineFeedDisplayedNews, <String>[_item0.id]);
    final List<Map<String, String>> events = _eventsNamed(
      'taglineNewsDisplayed',
    );
    expect(events, hasLength(1));
    expect(events.single['e_a'], _item0.id);
  });

  testWidgets('tap marks and tracks the click without delaying the launch', (
    WidgetTester tester,
  ) async {
    final UserPreferences prefs = await _pumpCard(
      tester,
      'Light',
      <AppNewsItem>[_item0, _item1],
    );

    await tester.tap(find.byType(InkWell));
    await tester.pump();

    expect(prefs.taglineFeedClickedNews, <String>[_item0.id]);
    expect(prefs.taglineFeedDisplayedNews, isNot(contains(_item0.id)));
    final List<Map<String, String>> events = _eventsNamed('taglineNewsClicked');
    expect(events, hasLength(1));
    expect(events.single['e_a'], _item0.id);
  });

  testWidgets('a second tap on the same item tracks only one click', (
    WidgetTester tester,
  ) async {
    await _pumpCard(tester, 'Light', <AppNewsItem>[_item0, _item1]);

    await tester.tap(find.byType(InkWell));
    await tester.pump();
    await tester.tap(find.byType(InkWell));
    await tester.pump();

    expect(_eventsNamed('taglineNewsClicked'), hasLength(1));
  });

  testWidgets('an impression does not demote an already-clicked item', (
    WidgetTester tester,
  ) async {
    final UserPreferences prefs = await _pumpCard(
      tester,
      'Light',
      <AppNewsItem>[_item0, _item1],
    );
    await tester.tap(find.byType(InkWell));
    await tester.pump();
    expect(prefs.taglineFeedClickedNews, <String>[_item0.id]);

    // A brand new card instance, i.e. the next app launch: its de-dup set is
    // empty, so the impression fires again on an id that is already clicked.
    await tester.pumpWidget(const SizedBox());
    MatomoTracker.instance.dropActions();
    await _pumpCard(tester, 'Light', <AppNewsItem>[_item0, _item1]);

    expect(prefs.taglineFeedClickedNews, <String>[_item0.id]);
    expect(prefs.taglineFeedDisplayedNews, isEmpty);
    expect(_eventsNamed('taglineNewsDisplayed'), hasLength(1));
  });

  testWidgets('rotation repaints after 30 minutes (setState regression)', (
    WidgetTester tester,
  ) async {
    await _pumpCard(tester, 'Light', <AppNewsItem>[_item0, _item1]);

    await tester.pump(const Duration(minutes: 31));

    expect(_titleFinder(_item1.title), findsOneWidget);
  });

  testWidgets('rotation marks the new item as displayed', (
    WidgetTester tester,
  ) async {
    final UserPreferences prefs = await _pumpCard(
      tester,
      'Light',
      <AppNewsItem>[_item0, _item1],
    );

    await tester.pump(const Duration(minutes: 31));

    expect(
      prefs.taglineFeedDisplayedNews,
      containsAll(<String>[_item0.id, _item1.id]),
    );
    final List<Map<String, String>> events = _eventsNamed(
      'taglineNewsDisplayed',
    );
    expect(events, hasLength(2));
    expect(events.last['e_a'], _item1.id);
  });

  testWidgets('impression is de-duplicated across a hide/show cycle', (
    WidgetTester tester,
  ) async {
    final ValueNotifier<bool> hidden = ValueNotifier<bool>(false);
    addTearDown(hidden.dispose);

    final UserPreferences prefs = await _pumpCard(
      tester,
      'Light',
      <AppNewsItem>[_item0, _item1],
      offstage: hidden,
    );

    hidden.value = true;
    await tester.pump();
    hidden.value = false;
    await tester.pump();

    expect(prefs.taglineFeedDisplayedNews, <String>[_item0.id]);
    expect(_eventsNamed('taglineNewsDisplayed'), hasLength(1));
  });

  testWidgets('single-item feed wraps without a second impression', (
    WidgetTester tester,
  ) async {
    final UserPreferences prefs = await _pumpCard(
      tester,
      'Light',
      <AppNewsItem>[_item0],
    );

    await tester.pump(const Duration(minutes: 31));

    expect(prefs.taglineFeedDisplayedNews, <String>[_item0.id]);
    expect(_eventsNamed('taglineNewsDisplayed'), hasLength(1));
  });

  testWidgets('an off-screen build does not fire an impression', (
    WidgetTester tester,
  ) async {
    final ValueNotifier<bool> hidden = ValueNotifier<bool>(true);
    addTearDown(hidden.dispose);

    final UserPreferences prefs = await _pumpCard(
      tester,
      'Light',
      <AppNewsItem>[_item0],
      offstage: hidden,
    );

    expect(prefs.taglineFeedDisplayedNews, isEmpty);
    expect(_eventsNamed('taglineNewsDisplayed'), isEmpty);
  });

  testWidgets('does not fire or throw after being disposed mid-timer', (
    WidgetTester tester,
  ) async {
    await _pumpCard(tester, 'Light', <AppNewsItem>[_item0, _item1]);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 31));

    expect(tester.takeException(), isNull);
  });

  group('renders correctly in every theme', () {
    for (final String theme in <String>['Light', 'Dark', 'AMOLED']) {
      testWidgets(theme, (WidgetTester tester) async {
        await _pumpCard(tester, theme, <AppNewsItem>[_item0, _item1]);

        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

        // No `didExceedMaxLines` probe: the title is an `AutoSizeText`, a leaf
        // render object that shrinks its font to fit and exposes no such flag,
        // and the message renders at `maxLines: 500`. So the two pumps below
        // are the coverage - a layout overflow at either scale is reported as
        // an exception during paint and fails the test.
        for (final double textScale in <double>[1.3, 2.0]) {
          tester.platformDispatcher.textScaleFactorTestValue = textScale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await tester.pump();
        }
      });
    }
  });
}
