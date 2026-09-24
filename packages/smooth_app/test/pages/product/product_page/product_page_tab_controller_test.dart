import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/pages/product/product_page/header/product_page_tabs.dart';
import 'package:smooth_app/pages/product/product_page/product_page_tab_controller.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../../../tests_utils/mocks.dart';

/// The hardcoded Prices/Folksonomy tabs eagerly kick off a `package:http`
/// GET request for their badge count as soon as
/// `ProductPageTabsGenerator.getTabs()` runs (`_getPricesTotal`/
/// `_getFolksonomyTotal`), independently of whether that badge is ever
/// rendered. The shared `MockHttpOverrides` (`tests_utils/mocks.dart`) only
/// stubs `HttpClient.getUrl` and throws for anything else, which
/// `package:http`'s `IOClient` (it calls `openUrl`) turns into a rejected
/// Future - and since these badge futures are otherwise unobserved by
/// anything this test awaits, a rejection surfaces as an unrelated
/// unhandled-async-error test failure. Returning a Future that never
/// completes avoids that without ever needing a real socket.
class _StallingHttpClient extends Mock implements HttpClient {
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) =>
      Completer<HttpClientRequest>().future;

  @override
  Future<HttpClientRequest> getUrl(Uri url) =>
      Completer<HttpClientRequest>().future;
}

class _StallingHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? _) => _StallingHttpClient();
}

