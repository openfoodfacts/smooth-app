import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/product/add_new_product_page.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';

/// "Incomplete product!" card to be displayed in product summary, if relevant.
///
/// You're suppose to test [isProductIncomplete] first; if true you should
/// display the card.
class ProductIncompleteCard extends StatelessWidget {
  const ProductIncompleteCard({
    required this.product,
    this.isLoggedInMandatory = true,
  });

  final Product product;
  final bool isLoggedInMandatory;

  static bool isProductIncomplete(final Product product) {
    bool checkScores = true;
    if (_isNutriscoreNotApplicable(product)) {
      AnalyticsHelper.trackEvent(
        AnalyticsEvent.notShowFastTrackProductEditCardNutriscore,
        barcode: product.barcode,
      );
      checkScores = false;
    }
    if (_isEcoscoreNotApplicable(product)) {
      AnalyticsHelper.trackEvent(
        AnalyticsEvent.notShowFastTrackProductEditCardEcoscore,
        barcode: product.barcode,
      );
      checkScores = false;
    }
    if (!checkScores) {
      return false;
    }
    final List<ProductFieldEditor> editors = <ProductFieldEditor>[
      ProductFieldSimpleEditor(SimpleInputPageCategoryHelper()),
      ProductFieldNutritionEditor(),
      ProductFieldOcrIngredientEditor(),
    ];

    for (final ProductFieldEditor editor in editors) {
      if (!editor.isPopulated(product)) {
        return true;
      }
    }
    return false;
  }

  static bool _isNutriscoreNotApplicable(final Product product) =>
      _isScoreNotApplicable(product, 'nutriscore');

  static bool _isEcoscoreNotApplicable(final Product product) =>
      _isScoreNotApplicable(product, 'ecoscore');

  static bool _isScoreNotApplicable(final Product product, final String tag) =>
      _getAttribute(product, tag)?.iconUrl ==
      'https://static.openfoodfacts.org/images/attributes/$tag-not-applicable.svg';

  // TODO(monsieurtanuki): move to off-dart (or find it there)
  static Attribute? _getAttribute(final Product product, final String id) {
    if (product.attributeGroups == null) {
      return null;
    }
    for (final AttributeGroup attributeGroup in product.attributeGroups!) {
      if (attributeGroup.attributes == null) {
        continue;
      }
      for (final Attribute attribute in attributeGroup.attributes!) {
        if (attribute.id == id) {
          return attribute;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if (!isProductIncomplete(product)) {
      // not supposed to happen: you should check `isProductIncomplete == true` first
      return EMPTY_WIDGET;
    }

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
      child: ElevatedButton.icon(
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
          child: Text(appLocalizations.hey_incomplete_product_message),
        ),
        icon: const Icon(
          Icons.bolt,
          color: Colors.amber,
        ),
        onPressed: () async => Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => AddNewProductPage.fromProduct(
              product,
              isLoggedInMandatory: isLoggedInMandatory,
            ),
          ),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            colorScheme.primary,
          ),
          foregroundColor: MaterialStateProperty.all<Color>(
            colorScheme.onPrimary,
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            const RoundedRectangleBorder(borderRadius: ANGULAR_BORDER_RADIUS),
          ),
        ),
      ),
    );
  }
}
