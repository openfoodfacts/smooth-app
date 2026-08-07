import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_square/knowledge_panel_square_item.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../tests_utils/mocks.dart';

void main() {
  late UserPreferences userPreferences;
  late ProductPreferences productPreferences;
  late ThemeProvider themeProvider;
  late ColorProvider colorProvider;
  late TextContrastProvider textContrastProvider;

  setUpAll(() async {
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
    // trackCustomEvent and _reformatValue both read ProductQuery's `late`
    // country/language globals - never set in a fresh test isolate.
    await ProductQuery.setCountry(userPreferences, 'fr');
    themeProvider = ThemeProvider(userPreferences);
    colorProvider = ColorProvider(userPreferences);
    textContrastProvider = TextContrastProvider(userPreferences);
    await mockMatomo();
  });

  setUp(() {
    MatomoTracker.instance.dropActions();
  });

  Widget wrap(Widget child) => MockSmoothApp(
    userPreferences,
    UserManagementProvider(),
    productPreferences,
    themeProvider,
    textContrastProvider,
    colorProvider,
    Material(child: child),
  );

  Iterable<Map<String, String>> knowledgePanelOpenEvents() =>
      MatomoTracker.instance.queue.where(
        (Map<String, String> event) => event['e_n'] == 'knowledgePanelOpen',
      );

  Product buildProductWithPanels() =>
      Product(barcode: '0000000000000')
        ..knowledgePanels = const KnowledgePanels(
          panelIdToPanelMap: <String, KnowledgePanel>{
            'nutriscore': KnowledgePanel(
              titleElement: TitleElement(title: 'Nutri-Score'),
              elements: <KnowledgePanelElement>[
                KnowledgePanelElement(
                  elementType: KnowledgePanelElementType.TEXT,
                  textElement: KnowledgePanelTextElement(html: 'whatever'),
                ),
              ],
            ),
            // No `elements` -> KnowledgePanelsBuilder.hasSomethingToDisplay
            // returns false -> `improvedIsClickable` false -> onTap is null.
            'unclickable': KnowledgePanel(
              titleElement: TitleElement(title: 'Unclickable'),
            ),
          },
        );

  group('KnowledgePanelCard - card -> full page (route 1)', () {
    testWidgets('T4 - unclickable card has a null onTap and fires nothing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          KnowledgePanelCard(
            panelId: 'unclickable',
            product: buildProductWithPanels(),
            isClickable: true,
            simplified: false,
          ),
        ),
      );
      await tester.pump();

      final InkWell inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNull);
      expect(knowledgePanelOpenEvents(), isEmpty);
    });

    testWidgets('T4 - a clickable card fires nothing before it is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          KnowledgePanelCard(
            panelId: 'nutriscore',
            product: buildProductWithPanels(),
            isClickable: true,
            simplified: false,
          ),
        ),
      );
      await tester.pump();

      final InkWell inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNotNull);
      expect(knowledgePanelOpenEvents(), isEmpty);
    });

    testWidgets('T5 - tapping a clickable card fires the panel id', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          KnowledgePanelCard(
            panelId: 'nutriscore',
            product: buildProductWithPanels(),
            isClickable: true,
            simplified: false,
          ),
        ),
      );
      await tester.pump();

      // Invoked directly, never pumped: pushing the real KnowledgePanelPage
      // needs a `LocalDatabase.upToDate` that the shared mock does not stub.
      tester.widget<InkWell>(find.byType(InkWell)).onTap!();

      final Map<String, String> event = knowledgePanelOpenEvents().single;
      expect(event['e_a'], 'nutriscore');
    });
  });

  group('KnowledgePanelSquareItem - square -> modal sheet (route 2)', () {
    const KnowledgePanel panel = KnowledgePanel(
      titleElement: TitleElement(title: 'Nutri-Score', name: 'Nutri-Score'),
    );

    Widget wrapSquare(String? panelId) => wrap(
      Provider<Product>.value(
        value: Product(barcode: '0000000000000'),
        child: Row(
          children: <Widget>[
            KnowledgePanelSquareItem(panelId: panelId, panel: panel),
          ],
        ),
      ),
    );

    testWidgets('T6 - no panel id means a null onTap and fires nothing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrapSquare(null));
      await tester.pump();

      final InkWell inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNull);
      expect(knowledgePanelOpenEvents(), isEmpty);
    });

    testWidgets('T6 - tapping a square fires its panel id', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrapSquare('nutriscore'));
      await tester.pump();

      // Invoked directly, never pumped: the modal sheet route is not ours
      // to build in this test.
      tester.widget<InkWell>(find.byType(InkWell)).onTap!();

      final Map<String, String> event = knowledgePanelOpenEvents().single;
      expect(event['e_a'], 'nutriscore');
    });
  });

  test(
    'T7 - KnowledgePanelPage keeps its existing screen-view actionName '
    '(source-level check, no navigation - the page is untouched by this PR)',
    () {
      final String source = File(
        'lib/knowledge_panel/knowledge_panels/knowledge_panel_page.dart',
      ).readAsStringSync();
      expect(source.contains("'Opened full knowledge panel page'"), isTrue);
    },
  );
}
