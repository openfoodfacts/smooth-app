import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/html/smooth_html_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> actionWidgets = <Widget>[];
    for (final String action in element.actions) {
      final Widget? button = _getButton(action);
      if (button != null) {
        actionWidgets.add(button);
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (element.html != null) SmoothHtmlWidget(element.html!),
        const SizedBox(height: SMALL_SPACE),
        ...actionWidgets,
      ],
    );
  }

  Widget? _getButton(final String action) {
    final KnowledgePanelAction? kpAction =
        KnowledgePanelAction.fromOffTag(action);
    if (kpAction == null) {
      Logs.e('unknown knowledge panel action: $action');
      return null;
    }
    final AbstractSimpleInputPageHelper? simpleInputPageHelper =
        _getSimpleInputPageHelper(kpAction);
    if (simpleInputPageHelper != null) {
      return AddSimpleInputButton(
        product: product,
        helper: simpleInputPageHelper,
      );
    }
    if (_isPackaging(kpAction)) {
      return AddPackagingButton(
        product: product,
      );
    }
    if (_isIngredient(kpAction)) {
      return AddOcrButton(
        product: product,
        editor: ProductFieldOcrIngredientEditor(),
      );
    }
    if (kpAction == KnowledgePanelAction.addNutritionFacts) {
      if (AddNutritionButton.acceptsNutritionFacts(product)) {
        return AddNutritionButton(product);
      }
    }
    Logs.e('unhandled knowledge panel action: $action');
    return null;
  }

  AbstractSimpleInputPageHelper? _getSimpleInputPageHelper(
    final KnowledgePanelAction action,
  ) {
    switch (action) {
      case KnowledgePanelAction.addCategories:
        return SimpleInputPageCategoryHelper();
      case KnowledgePanelAction.addOrigins:
        return SimpleInputPageOriginHelper();
      case KnowledgePanelAction.addStores:
        return SimpleInputPageStoreHelper();
      case KnowledgePanelAction.addLabels:
        return SimpleInputPageLabelHelper();
      case KnowledgePanelAction.addCountries:
        return SimpleInputPageCountryHelper();
      default:
        return null;
    }
  }

  bool _isIngredient(final KnowledgePanelAction action) {
    switch (action) {
      case KnowledgePanelAction.addIngredientsText:
      case KnowledgePanelAction.addIngredientsImage:
        return true;
      default:
        return false;
    }
  }

  bool _isPackaging(final KnowledgePanelAction action) {
    switch (action) {
      case KnowledgePanelAction.addPackagingText:
      case KnowledgePanelAction.addPackagingImage:
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
