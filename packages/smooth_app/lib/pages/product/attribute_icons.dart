import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/resources/app_icons.dart';

abstract class AttributeIcon extends StatelessWidget {
  factory AttributeIcon(
    Attribute attribute, {
    required Color backgroundColor,
    required double size,
    Color? foregroundColor,
    String? semanticsLabel,
  }) {
    return switch (attribute.id) {
      'additives' => _AttributeAdditivesIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'allergens_no_celery' => _AttributeCeleryIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'allergens_no_crustaceans' => _AttributeCrustaceansIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'allergens_no_eggs' => _AttributeEggsIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'allergens_no_fish' => _AttributeFishIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'allergens_no_gluten' => _AttributeGlutenIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'allergens_no_lupin' => _AttributeLupinIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'allergens_no_milk' => _AttributeMilkIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'allergens_no_molluscs' => _AttributeMolluscsIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'allergens_no_mustard' => _AttributeMustardIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'allergens_no_nuts' => _AttributeNutsIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'allergens_no_peanuts' => _AttributePeanutsIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'allergens_no_sesame_seeds' => _AttributeSesameSeedsIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'allergens_no_soybeans' => _AttributeSoybeansIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'allergens_no_sulphur_dioxide_and_sulphites' => _AttributeSulphitesIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'forest_footprint' => _AttributeForestFootprintIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'labels_fair_trade' => _AttributeFairTradeIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'labels_organic' => _AttributeOrganicFarmingIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'low_fat' => _AttributeFatIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'low_salt' => _AttributeSaltIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'low_saturated_fat' => _AttributeSaturatedFatIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'low_sugars' => _AttributeSugarIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'nova' => _AttributeNOVAIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'palm_oil_free' => _AttributePalmOilIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'vegan' => _AttributeVeganIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'vegetarian' => _AttributeVegetarianIcon(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),

      /*'nutriscore' => EMPTY_WIDGET,
      'ecoscore' => EMPTY_WIDGET,*/
      _ => throw UnsupportedError('Unsupported attribute: ${attribute.id}'),
    };
  }

  const AttributeIcon._({
    required this.icon,
    required this.backgroundColor,
    this.size,
    this.iconSize,
    this.angle,
    this.offset,
    Color? foregroundColor,
    this.padding,
    this.semanticsLabel,
    this.clip = false,
  }) : foregroundColor = foregroundColor ?? Colors.white;

  final Widget icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final double? size;
  final double? angle;
  final Offset? offset;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final String? semanticsLabel;
  final bool? clip;

  @override
  Widget build(BuildContext context) {
    Widget child = Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: const CircleBorder(),
          color: backgroundColor,
        ),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Transform.translate(
            offset: offset ?? Offset.zero,
            child: AppIconTheme(
              color: foregroundColor,
              size: iconSize,
              child: icon,
            ),
          ),
        ),
      ),
    );

    if (angle != null) {
      child = Transform.rotate(
        angle: angle!,
        child: child,
      );
    }

    if (clip == true) {
      child = ClipOval(
        child: child,
      );
    }

    if (size != null) {
      return SizedBox.square(
        dimension: size,
        child: child,
      );
    }
    return child;
  }
}

class _AttributeAdditivesIcon extends AttributeIcon {
  _AttributeAdditivesIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.additives(),
          iconSize: size! * 0.6,
          padding: EdgeInsetsDirectional.only(bottom: size * 0.05),
        );
}

class _AttributeCeleryIcon extends AttributeIcon {
  _AttributeCeleryIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.celery(),
          iconSize: size! * 0.95,
          offset: Offset(size * -0.1, 0.0),
          clip: true,
          padding: EdgeInsetsDirectional.only(top: size * 0.15),
        );
}

class _AttributeCrustaceansIcon extends AttributeIcon {
  _AttributeCrustaceansIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.crustaceans(),
          iconSize: size! * 0.95,
          clip: true,
          padding: EdgeInsetsDirectional.only(
            top: size * 0.15,
          ),
        );
}

class _AttributeEggsIcon extends AttributeIcon {
  _AttributeEggsIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.eggs(),
          iconSize: size! * 0.65,
          padding: const EdgeInsetsDirectional.only(top: 1.0),
        );
}

class _AttributeFishIcon extends AttributeIcon {
  _AttributeFishIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.fish(),
          iconSize: size! * 0.8,
          padding: EdgeInsetsDirectional.only(
            top: size * 0.06,
            start: size * 0.02,
          ),
        );
}

class _AttributeGlutenIcon extends AttributeIcon {
  _AttributeGlutenIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.gluten(),
          iconSize: size! * 0.6,
          padding: EdgeInsetsDirectional.only(
            top: size * 0.04,
            end: size * 0.01,
          ),
        );
}

