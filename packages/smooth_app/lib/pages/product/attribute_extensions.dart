import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:smooth_app/pages/product/attribute_icons.dart';
import 'package:smooth_app/resources/app_icons.dart';

extension AttributeExtensions on Attribute {
  Widget? getIcon({
    Color? color,
    Shadow? shadow,
    double? size,
    String? semanticLabel,
  }) {
    return switch (id) {
      'additives' => FoodIcons.additives(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'allergens_no_celery' => FoodIcons.celery(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'allergens_no_crustaceans' => FoodIcons.crustaceans(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'allergens_no_eggs' => FoodIcons.eggs(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'allergens_no_fish' => FoodIcons.fish(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'allergens_no_gluten' => FoodIcons.gluten(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'allergens_no_lupin' => FoodIcons.lupin(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'allergens_no_milk' => FoodIcons.milk(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'allergens_no_molluscs' => FoodIcons.molluscs(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'allergens_no_mustard' => FoodIcons.mustard(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'allergens_no_nuts' => FoodIcons.nuts(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'allergens_no_peanuts' => FoodIcons.peanuts(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'allergens_no_sesame_seeds' => FoodIcons.sesameSeeds(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'allergens_no_soybeans' => FoodIcons.soybeans(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'allergens_no_sulphur_dioxide_and_sulphites' => FoodIcons.sulphites(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'ecoscore' => EMPTY_WIDGET,
      'forest_footprint' => FoodIcons.forestFootprint(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'labels_fair_trade' => FoodIcons.fairTrade(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'labels_organic' => FoodIcons.organicFarming(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'low_fat' => FoodIcons.fat(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'low_salt' => FoodIcons.salt(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'low_saturated_fat' => FoodIcons.saturatedFat(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'low_sugars' => FoodIcons.sugar(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'nova' => EMPTY_WIDGET,
      'nutriscore' => EMPTY_WIDGET,
      'palm_oil_free' => FoodIcons.palmOil(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'vegan' => FoodIcons.vegan(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      'vegetarian' => FoodIcons.vegetarian(
          color: color,
          size: size,
          shadow: shadow,
          semanticLabel: semanticLabel,
        ),
      _ => throw UnimplementedError(),
    };
  }

  Widget? getCircledIcon({
    required Color backgroundColor,
    required double size,
    Color? foregroundColor,
    Shadow? shadow,
    String? semanticLabel,
  }) {
    try {
      return AttributeIcon(
        this,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        size: size,
      );
    } catch (e) {
      return SizedBox.square(dimension: size);
    }
  }
}