/// Regression coverage for https://github.com/openfoodfacts/smooth-app/issues/7698.
///
/// `Product` has no value equality (it's defined in the external
/// `openfoodfacts` package), and `ProductPageState` hands
/// `ProductPageTabController` a brand-new `Product` *instance* on
/// essentially every rebuild (`UpToDateProductProvider.copy()`), even when
/// nothing about the product actually changed. `_ProductPageTabControllerState`
/// used to treat that identity change alone as a reason to dispose and
/// recreate its `TabController`. Flutter's `TabBarView` reacts to a new
/// `TabController` identity by jumping back to the committed tab, which
/// aborts an in-progress swipe gesture.
///
/// These tests drive the real `ProductPageTabController` and a real
/// `TabBarView`; tab *content* is stubbed with plain `Text` widgets, since
/// the investigation directly ruled out tab content as a factor in this
/// mechanism.
void main() {
  late UserPreferences userPreferences;
  late ProductPreferences productPreferences;
  late ThemeProvider themeProvider;
  late ColorProvider colorProvider;
  late TextContrastProvider textContrastProvider;
  HttpOverrides? priorHttpOverrides;

  const String barcode = '1234567890123';

  setUp(() async {
    priorHttpOverrides = HttpOverrides.current;
    HttpOverrides.global = _StallingHttpOverrides();

    SharedPreferences.setMockInitialValues(mockSharedPreferences());
    userPreferences = await UserPreferences.getUserPreferences();
    productPreferences = ProductPreferences(
      ProductPreferencesSelection(
        setImportance: userPreferences.setImportance,
        getImportance: userPreferences.getImportance,
        notify: () => productPreferences.notifyListeners(),
      ),
    );
    await productPreferences.init(PlatformAssetBundle());
    await userPreferences.init(productPreferences);
    // The hardcoded tabs' badge fetches (`_getPricesTotal`/
    // `_getFolksonomyTotal`) read `ProductQuery`'s late-initialized URI
    // helpers and need a user agent set; normally done once at app startup
    // (`main.dart`).
    OpenFoodAPIConfiguration.userAgent = UserAgent(name: 'smooth-app-test');
    ProductQuery.setQueryType(userPreferences);
    themeProvider = ThemeProvider(userPreferences);
    colorProvider = ColorProvider(userPreferences);
    textContrastProvider = TextContrastProvider(userPreferences);
  });

  tearDown(() {
    HttpOverrides.global = priorHttpOverrides;
  });

  Product basicProduct() => Product(barcode: barcode);

  /// Returns a data-identical but distinct `Product` *instance* - exactly
  /// what `UpToDateProductProvider.copy()` produces on every
  /// `ProductPageState` rebuild.
  Product dataIdenticalCopy(Product source) => Product.fromJson(
    jsonDecode(jsonEncode(source.toJson())) as Map<String, dynamic>,
  );

  /// A product exposing one extra knowledge-panel-driven tab ("environment"),
  /// on top of the 3 hardcoded ones - used to force a genuine tab-structure
  /// change.
  Product productWithExtraTab() =>
      Product(barcode: barcode)
        ..knowledgePanels = const KnowledgePanels(
          panelIdToPanelMap: <String, KnowledgePanel>{
            'simplified_root': KnowledgePanel(
              elements: <KnowledgePanelElement>[
                KnowledgePanelElement(
                  elementType: KnowledgePanelElementType.PANEL,
                  panelElement: KnowledgePanelPanelIdElement(
                    panelId: 'environment_card',
                  ),
                ),
              ],
            ),
            'environment_card': KnowledgePanel(
              titleElement: TitleElement(title: 'Environment'),
            ),
          },
        );

  /// Builds the smallest realistic harness around the real
  /// `ProductPageTabController` and a real `TabBarView`.
  Widget harness({
    required Product product,
    required void Function(TabController) onControllerBuilt,
    required void Function(List<ProductPageTab>) onTabsBuilt,
  }) {
    return MockSmoothApp(
      userPreferences,
      UserManagementProvider(),
      productPreferences,
      themeProvider,
      textContrastProvider,
      colorProvider,
      Scaffold(
        body: ProductPageTabController(
          product: product,
          childBuilder:
              (List<ProductPageTab> tabs, TabController tabController) {
                onControllerBuilt(tabController);
                onTabsBuilt(tabs);
                return TabBarView(
                  controller: tabController,
                  children: tabs
                      .map(
                        (ProductPageTab tab) => Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(tab.id),
                              // Rendering the badge (rather than discarding
                              // it) attaches an error listener to its
                              // `future:` - the same badge future that
                              // `getTabs()` always kicks off eagerly - so a
                              // rejected mocked network call doesn't surface
                              // as an unrelated unhandled-async-error test
                              // failure.
                              if (tab.suffix != null) tab.suffix!,
                            ],
                          ),
                        ),
                      )
                      .toList(growable: false),
                );
              },
        ),
      ),
    );
  }

  /// Performs a slow, steady drag using the same low-level event-synthesis
  /// technique as `WidgetController.flingFrom` (a `TestPointer` driven via
  /// `sendEventToBinding` with explicit synthetic timestamps), but pauses
  /// mid-gesture - after `pauseAtStep` of `totalSteps` - to let the caller
  /// inject a rebuild while the drag is still genuinely in flight, before
  /// resuming and releasing.
  Future<void> dragInStages(
    WidgetTester tester,
    Offset startLocation,
    Offset totalOffset, {
    required int totalSteps,
    required int pauseAtStep,
    required Future<void> Function() onPause,
  }) async {
    const Duration frameInterval = Duration(milliseconds: 16);
    final TestPointer pointer = TestPointer(1, PointerDeviceKind.touch);
    double timeStamp = 0;

    await tester.sendEventToBinding(
      pointer.down(
        startLocation,
        timeStamp: Duration(microseconds: timeStamp.round()),
      ),
    );

    for (int step = 1; step <= totalSteps; step++) {
      final Offset location =
          startLocation +
          Offset.lerp(Offset.zero, totalOffset, step / totalSteps)!;
      timeStamp += frameInterval.inMicroseconds;
      await tester.sendEventToBinding(
        pointer.move(
          location,
          timeStamp: Duration(microseconds: timeStamp.round()),
        ),
      );
      await tester.pump(frameInterval);

      if (step == pauseAtStep) {
        await onPause();
      }
    }

    timeStamp += frameInterval.inMicroseconds;
    await tester.sendEventToBinding(
      pointer.up(timeStamp: Duration(microseconds: timeStamp.round())),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    for (int i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  testWidgets('a Prices -> Folksonomy swipe completes even if an unrelated, '
      'data-identical Product rebuild lands mid-drag (#7698)', (
    WidgetTester tester,
  ) async {
    final Product productA = basicProduct();
    TabController? controller;
    List<ProductPageTab>? tabs;

    await tester.pumpWidget(
      harness(
        product: productA,
        onControllerBuilt: (TabController c) => controller = c,
        onTabsBuilt: (List<ProductPageTab> t) => tabs = t,
      ),
    );
    await tester.pump();

    // FOR_ME(0), PRICES(1), FOLKSONOMY(2): no knowledge panel tabs here.
    expect(tabs!.map((ProductPageTab tab) => tab.id).toList(), <String>[
      'for_me',
      'prices',
      'folksonomy',
    ]);

    // Start on Prices, via a real (uninterrupted) swipe: reaching it
    // through `TabController.animateTo(duration: Duration.zero)` leaves
    // the TabBarView's internal PageView unable to correctly track a
    // subsequent drag in this Flutter version, which would make this test
    // meaningless regardless of the fix under test.
    final Offset start = tester.getCenter(find.byType(TabBarView));
    await dragInStages(
      tester,
      start,
      const Offset(-700, 0),
      totalSteps: 20,
      pauseAtStep: -1,
      onPause: () async {},
    );
    await settle(tester);
    expect(controller!.index, 1);

    final TabController controllerBeforeDrag = controller!;

    await dragInStages(
      tester,
      start,
      const Offset(-700, 0),
      totalSteps: 20,
      pauseAtStep: 12,
      onPause: () async {
        // Inject a data-identical but different `Product` instance while
        // the drag is still active - mirrors what
        // `UpToDateProductProvider.copy()` does on every `ProductPageState`
        // rebuild.
        final Product productB = dataIdenticalCopy(productA);
        expect(identical(productA, productB), isFalse);

        await tester.pumpWidget(
          harness(
            product: productB,
            onControllerBuilt: (TabController c) => controller = c,
            onTabsBuilt: (List<ProductPageTab> t) => tabs = t,
          ),
        );
        await tester.pump();
      },
    );

    await settle(tester);

    expect(
      controller!.index,
      2,
      reason:
          'the swipe should reach Folksonomy, not snap back to Prices '
          '(controller preserved: ${identical(controllerBeforeDrag, controller)})',
    );
  });

  testWidgets('an uninterrupted swipe between tabs reaches its destination', (
    WidgetTester tester,
  ) async {
    final Product product = basicProduct();
    TabController? controller;
    List<ProductPageTab>? tabs;

    await tester.pumpWidget(
      harness(
        product: product,
        onControllerBuilt: (TabController c) => controller = c,
        onTabsBuilt: (List<ProductPageTab> t) => tabs = t,
      ),
    );
    await tester.pump();
    expect(tabs!.length, 3);

    final Offset start = tester.getCenter(find.byType(TabBarView));
    Future<void> swipeLeft() => dragInStages(
      tester,
      start,
      const Offset(-700, 0),
      totalSteps: 20,
      pauseAtStep: -1,
      onPause: () async {},
    );

    await swipeLeft();
    await settle(tester);
    expect(controller!.index, 1, reason: 'ForMe -> Prices should work');

    await swipeLeft();
    await settle(tester);
    expect(controller!.index, 2, reason: 'Prices -> Folksonomy should work');
  });

  testWidgets(
    'a genuine tab-structure change still recreates the TabController',
    (WidgetTester tester) async {
      final Product productA = basicProduct();
      TabController? controller;
      List<ProductPageTab>? tabs;

      await tester.pumpWidget(
        harness(
          product: productA,
          onControllerBuilt: (TabController c) => controller = c,
          onTabsBuilt: (List<ProductPageTab> t) => tabs = t,
        ),
      );
      await tester.pump();
      expect(tabs!.length, 3);
      final TabController originalController = controller!;

      // Move to Prices before the structure change, to check the
      // `initialIndex` fallback (unchanged from the pre-fix behavior).
      originalController.animateTo(1, duration: Duration.zero);
      await tester.pump();

      final Product productB = productWithExtraTab();
      await tester.pumpWidget(
        harness(
          product: productB,
          onControllerBuilt: (TabController c) => controller = c,
          onTabsBuilt: (List<ProductPageTab> t) => tabs = t,
        ),
      );
      await tester.pump();

      expect(tabs!.map((ProductPageTab tab) => tab.id).toList(), <String>[
        'for_me',
        'environment_card',
        'prices',
        'folksonomy',
      ]);
      expect(
        identical(originalController, controller),
        isFalse,
        reason:
            'the tab structure genuinely changed, so the TabController must '
            'be recreated',
      );
      expect(controller!.length, 4);
      // The old committed index (1) is still a valid index in the new
      // controller, so the existing initialIndex fallback keeps it.
      expect(controller!.index, 1);
    },
  );

  testWidgets(
    'the TabController is preserved but tab content stays fresh when the '
    'tab structure is unchanged',
    (WidgetTester tester) async {
      final Product productA = basicProduct();
      TabController? controller;
      List<ProductPageTab>? tabs;

      await tester.pumpWidget(
        harness(
          product: productA,
          onControllerBuilt: (TabController c) => controller = c,
          onTabsBuilt: (List<ProductPageTab> t) => tabs = t,
        ),
      );
      await tester.pump();
      final TabController originalController = controller!;
      final List<ProductPageTab> originalTabs = tabs!;

      final Product productB = dataIdenticalCopy(productA);
      await tester.pumpWidget(
        harness(
          product: productB,
          onControllerBuilt: (TabController c) => controller = c,
          onTabsBuilt: (List<ProductPageTab> t) => tabs = t,
        ),
      );
      await tester.pump();

      expect(
        identical(originalController, controller),
        isTrue,
        reason:
            'the tab structure is unchanged, so the TabController must '
            'be preserved',
      );
      expect(
        identical(originalTabs, tabs),
        isFalse,
        reason:
            'the tab list must still be recomputed so tab content (labels, '
            'badges, prefixes) stays current even though the controller is '
            'preserved',
      );
    },
  );
}
