import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/widgets/svg_icon.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';

class StringPair {
  StringPair({
    required this.first,
    this.second,
  });

  final String first;
  final String? second;
}

abstract class AttributeFirstRowHelper {
  List<StringPair> getAllTerms();

  Widget? getLeadingIcon();

  String getTitle(BuildContext context);
}

class AttributeFirstRowSimpleHelper extends AttributeFirstRowHelper {
  AttributeFirstRowSimpleHelper({
    required this.helper,
  });

  final AbstractSimpleInputPageHelper helper;

  @override
  List<StringPair> getAllTerms() {
    final List<StringPair> allTerms = <StringPair>[];

    for (final String element in helper.terms) {
      allTerms.add(
        StringPair(
          first: element,
        ),
      );
    }

    return allTerms;
  }

  @override
  Widget? getLeadingIcon() {
    return helper.getIcon();
  }

  @override
  String getTitle(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return helper.getTitle(
      appLocalizations,
    );
  }
}

class AttributeFirstRowNutritionHelper extends AttributeFirstRowHelper {
  AttributeFirstRowNutritionHelper({
    required this.product,
  });

  final Product product;

  @override
  List<StringPair> getAllTerms() {
    final List<StringPair> allNutrients = <StringPair>[];
    product.nutriments?.toData().forEach(
      (String nutrientName, String quantity) {
        allNutrients.add(
          StringPair(
            first: nutrientName.split('_100g')[0],
            second: quantity,
          ),
        );
      },
    );

    return allNutrients;
  }

  @override
  Widget? getLeadingIcon() {
    return const SvgIcon(
      'assets/cacheTintable/scale-balance.svg',
      dontAddColor: true,
    );
  }

  @override
  String getTitle(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return appLocalizations.nutrition_page_title;
  }
}

class AttributeFirstRowIngredientsHelper extends AttributeFirstRowHelper {
  AttributeFirstRowIngredientsHelper({
    required this.product,
  });

  final Product product;

  @override
  List<StringPair> getAllTerms() {
    final List<StringPair> allIngredients = <StringPair>[];
    product.ingredients?.forEach(
      (Ingredient element) {
        if (element.text != null) {
          allIngredients.add(
            StringPair(
              first: element.text!,
            ),
          );
        }
      },
    );

    return allIngredients;
  }

  @override
  Widget? getLeadingIcon() {
    return const SvgIcon(
      'assets/cacheTintable/ingredients.svg',
      dontAddColor: true,
    );
  }

  @override
  String getTitle(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return appLocalizations.ingredients;
  }
}
