import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/html/smooth_html_widget.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/add_nutrition_button.dart';
import 'package:smooth_app/pages/product/add_ocr_button.dart';
import 'package:smooth_app/pages/product/add_packaging_button.dart';
import 'package:smooth_app/pages/product/add_simple_input_button.dart';
import 'package:smooth_app/pages/product/edit_product/edit_product_page.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/pages/product/simple_input/simple_input_page_country_helper.dart';
import 'package:smooth_app/pages/product/simple_input/simple_input_page_helpers.dart';
import 'package:smooth_app/services/smooth_services.dart';
import 'package:smooth_app/widgets/table/html_tag_remover.dart';

/// "Contribute Actions" for the knowledge panels.
class KnowledgePanelActionCard extends StatelessWidget {
  const KnowledgePanelActionCard(this.element, this.product);

  final KnowledgePanelActionElement element;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final List<Widget> initialButtons = <Widget>[];
    String? singleAction;
    for (final String action in element.actions) {
      final Widget? button = _getButton(context, action);
      if (button != null) {
        initialButtons.add(button);
        singleAction = action;
      }
    }

    final String plainText = _getPlainText(element.html);
    final bool overrideSingleButton =
        plainText.isNotEmpty && initialButtons.length == 1;

    final List<Widget> actionWidgets;
    if (overrideSingleButton) {
      actionWidgets = <Widget>[
        _getButton(context, singleAction!, label: plainText)!,
      ];
    } else {
      actionWidgets = initialButtons;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (!overrideSingleButton && element.html != null)
          SmoothHtmlWidget(element.html!),
        const SizedBox(height: SMALL_SPACE),
        ...actionWidgets,
      ],
    );
  }

  static String _getPlainText(String? html) {
    if (html == null) {
      return '';
    }
    return HtmlTagRemover().extract(html).trim();
  }

  // TODO(monsieurtanuki): deprecate KnowledgePanelAction in off-dart, as its use drags us behind
  Widget? _getButton(BuildContext context, String action, {String? label}) {
    final AbstractSimpleInputPageHelper? simpleInputPageHelper =
        _getSimpleInputPageHelper(context, action);
    if (simpleInputPageHelper != null) {
      return AddSimpleInputButton(
        product: product,
        helper: simpleInputPageHelper,
        label: label,
      );
    }
    if (_isPackaging(action)) {
      return AddPackagingButton(product: product, label: label);
    }
    if (_isIngredient(action)) {
      return AddOcrButton(
        product: product,
        editor: ProductFieldOcrIngredientEditor(),
        label: label,
      );
    }
    if (action == 'add_nutrition_facts') {
      if (AddNutritionButton.acceptsNutritionFacts(product)) {
        return AddNutritionButton(product, label: label);
      }
      return null;
    }
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if (action == 'edit_product') {
      return addPanelButton(
        label ?? appLocalizations.edit_product_label,
        onPressed: () async => Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => EditProductPage(product),
          ),
        ),
      );
    }
    if (action == 'report_product_to_nutripatrol') {
      return addPanelButton(
        label ?? appLocalizations.product_footer_action_report,
        onPressed: () async => LaunchUrlHelper.launchURL(
          'https://nutripatrol.openfoodfacts.org/flag/product/'
          '?barcode=${product.barcode}'
          '&source=mobile'
          '&flavor=${product.productType?.flavor.offTag}',
        ),
      );
    }
    Logs.e('unhandled knowledge panel action: $action');
    return null;
  }

  AbstractSimpleInputPageHelper? _getSimpleInputPageHelper(
    BuildContext context,
    String action,
  ) {
    switch (action) {
      case 'add_categories':
        return SimpleInputPageCategoryHelper();
      case 'add_origins':
        return SimpleInputPageOriginHelper();
      case 'add_stores':
        return SimpleInputPageStoreHelper();
      case 'add_labels':
        return SimpleInputPageLabelHelper();
      case 'add_countries':
        return SimpleInputPageCountryHelper(context.read<UserPreferences>());
      default:
        return null;
    }
  }

  bool _isIngredient(String action) {
    switch (action) {
      case 'add_ingredients_text':
      case 'add_ingredients_image':
        return true;
      default:
        return false;
    }
  }

  bool _isPackaging(String action) {
    switch (action) {
      case 'add_packaging_text':
      case 'add_packaging_image':
        return true;
      default:
        return false;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('html', element.html));
    properties.add(IterableProperty<String>('actions', element.actions));
  }
}

// TODO(monsieurtanuki): move code to off-dart
extension ProductTypeFlavorExtension on ProductType {
  Flavor get flavor => switch (this) {
    ProductType.food => Flavor.openFoodFacts,
    ProductType.beauty => Flavor.openBeautyFacts,
    ProductType.petFood => Flavor.openPetFoodFacts,
    ProductType.product => Flavor.openProductFacts,
  };
}
