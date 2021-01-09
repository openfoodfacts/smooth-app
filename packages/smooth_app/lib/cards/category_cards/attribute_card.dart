import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/model/EnvironmentImpactLevels.dart';
import 'package:openfoodfacts/model/NutrientLevels.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AttributeCard extends StatelessWidget {
  const AttributeCard(
    this.product,
    this.variable,
  );

  final Product product;
  final String variable;

  static const double _HEIGHT = 40;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    switch (variable) {
      case 'nova':
        return _getNova(themeData, product.nutriments.novaGroup);
      case 'nutriscore':
        return _getNutriscore(themeData, product.nutriscore);
      case 'ecoscore':
        return _getEcoscore(
          themeData,
          _getEnvironmentImpactColor(product.environmentImpactLevels),
        );
      // TODO(monsieurtanuki): put all the other possible variables, and use attributeGroups instead
    }
    return Container();
  }

  static Widget _getNutriscore(
    final ThemeData themeData,
    final String nutriscore,
  ) =>
      Container(
        height: _HEIGHT,
        child: nutriscore != null
            ? Image.asset(
                'assets/product/nutri_score_$nutriscore.png',
                fit: BoxFit.fitHeight,
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      'Nutri-score unavailable',
                      style: themeData.textTheme.subtitle1
                          .copyWith(fontSize: 12.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
      );

  static Widget _getNova(
    final ThemeData themeData,
    final int novaGroup,
  ) =>
      Container(
        width: _HEIGHT / 2,
        height: _HEIGHT,
        child: novaGroup != null
            ? SvgPicture.asset(
                'assets/product/nova_group_$novaGroup.svg',
                fit: BoxFit.fitWidth,
              )
            : Container(),
      );

  static Widget _getEcoscore(
    final ThemeData themeData,
    final Color color,
  ) =>
      Container(
        width: _HEIGHT,
        height: _HEIGHT,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(30.0)),
        ),
        child: Center(
          child: Stack(
            children: <Widget>[
              const Text(
                'CO  ',
                style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              ),
              Transform.translate(
                offset: const Offset(16.0, 4.0),
                child: const Text(
                  '2',
                  style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );

  static final Color _colorImpactDefault = Colors.black.withAlpha(15);

  static final Map<Level, Color> _colorImpacts = <Level, Color>{
    Level.LOW: Colors.green,
    Level.MODERATE: Colors.orange,
    Level.HIGH: Colors.red,
    Level.UNDEFINED: _colorImpactDefault,
  };

  static Color _getEnvironmentImpactColor(
          EnvironmentImpactLevels environmentImpactLevels) =>
      environmentImpactLevels == null || environmentImpactLevels.levels.isEmpty
          ? _colorImpactDefault
          : _colorImpacts[environmentImpactLevels.levels.first] ??
              _colorImpactDefault;
}
