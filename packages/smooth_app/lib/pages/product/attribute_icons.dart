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
      'nova' when attribute.iconUrl?.endsWith('nova-group-1.svg') == true =>
        _AttributeNOVAIcon.group1(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'nova' when attribute.iconUrl?.endsWith('nova-group-2.svg') == true =>
        _AttributeNOVAIcon.group2(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'nova' when attribute.iconUrl?.endsWith('nova-group-3.svg') == true =>
        _AttributeNOVAIcon.group3(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      'nova' when attribute.iconUrl?.endsWith('nova-group-4.svg') == true =>
        _AttributeNOVAIcon.group4(
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
    required this.size,
    this.iconSizeFactor,
    this.angle,
    this.offsetFactor,
    Color? foregroundColor,
    this.paddingFactor,
    this.semanticsLabel,
    this.clip = false,
  }) : foregroundColor = foregroundColor ?? Colors.white;

  final Widget icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final double size;
  final double? angle;
  final Offset? offsetFactor;
  final double? iconSizeFactor;
  final EdgeInsetsDirectional? paddingFactor;
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
          padding: paddingFactor != null
              ? EdgeInsetsDirectional.only(
                  start: paddingFactor!.start * size,
                  end: paddingFactor!.end * size,
                  top: paddingFactor!.top * size,
                  bottom: paddingFactor!.bottom * size,
                )
              : EdgeInsets.zero,
          child: Transform.translate(
            offset: offsetFactor != null
                ? Offset(
                    size * offsetFactor!.dx,
                    size * offsetFactor!.dy,
                  )
                : Offset.zero,
            child: AppIconTheme(
              color: foregroundColor,
              size: size * (iconSizeFactor ?? 1.0),
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

    return SizedBox.square(
      dimension: size,
      child: child,
    );
  }
}

class _AttributeAdditivesIcon extends AttributeIcon {
  const _AttributeAdditivesIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.additives(),
          iconSizeFactor: 0.6,
          paddingFactor: const EdgeInsetsDirectional.only(bottom: 0.05),
        );
}

class _AttributeCeleryIcon extends AttributeIcon {
  const _AttributeCeleryIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.celery(),
          iconSizeFactor: 0.95,
          offsetFactor: const Offset(-0.1, 0.0),
          clip: true,
          paddingFactor: const EdgeInsetsDirectional.only(top: 0.15),
        );
}

class _AttributeCrustaceansIcon extends AttributeIcon {
  const _AttributeCrustaceansIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.crustaceans(),
          iconSizeFactor: 0.95,
          clip: true,
          paddingFactor: const EdgeInsetsDirectional.only(top: 0.15),
        );
}

class _AttributeEggsIcon extends AttributeIcon {
  const _AttributeEggsIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.eggs(),
          iconSizeFactor: 0.65,
          paddingFactor: const EdgeInsetsDirectional.only(top: 0.01),
        );
}

class _AttributeFishIcon extends AttributeIcon {
  const _AttributeFishIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.fish(),
          iconSizeFactor: 0.8,
          paddingFactor: const EdgeInsetsDirectional.only(
            top: 0.06,
            start: 0.02,
          ),
        );
}

class _AttributeGlutenIcon extends AttributeIcon {
  const _AttributeGlutenIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.gluten(),
          iconSizeFactor: 0.6,
          paddingFactor: const EdgeInsetsDirectional.only(
            top: 0.04,
            end: 0.01,
          ),
        );
}

class _AttributeFairTradeIcon extends AttributeIcon {
  const _AttributeFairTradeIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.fairTrade(),
          iconSizeFactor: 0.8,
          paddingFactor: const EdgeInsetsDirectional.only(
            top: 0.1,
            start: 0.01,
          ),
        );
}

class _AttributeFatIcon extends AttributeIcon {
  const _AttributeFatIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.fat(),
          iconSizeFactor: 0.7,
        );
}

class _AttributeForestFootprintIcon extends AttributeIcon {
  const _AttributeForestFootprintIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.forestFootprint(),
          iconSizeFactor: 0.68,
        );
}

class _AttributeLupinIcon extends AttributeIcon {
  const _AttributeLupinIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.lupin(),
          iconSizeFactor: 0.7,
          paddingFactor: const EdgeInsetsDirectional.only(
            start: 0.05,
            top: 0.06,
          ),
        );
}

class _AttributeMilkIcon extends AttributeIcon {
  const _AttributeMilkIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.milk(),
          iconSizeFactor: 1.02,
          clip: true,
          paddingFactor: const EdgeInsetsDirectional.only(
            top: 0.25,
          ),
        );
}

class _AttributeMolluscsIcon extends AttributeIcon {
  const _AttributeMolluscsIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.molluscs(),
          iconSizeFactor: 0.7,
        );
}