class _AttributeFairTradeIcon extends AttributeIcon {
  _AttributeFairTradeIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.fairTrade(),
          iconSize: size! * 0.8,
          padding: EdgeInsetsDirectional.only(
            top: size * 0.1,
            start: size * 0.01,
          ),
        );
}

class _AttributeFatIcon extends AttributeIcon {
  _AttributeFatIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.fat(),
          iconSize: size! * 0.7,
        );
}

class _AttributeForestFootprintIcon extends AttributeIcon {
  _AttributeForestFootprintIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.forestFootprint(),
          iconSize: size! * 0.68,
        );
}

class _AttributeLupinIcon extends AttributeIcon {
  _AttributeLupinIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.lupin(),
          iconSize: size! * 0.7,
          padding: EdgeInsetsDirectional.only(
            start: size * 0.05,
            top: size * 0.06,
          ),
        );
}

class _AttributeMilkIcon extends AttributeIcon {
  _AttributeMilkIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.milk(),
          iconSize: size! * 1.02,
          clip: true,
          padding: EdgeInsetsDirectional.only(
            top: size * 0.25,
          ),
        );
}

class _AttributeMolluscsIcon extends AttributeIcon {
  _AttributeMolluscsIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.molluscs(),
          iconSize: size! * 0.7,
        );
}

class _AttributeMustardIcon extends AttributeIcon {
  _AttributeMustardIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.mustard(),
          iconSize: size! * 1.2,
          angle: math.pi / 6,
          offset: Offset(size * -0.1, 0.0),
          clip: true,
          padding: EdgeInsetsDirectional.only(
            top: size * 0.12,
            end: size * 0.1,
          ),
        );
}

class _AttributeNutsIcon extends AttributeIcon {
  _AttributeNutsIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.nuts(),
          iconSize: size! * 0.7,
          padding: EdgeInsetsDirectional.only(top: size * 0.005),
        );
}

class _AttributeNOVAIcon extends AttributeIcon {
  _AttributeNOVAIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.nova(),
          iconSize: size! * 0.75,
        );
}

class _AttributeOrganicFarmingIcon extends AttributeIcon {
  _AttributeOrganicFarmingIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.organicFarming(),
          iconSize: size! * 0.8,
          clip: true,
          padding: EdgeInsetsDirectional.only(bottom: size * 0.1),
        );
}

class _AttributePalmOilIcon extends AttributeIcon {
  _AttributePalmOilIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.palmOil(),
          iconSize: size! * 0.75,
          padding: EdgeInsetsDirectional.only(top: size * 0.04),
        );
}

class _AttributePeanutsIcon extends AttributeIcon {
  _AttributePeanutsIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.peanuts(),
          iconSize: size! * 0.7,
          padding: EdgeInsetsDirectional.only(bottom: size * 0.03),
        );
}

class _AttributeSaltIcon extends AttributeIcon {
  _AttributeSaltIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.salt(),
          iconSize: size! * 1.1,
          clip: true,
          offset: Offset(size * -0.3, size * -0.3),
        );
}

class _AttributeSaturatedFatIcon extends AttributeIcon {
  _AttributeSaturatedFatIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.saturatedFat(),
          iconSize: size! * 0.75,
        );
}

class _AttributeSesameSeedsIcon extends AttributeIcon {
  _AttributeSesameSeedsIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.sesameSeeds(),
          iconSize: size! * 0.81,
          padding: EdgeInsetsDirectional.only(bottom: size * 0.02),
        );
}

class _AttributeSoybeansIcon extends AttributeIcon {
  _AttributeSoybeansIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.soybeans(),
          iconSize: size! * 0.7,
          padding: EdgeInsetsDirectional.only(
            top: size * 0.05,
            end: size * 0.07,
          ),
        );
}

class _AttributeSugarIcon extends AttributeIcon {
  _AttributeSugarIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.sugar(),
          iconSize: size! * 0.65,
          padding: EdgeInsetsDirectional.only(bottom: size * 0.1),
        );
}

class _AttributeSulphitesIcon extends AttributeIcon {
  _AttributeSulphitesIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.sulphites(),
          iconSize: size! * 0.9,
          clip: true,
        );
}

class _AttributeVeganIcon extends AttributeIcon {
  _AttributeVeganIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.vegan(),
          iconSize: size! * 0.7,
          padding: EdgeInsetsDirectional.only(top: size * 0.07),
        );
}

class _AttributeVegetarianIcon extends AttributeIcon {
  _AttributeVegetarianIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.vegetarian(),
          iconSize: size! * 0.65,
          padding: EdgeInsetsDirectional.only(
            bottom: size * 0.04,
            end: size * 0.06,
          ),
        );
}
