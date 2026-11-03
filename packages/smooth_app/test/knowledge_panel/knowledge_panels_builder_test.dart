import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_expanded_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';

void main() {
  group('KnowledgePanelsBuilder tests', () {
    test(
      'getKnowledgePanel matches exact and with hyphen/underscore fallback',
      () {
        final Map<String, KnowledgePanel> panelMap = <String, KnowledgePanel>{
          'nutrient_level_saturated-fat': const KnowledgePanel(
            titleElement: TitleElement(title: 'Saturated fat'),
          ),
          'forest_footprint': const KnowledgePanel(
            titleElement: TitleElement(title: 'Forest footprint'),
          ),
        };

        final Product product = Product.fromJson(<String, dynamic>{
          'knowledge_panels': panelMap.map(
            (String k, KnowledgePanel v) =>
                MapEntry<String, dynamic>(k, v.toJson()),
          ),
        });

        // Exact match
        expect(
          KnowledgePanelsBuilder.getKnowledgePanel(
            product,
            'nutrient_level_saturated-fat',
          ),
          isNotNull,
        );
        expect(
          KnowledgePanelsBuilder.getKnowledgePanel(product, 'forest_footprint'),
          isNotNull,
        );

        // Underscore looked up when panel has hyphens
        expect(
          KnowledgePanelsBuilder.getKnowledgePanel(
            product,
            'nutrient_level_saturated_fat',
          ),
          isNotNull,
        );

        // Hyphen looked up when panel has underscores
        expect(
          KnowledgePanelsBuilder.getKnowledgePanel(product, 'forest-footprint'),
          isNotNull,
        );

        // Non-existent panel returns null
        expect(
          KnowledgePanelsBuilder.getKnowledgePanel(
            product,
            'non_existent_panel',
          ),
          isNull,
        );
      },
    );

    test(
      'hasSomethingToDisplay returns false safely when panel is missing',
      () {
        final Product product = Product();

        expect(
          KnowledgePanelsBuilder.hasSomethingToDisplay(
            product,
            'missing_panel_id',
          ),
          isFalse,
        );
      },
    );

    testWidgets(
      'KnowledgePanelExpandedCard renders EMPTY_WIDGET when panel is missing',
      (WidgetTester tester) async {
        final Product product = Product();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: KnowledgePanelExpandedCard(
                panelId: 'missing_panel_id',
                product: product,
                isInitiallyExpanded: true,
                isClickable: false,
                simplified: false,
              ),
            ),
          ),
        );

        expect(find.byType(KnowledgePanelExpandedCard), findsOneWidget);
        expect(find.byWidget(EMPTY_WIDGET), findsOneWidget);
      },
    );
  });
}
