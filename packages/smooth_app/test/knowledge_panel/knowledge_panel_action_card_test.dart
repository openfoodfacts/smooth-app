import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/html/smooth_html_widget.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_action_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/table/html_tag_remover.dart';

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
    await ProductQuery.setCountry(userPreferences, 'fr');
    themeProvider = ThemeProvider(userPreferences);
    colorProvider = ColorProvider(userPreferences);
    textContrastProvider = TextContrastProvider(userPreferences);
  });

  Widget createWidget(KnowledgePanelActionElement element, Product product) =>
      MockSmoothApp(
        userPreferences,
        UserManagementProvider(),
        productPreferences,
        themeProvider,
        textContrastProvider,
        colorProvider,
        KnowledgePanelActionCard(element, product),
      );

  group(
    'KnowledgePanelActionCard - HtmlTagRemover plain text & entity decoding',
    () {
      test('HtmlTagRemover strips tags and decodes entities', () {
        final HtmlTagRemover remover = HtmlTagRemover();
        expect(
          remover.extract('<b>Take a photo</b> of the ingredients').trim(),
          'Take a photo of the ingredients',
        );
        expect(remover.extract('Fish &amp; chips').trim(), 'Fish & chips');
        expect(remover.extract('&eacute;clair').trim(), 'éclair');
        expect(remover.extract('<br>').trim(), '');
        expect(remover.extract('   \n\t  ').trim(), '');
      });

      test('KnowledgePanelActionCard.getPlainText handles null and empty', () {
        expect(KnowledgePanelActionCard.getPlainText(null), '');
        expect(KnowledgePanelActionCard.getPlainText(''), '');
        expect(KnowledgePanelActionCard.getPlainText('   '), '');
        expect(KnowledgePanelActionCard.getPlainText('<br>'), '');
        expect(KnowledgePanelActionCard.getPlainText('<b>Text</b>'), 'Text');
      });
    },
  );

  group('KnowledgePanelActionCard Widget Tests', () {
    final Product testProduct = Product(barcode: '3760298140013')
      ..productType = ProductType.food;

    testWidgets(
      '1. html non-empty + one recognized action: button labelled with html text, no duplicate text',
      (WidgetTester tester) async {
        const KnowledgePanelActionElement element = KnowledgePanelActionElement(
          html: 'Take a photo of the ingredients',
          actions: <String>['add_ingredients_image'],
        );

        await tester.pumpWidget(createWidget(element, testProduct));
        await tester.pumpAndSettle();

        expect(find.byType(SmoothHtmlWidget), findsNothing);
        expect(find.byType(SmoothLargeButtonWithIcon), findsOneWidget);
        expect(
          tester
              .widget<SmoothLargeButtonWithIcon>(
                find.byType(SmoothLargeButtonWithIcon),
              )
              .text,
          'Take a photo of the ingredients',
        );
      },
    );

    testWidgets(
      '2. html empty string + action: button keeps current localized label, rendering unchanged',
      (WidgetTester tester) async {
        const KnowledgePanelActionElement element = KnowledgePanelActionElement(
          html: '',
          actions: <String>['add_ingredients_image'],
        );

        await tester.pumpWidget(createWidget(element, testProduct));
        await tester.pumpAndSettle();

        expect(find.byType(SmoothHtmlWidget), findsOneWidget);
        expect(find.byType(SmoothLargeButtonWithIcon), findsOneWidget);
        final BuildContext context = tester.element(
          find.byType(KnowledgePanelActionCard),
        );
        final String defaultLabel = AppLocalizations.of(context)
            .score_add_missing_ingredients;
        expect(
          tester
              .widget<SmoothLargeButtonWithIcon>(
                find.byType(SmoothLargeButtonWithIcon),
              )
              .text,
          defaultLabel,
        );
      },
    );

    testWidgets(
      '3. html null + action: current localized label',
      (WidgetTester tester) async {
        const KnowledgePanelActionElement element = KnowledgePanelActionElement(
          html: null,
          actions: <String>['add_ingredients_image'],
        );

        await tester.pumpWidget(createWidget(element, testProduct));
        await tester.pumpAndSettle();

        expect(find.byType(SmoothHtmlWidget), findsNothing);
        expect(find.byType(SmoothLargeButtonWithIcon), findsOneWidget);
        final BuildContext context = tester.element(
          find.byType(KnowledgePanelActionCard),
        );
        final String defaultLabel = AppLocalizations.of(context)
            .score_add_missing_ingredients;
        expect(
          tester
              .widget<SmoothLargeButtonWithIcon>(
                find.byType(SmoothLargeButtonWithIcon),
              )
              .text,
          defaultLabel,
        );
      },
    );

    testWidgets(
      '4. html whitespace-only: treated as empty, current behavior unchanged',
      (WidgetTester tester) async {
        const KnowledgePanelActionElement element = KnowledgePanelActionElement(
          html: '   \n \t  ',
          actions: <String>['add_ingredients_image'],
        );

        await tester.pumpWidget(createWidget(element, testProduct));
        await tester.pumpAndSettle();

        expect(find.byType(SmoothHtmlWidget), findsOneWidget);
        expect(find.byType(SmoothLargeButtonWithIcon), findsOneWidget);
        final BuildContext context = tester.element(
          find.byType(KnowledgePanelActionCard),
        );
        final String defaultLabel = AppLocalizations.of(context)
            .score_add_missing_ingredients;
        expect(
          tester
              .widget<SmoothLargeButtonWithIcon>(
                find.byType(SmoothLargeButtonWithIcon),
              )
              .text,
          defaultLabel,
        );
      },
    );

    testWidgets(
      '5. html with tags but no visible text (e.g. <br>): treated as empty, current behavior unchanged',
      (WidgetTester tester) async {
        const KnowledgePanelActionElement element = KnowledgePanelActionElement(
          html: '<br>',
          actions: <String>['add_ingredients_image'],
        );

        await tester.pumpWidget(createWidget(element, testProduct));
        await tester.pumpAndSettle();

        expect(find.byType(SmoothHtmlWidget), findsOneWidget);
        expect(find.byType(SmoothLargeButtonWithIcon), findsOneWidget);
        final BuildContext context = tester.element(
          find.byType(KnowledgePanelActionCard),
        );
        final String defaultLabel = AppLocalizations.of(context)
            .score_add_missing_ingredients;
        expect(
          tester
              .widget<SmoothLargeButtonWithIcon>(
                find.byType(SmoothLargeButtonWithIcon),
              )
              .text,
          defaultLabel,
        );
      },
    );

    testWidgets(
      '6. html containing tags with text: label is the stripped plain text',
      (WidgetTester tester) async {
        const KnowledgePanelActionElement element = KnowledgePanelActionElement(
          html: '<b>Take a photo</b> of the ingredients',
          actions: <String>['add_ingredients_image'],
        );

        await tester.pumpWidget(createWidget(element, testProduct));
        await tester.pumpAndSettle();

        expect(find.byType(SmoothHtmlWidget), findsNothing);
        expect(find.byType(SmoothLargeButtonWithIcon), findsOneWidget);
        expect(
          tester
              .widget<SmoothLargeButtonWithIcon>(
                find.byType(SmoothLargeButtonWithIcon),
              )
              .text,
          'Take a photo of the ingredients',
        );
      },
    );

    testWidgets(
      '7. html containing an entity: label decodes to characters they display',
      (WidgetTester tester) async {
        const KnowledgePanelActionElement element = KnowledgePanelActionElement(
          html: 'Fish &amp; chips',
          actions: <String>['add_ingredients_image'],
        );

        await tester.pumpWidget(createWidget(element, testProduct));
        await tester.pumpAndSettle();

        expect(find.byType(SmoothHtmlWidget), findsNothing);
        expect(find.byType(SmoothLargeButtonWithIcon), findsOneWidget);
        expect(
          tester
              .widget<SmoothLargeButtonWithIcon>(
                find.byType(SmoothLargeButtonWithIcon),
              )
              .text,
          'Fish & chips',
        );
      },
    );

    testWidgets(
      '8. html non-empty + more than one rendered button: current behavior preserved',
      (WidgetTester tester) async {
        const KnowledgePanelActionElement element = KnowledgePanelActionElement(
          html: 'Explanation text for multiple actions',
          actions: <String>['add_ingredients_image', 'edit_product'],
        );

        await tester.pumpWidget(createWidget(element, testProduct));
        await tester.pumpAndSettle();

        expect(find.byType(SmoothHtmlWidget), findsOneWidget);
        expect(find.byType(SmoothLargeButtonWithIcon), findsNWidgets(2));
        final BuildContext context = tester.element(
          find.byType(KnowledgePanelActionCard),
        );
        final String defaultIngredientsLabel = AppLocalizations.of(context)
            .score_add_missing_ingredients;
        final String defaultEditLabel = AppLocalizations.of(context)
            .edit_product_label;
        final List<String> buttonLabels = tester
            .widgetList<SmoothLargeButtonWithIcon>(
              find.byType(SmoothLargeButtonWithIcon),
            )
            .map((SmoothLargeButtonWithIcon b) => b.text)
            .toList();
        expect(
          buttonLabels,
          containsAll(<String>[defaultIngredientsLabel, defaultEditLabel]),
        );
      },
    );

    testWidgets(
      '9. html non-empty + unrecognized action: html text still displayed as today',
      (WidgetTester tester) async {
        const KnowledgePanelActionElement element = KnowledgePanelActionElement(
          html: 'Some html explanation',
          actions: <String>['unrecognized_action_key'],
        );

        await tester.pumpWidget(createWidget(element, testProduct));
        await tester.pumpAndSettle();

        expect(find.byType(SmoothHtmlWidget), findsOneWidget);
        expect(find.byType(SmoothLargeButtonWithIcon), findsNothing);
      },
    );
  });
}
