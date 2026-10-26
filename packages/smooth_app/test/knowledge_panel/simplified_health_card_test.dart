import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_expanded_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_group_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/product/add_nutrition_button.dart';
import 'package:smooth_app/pages/product/add_ocr_button.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/table/scrollable_table_widget.dart';

import '../tests_utils/mocks.dart';

/// The "Health" tab of food products is built from the simplified health card,
/// which has neither the nutrition facts table nor the ingredients.
///
/// cf. https://github.com/openfoodfacts/smooth-app/issues/7728
void main() {
  late UserPreferences userPreferences;
  late ProductPreferences productPreferences;
  late ThemeProvider themeProvider;
  late ColorProvider colorProvider;
  late TextContrastProvider textContrastProvider;

  const String simplifiedHealthCardId = 'health_card_simplified';
  const String nutritionTableId = KnowledgePanelCard.PANEL_NUTRITION_TABLE_ID;
  const String ingredientsId = KnowledgePanelCard.PANEL_INGREDIENTS_ID;
  final String expandNutritionFlag = KnowledgePanelCard.getExpandFlagTag(
    nutritionTableId,
  );
  final String expandIngredientsFlag = KnowledgePanelCard.getExpandFlagTag(
    ingredientsId,
  );

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
    themeProvider = ThemeProvider(userPreferences);
    colorProvider = ColorProvider(userPreferences);
    textContrastProvider = TextContrastProvider(userPreferences);
  });

  setUp(() async {
    await userPreferences.setFlag(expandNutritionFlag, null);
    await userPreferences.setFlag(expandIngredientsFlag, null);
    await userPreferences.setFlag(
      UserPreferencesDevMode.userPreferencesFlagEditIngredients,
      null,
    );
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

  KnowledgePanelElement panelElement(final String panelId) =>
      KnowledgePanelElement(
        elementType: KnowledgePanelElementType.PANEL,
        panelElement: KnowledgePanelPanelIdElement(panelId: panelId),
      );

  KnowledgePanelElement panelGroupElement(final List<String> panelIds) =>
      KnowledgePanelElement(
        elementType: KnowledgePanelElementType.PANEL_GROUP,
        panelGroupElement: KnowledgePanelPanelGroupElement(
          title: null,
          panelIds: panelIds,
        ),
      );

  KnowledgePanel textPanel(final String title) => KnowledgePanel(
    titleElement: TitleElement(title: title),
    elements: <KnowledgePanelElement>[
      KnowledgePanelElement(
        elementType: KnowledgePanelElementType.TEXT,
        textElement: KnowledgePanelTextElement(html: '$title (details)'),
      ),
    ],
  );

  const KnowledgePanel nutritionTablePanel = KnowledgePanel(
    titleElement: TitleElement(title: 'Nutrition facts'),
    elements: <KnowledgePanelElement>[
      KnowledgePanelElement(
        elementType: KnowledgePanelElementType.TABLE,
        tableElement: KnowledgePanelTableElement(
          id: nutritionTableId,
          title: null,
          columns: <KnowledgePanelTableColumn>[
            KnowledgePanelTableColumn(
              text: 'Nutrient',
              type: KnowledgePanelColumnType.TEXT,
            ),
            KnowledgePanelTableColumn(
              text: 'As sold for 100 g',
              type: KnowledgePanelColumnType.TEXT,
            ),
          ],
          rows: <KnowledgePanelTableRowElement>[
            KnowledgePanelTableRowElement(
              values: <KnowledgePanelTableCell>[
                KnowledgePanelTableCell(text: 'Sugars'),
                KnowledgePanelTableCell(text: '56.3 g'),
              ],
            ),
          ],
        ),
      ),
    ],
  );

  /// Mimics the panels the server sends for a food product (e.g. 3017620422003).
  Product buildProduct({
    final List<KnowledgePanelElement>? healthCardElements,
    final bool withNutritionTable = true,
    final bool withIngredients = true,
    final List<String>? statesTags,
  }) => Product(barcode: '3017620422003')
    ..statesTags = statesTags
    ..knowledgePanels = KnowledgePanels(
      panelIdToPanelMap: <String, KnowledgePanel>{
        simplifiedHealthCardId: KnowledgePanel(
          titleElement: const TitleElement(title: 'Health'),
          topics: const <String>['health'],
          elements:
              healthCardElements ??
              <KnowledgePanelElement>[
                panelGroupElement(<String>[
                  'nutriscore_2023',
                  'nutrient_levels',
                ]),
                panelGroupElement(<String>['nova', 'additives']),
              ],
        ),
        'environment_card_simplified': KnowledgePanel(
          titleElement: const TitleElement(title: 'Environment'),
          topics: const <String>['environment'],
          elements: <KnowledgePanelElement>[
            panelGroupElement(<String>['environmental_score']),
          ],
        ),
        'nutriscore_2023': textPanel('Nutri-Score E'),
        'nutrient_levels': textPanel('Nutrient levels'),
        'nova': textPanel('Processed foods'),
        'environmental_score': textPanel('Green-Score'),
        if (withNutritionTable) nutritionTableId: nutritionTablePanel,
        if (withIngredients) ingredientsId: textPanel('2 ingredients'),
      },
    );

  /// Displays the [panelId] card the way the product page tabs do.
  Future<List<Widget>> pumpCard(
    final WidgetTester tester,
    final Product product, {
    final String panelId = simplifiedHealthCardId,
  }) async {
    late List<Widget> children;
    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (final BuildContext context) {
            children = KnowledgePanelsBuilder.getChildren(
              context,
              panelElement: panelElement(panelId),
              product: product,
              onboardingMode: false,
              simplified: true,
            );
            return ListView(children: children);
          },
        ),
      ),
    );
    await tester.pump();
    return children;
  }

  List<List<String>> getPanelGroups(final List<Widget> children) =>
      <List<String>>[
        for (final KnowledgePanelGroupCard card
            in children.whereType<KnowledgePanelGroupCard>())
          card.groupElement.panelIds,
      ];

  Finder findCard(final String panelId) => find.byWidgetPredicate(
    (final Widget widget) =>
        widget is KnowledgePanelCard && widget.panelId == panelId,
  );

  Finder findExpandedCard(final String panelId) => find.byWidgetPredicate(
    (final Widget widget) =>
        widget is KnowledgePanelExpandedCard && widget.panelId == panelId,
  );

  group('Simplified health card', () {
    testWidgets('has the nutrition facts table and the ingredients, '
        'right after the nutrient levels', (WidgetTester tester) async {
      final List<Widget> children = await pumpCard(tester, buildProduct());

      expect(getPanelGroups(children), <List<String>>[
        <String>['nutriscore_2023', 'nutrient_levels'],
        <String>[nutritionTableId, ingredientsId],
        <String>['nova', 'additives'],
      ]);
      expect(find.text('Nutrition facts'), findsOneWidget);
      expect(find.text('2 ingredients'), findsOneWidget);
    });

    testWidgets('only has the panels that exist', (WidgetTester tester) async {
      List<Widget> children = await pumpCard(
        tester,
        buildProduct(withNutritionTable: false),
      );
      expect(getPanelGroups(children), <List<String>>[
        <String>['nutriscore_2023', 'nutrient_levels'],
        <String>[ingredientsId],
        <String>['nova', 'additives'],
      ]);

      children = await pumpCard(
        tester,
        buildProduct(withNutritionTable: false, withIngredients: false),
      );
      expect(getPanelGroups(children), <List<String>>[
        <String>['nutriscore_2023', 'nutrient_levels'],
        <String>['nova', 'additives'],
      ]);
    });

    testWidgets('does not duplicate a panel the server already put there', (
      WidgetTester tester,
    ) async {
      final List<Widget> children = await pumpCard(
        tester,
        buildProduct(
          healthCardElements: <KnowledgePanelElement>[
            panelGroupElement(<String>['nutriscore_2023', 'nutrient_levels']),
            panelElement(nutritionTableId),
            panelGroupElement(<String>['nova', 'additives']),
          ],
        ),
      );

      expect(getPanelGroups(children), <List<String>>[
        <String>['nutriscore_2023', 'nutrient_levels'],
        <String>[ingredientsId],
        <String>['nova', 'additives'],
      ]);
      expect(findCard(nutritionTableId), findsOneWidget);
    });

    testWidgets('looks for duplicates in expanded panels only', (
      WidgetTester tester,
    ) async {
      final Product product = buildProduct(
        healthCardElements: <KnowledgePanelElement>[
          panelGroupElement(<String>['nutriscore_2023', 'nutrient_levels']),
          panelElement('expanded'),
          panelElement('collapsed'),
          panelGroupElement(<String>['nova', 'additives']),
        ],
      );
      final Map<String, KnowledgePanel> panels =
          product.knowledgePanels!.panelIdToPanelMap;
      panels['expanded'] = KnowledgePanel(
        expanded: true,
        elements: <KnowledgePanelElement>[panelElement(nutritionTableId)],
      );
      panels['collapsed'] = KnowledgePanel(
        titleElement: const TitleElement(title: 'Collapsed'),
        elements: <KnowledgePanelElement>[panelElement(ingredientsId)],
      );
      final List<Widget> children = await pumpCard(tester, product);

      expect(getPanelGroups(children), <List<String>>[
        <String>['nutriscore_2023', 'nutrient_levels'],
        <String>[ingredientsId],
        <String>['nova', 'additives'],
      ]);
      expect(findCard(nutritionTableId), findsOneWidget);
      expect(findCard(ingredientsId), findsOneWidget);
    });

    testWidgets('has the extra panels at the end without nutrient levels', (
      WidgetTester tester,
    ) async {
      final List<Widget> children = await pumpCard(
        tester,
        buildProduct(
          healthCardElements: <KnowledgePanelElement>[
            panelGroupElement(<String>['nova', 'additives']),
          ],
        ),
      );

      expect(getPanelGroups(children), <List<String>>[
        <String>['nova', 'additives'],
        <String>[nutritionTableId, ingredientsId],
      ]);
    });

    testWidgets('keeps the other cards as they are', (
      WidgetTester tester,
    ) async {
      final List<Widget> children = await pumpCard(
        tester,
        buildProduct(),
        panelId: 'environment_card_simplified',
      );

      expect(getPanelGroups(children), <List<String>>[
        <String>['environmental_score'],
      ]);
      expect(findCard(nutritionTableId), findsNothing);
      expect(findCard(ingredientsId), findsNothing);
    });

    testWidgets('has the "add nutrition facts" button when relevant', (
      WidgetTester tester,
    ) async {
      await pumpCard(tester, buildProduct());
      expect(find.byType(AddNutritionButton), findsNothing);

      await pumpCard(
        tester,
        buildProduct(
          statesTags: <String>[
            ProductState.NUTRITION_FACTS_COMPLETED.toBeCompletedTag,
          ],
        ),
      );
      expect(find.byType(AddNutritionButton), findsOneWidget);
    });

    testWidgets('has the "add ingredients" button in dev mode', (
      WidgetTester tester,
    ) async {
      await pumpCard(tester, buildProduct());
      expect(find.byType(AddOcrButton), findsNothing);

      await userPreferences.setFlag(
        UserPreferencesDevMode.userPreferencesFlagEditIngredients,
        true,
      );
      await pumpCard(tester, buildProduct());
      expect(find.byType(AddOcrButton), findsOneWidget);
    });
  });

  group('"Expand" preferences on the simplified health card', () {
    testWidgets('without them, the nutrition facts table is one tap away', (
      WidgetTester tester,
    ) async {
      await pumpCard(tester, buildProduct());

      expect(findExpandedCard(nutritionTableId), findsNothing);
      expect(findExpandedCard(ingredientsId), findsNothing);
      expect(find.byType(ScrollableTableWidget), findsNothing);
      final InkWell row = tester.widget<InkWell>(
        find
            .descendant(
              of: findCard(nutritionTableId),
              matching: find.byType(InkWell),
            )
            .first,
      );
      expect(row.onTap, isNotNull);
    });

    testWidgets('"expand nutrition facts" displays the table on the tab', (
      WidgetTester tester,
    ) async {
      await userPreferences.setFlag(expandNutritionFlag, true);
      await pumpCard(tester, buildProduct());

      expect(findExpandedCard(nutritionTableId), findsOneWidget);
      expect(find.byType(ScrollableTableWidget), findsOneWidget);
      expect(findExpandedCard(ingredientsId), findsNothing);
    });

    testWidgets('"expand ingredients" displays the ingredients on the tab', (
      WidgetTester tester,
    ) async {
      await userPreferences.setFlag(expandIngredientsFlag, true);
      await pumpCard(tester, buildProduct());

      expect(findExpandedCard(ingredientsId), findsOneWidget);
      expect(findExpandedCard(nutritionTableId), findsNothing);
    });
  });

  group('"Expand" preferences on a single card', () {
    Future<void> pumpPanel(
      final WidgetTester tester,
      final Product product,
      final String panelId,
    ) async {
      await tester.pumpWidget(
        wrap(
          KnowledgePanelCard(
            panelId: panelId,
            product: product,
            isClickable: true,
            simplified: false,
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('only apply to their own panel, not to a namesake', (
      WidgetTester tester,
    ) async {
      await userPreferences.setFlag(expandNutritionFlag, true);
      final Product product = buildProduct()
        ..knowledgePanels!.panelIdToPanelMap['namesake'] = textPanel(
          'Nutrition facts',
        );

      await pumpPanel(tester, product, 'namesake');
      expect(findExpandedCard('namesake'), findsNothing);

      await pumpPanel(tester, product, nutritionTableId);
      expect(findExpandedCard(nutritionTableId), findsOneWidget);
    });

    testWidgets('do not apply to an untitled panel when theirs is missing', (
      WidgetTester tester,
    ) async {
      await userPreferences.setFlag(expandIngredientsFlag, true);
      final Product product = buildProduct(withIngredients: false)
        ..knowledgePanels!.panelIdToPanelMap['untitled'] = const KnowledgePanel(
          titleElement: TitleElement(title: null),
          elements: <KnowledgePanelElement>[
            KnowledgePanelElement(
              elementType: KnowledgePanelElementType.TEXT,
              textElement: KnowledgePanelTextElement(html: 'whatever'),
            ),
          ],
        );

      await pumpPanel(tester, product, 'untitled');
      expect(findExpandedCard('untitled'), findsNothing);
    });
  });
}
