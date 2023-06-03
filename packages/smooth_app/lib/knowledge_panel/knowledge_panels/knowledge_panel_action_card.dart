import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/smooth_html_widget.dart';
import 'package:smooth_app/pages/product/add_nutrition_button.dart';
import 'package:smooth_app/pages/product/add_ocr_button.dart';
import 'package:smooth_app/pages/product/add_packaging_button.dart';
import 'package:smooth_app/pages/product/add_simple_input_button.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/services/smooth_services.dart';

/// "Contribute Actions" for the knowledge panels.
class KnowledgePanelActionCard extends StatelessWidget {
  const KnowledgePanelActionCard(this.element, this.product);

  final KnowledgePanelActionElement element;
  final Product product;

  // TODO(monsieurtanuki): move to off-dart's knowledge_panel_element.dart
  static const String _ACTION_ADD_ORIGINS = 'add_origins';
  static const String _ACTION_ADD_STORES = 'add_stores';
  static const String _ACTION_ADD_LABELS = 'add_labels';
  static const String _ACTION_ADD_COUNTRIES = 'add_countries';
  static const String _ACTION_ADD_PACKAGING_IMAGE = 'add_packaging_image';
  static const String _ACTION_ADD_PACKAGING_TEXT = 'add_packaging_text';
  static const String _ACTION_ADD_INGREDIENTS_IMAGE = 'add_ingredients_image';

  @override
  Widget build(BuildContext context) {
    final List<Widget> actionWidgets = <Widget>[];
    for (final String action in element.actions) {
      final Widget? button = _getButton(action);
      if (button != null) {
        actionWidgets.add(button);
      } else {
        Logs.e('unknown knowledge panel action: $action');
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SmoothHtmlWidget(element.html),
        const SizedBox(height: SMALL_SPACE),
        ...actionWidgets,
      ],
    );
  }

  Widget? _getButton(final String action) {
    final AbstractSimpleInputPageHelper? simpleInputPageHelper =
        _getSimpleInputPageHelper(action);
    if (simpleInputPageHelper != null) {
      return AddSimpleInputButton(
        product: product,
        helper: simpleInputPageHelper,
      );
    }
    if (_isPackaging(action)) {
      return AddPackagingButton(
        product: product,
      );
    }
    if (_isIngredient(action)) {
      return AddOcrButton(
        product: product,
        editor: ProductFieldOcrIngredientEditor(),
      );
    }
    if (action == KnowledgePanelActionElement.ACTION_ADD_NUTRITION_FACTS) {
      return AddNutritionButton(product);
    }
    Logs.e('unknown knowledge panel action: $action');
    return null;
  }

  AbstractSimpleInputPageHelper? _getSimpleInputPageHelper(
    final String action,
  ) {
    switch (action) {
      case KnowledgePanelActionElement.ACTION_ADD_CATEGORIES:
        return SimpleInputPageCategoryHelper();
      case _ACTION_ADD_ORIGINS:
        return SimpleInputPageOriginHelper();
      case _ACTION_ADD_STORES:
        return SimpleInputPageStoreHelper();
      case _ACTION_ADD_LABELS:
        return SimpleInputPageLabelHelper();
      case _ACTION_ADD_COUNTRIES:
        return SimpleInputPageCountryHelper();
    }
    return null;
  }

  bool _isIngredient(
    final String action,
  ) {
    switch (action) {
      case KnowledgePanelActionElement.ACTION_ADD_INGREDIENTS_TEXT:
      case _ACTION_ADD_INGREDIENTS_IMAGE:
        return true;
      default:
        return false;
    }
  }

  bool _isPackaging(
    final String action,
  ) {
    switch (action) {
      case _ACTION_ADD_PACKAGING_IMAGE:
      case _ACTION_ADD_PACKAGING_TEXT:
        return true;
      default:
        return false;
    }
  }
}