class _AttributeMustardIcon extends AttributeIcon {
  const _AttributeMustardIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.mustard(),
          iconSizeFactor: 1.2,
          angle: math.pi / 6,
          offsetFactor: const Offset(-0.1, 0.0),
          clip: true,
          paddingFactor: const EdgeInsetsDirectional.only(
            top: 0.12,
            end: 0.1,
          ),
        );
}

class _AttributeNutsIcon extends AttributeIcon {
  const _AttributeNutsIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.nuts(),
          iconSizeFactor: 0.7,
          paddingFactor: const EdgeInsetsDirectional.only(top: 0.005),
        );
}

class _AttributeNOVAIcon extends AttributeIcon {
  const _AttributeNOVAIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.nova(),
          iconSizeFactor: 0.75,
        );

  const _AttributeNOVAIcon.group1({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.nova1(),
          iconSizeFactor: 0.68,
          paddingFactor: const EdgeInsetsDirectional.only(
            top: 0.12,
            start: 0.025,
          ),
        );

  const _AttributeNOVAIcon.group2({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.nova2(),
          iconSizeFactor: 0.67,
          paddingFactor: const EdgeInsetsDirectional.only(
            top: 0.08,
            start: 0.025,
          ),
        );

  const _AttributeNOVAIcon.group3({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.nova3(),
          iconSizeFactor: 0.68,
          paddingFactor: const EdgeInsetsDirectional.only(
            top: 0.12,
            start: 0.025,
          ),
        );

  const _AttributeNOVAIcon.group4({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.nova4(),
          iconSizeFactor: 0.65,
          paddingFactor: const EdgeInsetsDirectional.only(
            top: 0.09,
            start: 0.025,
          ),
        );
}

class _AttributeOrganicFarmingIcon extends AttributeIcon {
  const _AttributeOrganicFarmingIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.organicFarming(),
          iconSizeFactor: 0.8,
          clip: true,
          paddingFactor: const EdgeInsetsDirectional.only(bottom: 0.1),
        );
}

class _AttributePalmOilIcon extends AttributeIcon {
  const _AttributePalmOilIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.palmOil(),
          iconSizeFactor: 0.75,
          paddingFactor: const EdgeInsetsDirectional.only(top: 0.04),
        );
}

class _AttributePeanutsIcon extends AttributeIcon {
  const _AttributePeanutsIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.peanuts(),
          iconSizeFactor: 0.7,
          paddingFactor: const EdgeInsetsDirectional.only(bottom: 0.03),
        );
}

class _AttributeSaltIcon extends AttributeIcon {
  const _AttributeSaltIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.salt(),
          iconSizeFactor: 1.1,
          clip: true,
          offsetFactor: const Offset(-0.3, -0.3),
        );
}

class _AttributeSaturatedFatIcon extends AttributeIcon {
  const _AttributeSaturatedFatIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.saturatedFat(),
          iconSizeFactor: 0.75,
        );
}

class _AttributeSesameSeedsIcon extends AttributeIcon {
  const _AttributeSesameSeedsIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.sesameSeeds(),
          iconSizeFactor: 0.81,
          paddingFactor: const EdgeInsetsDirectional.only(bottom: 0.02),
        );
}

class _AttributeSoybeansIcon extends AttributeIcon {
  const _AttributeSoybeansIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.soybeans(),
          iconSizeFactor: 0.7,
          paddingFactor: const EdgeInsetsDirectional.only(
            top: 0.05,
            end: 0.07,
          ),
        );
}

class _AttributeSugarIcon extends AttributeIcon {
  const _AttributeSugarIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.sugar(),
          iconSizeFactor: 0.65,
          paddingFactor: const EdgeInsetsDirectional.only(bottom: 0.1),
        );
}

class _AttributeSulphitesIcon extends AttributeIcon {
  const _AttributeSulphitesIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.sulphites(),
          iconSizeFactor: 0.9,
          clip: true,
        );
}

class _AttributeVeganIcon extends AttributeIcon {
  const _AttributeVeganIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.vegan(),
          iconSizeFactor: 0.7,
          paddingFactor: const EdgeInsetsDirectional.only(top: 0.07),
        );
}

class _AttributeVegetarianIcon extends AttributeIcon {
  const _AttributeVegetarianIcon({
    required super.backgroundColor,
    required super.size,
    super.foregroundColor,
    super.semanticsLabel,
  }) : super._(
          icon: const FoodIcons.vegetarian(),
          iconSizeFactor: 0.65,
          paddingFactor: const EdgeInsetsDirectional.only(
            bottom: 0.04,
            end: 0.06,
          ),
        );
}
