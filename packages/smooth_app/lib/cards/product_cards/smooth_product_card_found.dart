import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:openfoodfacts/model/EnvironmentImpactLevels.dart';
import 'package:openfoodfacts/model/NutrientLevels.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_template.dart';
import 'package:smooth_app/pages/product_page.dart';
import 'package:smooth_ui_library/widgets/smooth_product_image.dart';

class SmoothProductCardFound extends SmoothProductCardTemplate {
  SmoothProductCardFound({
    @required this.product,
    @required this.heroTag,
    this.elevation = 0.0,
    this.useNewStyle = true,
    this.backgroundColor = Colors.white,
  });

  final Product product;
  final String heroTag;
  final double elevation;
  final bool useNewStyle;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    if (!useNewStyle) {
      return _getOldStyle(context);
    }
    return GestureDetector(
      onTap: () {
        //_openSneakPeek(context);
        Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => ProductPage(
                    product: product,
                  )),
        );
      },
      child: Hero(
        tag: heroTag,
        child: Material(
          elevation: elevation,
          borderRadius: const BorderRadius.all(Radius.circular(15.0)),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            ),
            padding: const EdgeInsets.all(5.0),
            height: 120.0,
            child: Row(
              children: <Widget>[
                SmoothProductImage(
                  product: product,
                  width: MediaQuery.of(context).size.width * 0.20,
                  height: double.infinity,
                ),
                const SizedBox(
                  width: 8.0,
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  product.productName ?? 'Unknown product name',
                                  maxLines: 2,
                                  overflow: TextOverflow.fade,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  product.brands ?? 'Unknown brand',
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w300,
                                      fontStyle: FontStyle.italic),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                            top: BorderSide(color: Colors.grey, width: 1.0)),
                      ),
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.225,
                            child: product.nutriscore != null
                                ? Image.asset(
                                    'assets/product/nutri_score_${product.nutriscore}.png',
                                    fit: BoxFit.fitWidth,
                                  )
                                : Row(
                                    children: <Widget>[
                                      Flexible(
                                        child: Text(
                                          'Nutri-score unavailable',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1
                                              .copyWith(
                                                  color: Colors.black,
                                                  fontSize: 12.0),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          Container(
                            height: 35.0,
                            width: 1.0,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            color: Colors.grey,
                          ),
                          Container(
                            width: 20.0,
                            height: 40.0,
                            child: product.nutriments.novaGroup != null
                                ? SvgPicture.asset(
                                    'assets/product/nova_group_${product.nutriments.novaGroup}.svg',
                                    fit: BoxFit.contain,
                                  )
                                : Container(),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.225,
                            margin: const EdgeInsets.only(left: 4.0),
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    product.nutriments.novaGroup != null
                                        ? _getNovaText(
                                            product.nutriments.novaGroup)
                                        : 'NOVA group unavailable',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(
                                            color: Colors.black,
                                            fontSize: 12.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 35.0,
                            width: 1.0,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            color: Colors.grey,
                          ),
                          Container(
                            width: 30.0,
                            height: 30.0,
                            decoration: BoxDecoration(
                              color: _getEnvironmentImpactColor(
                                  product.environmentImpactLevels),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(30.0)),
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
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getOldStyle(final BuildContext context) => GestureDetector(
        onTap: () {
          //_openSneakPeek(context);
          Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => ProductPage(
                      product: product,
                    )),
          );
        },
        child: Hero(
          tag: heroTag,
          child: Material(
            elevation: elevation,
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SmoothProductImage(
                        product: product,
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: 140.0,
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10.0),
                        padding: const EdgeInsets.only(top: 7.5),
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 140.0,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      child: Text(
                                        product.productName,
                                        maxLines: 3,
                                        overflow: TextOverflow.fade,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 4.0,
                                ),
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      child: Text(
                                        product.brands ?? 'Unknown brand',
                                        maxLines: 1,
                                        overflow: TextOverflow.fade,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w300,
                                            fontStyle: FontStyle.italic),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: 100.0,
                                  child: product.nutriscore != null
                                      ? Image.asset(
                                          'assets/product/nutri_score_${product.nutriscore}.png',
                                          fit: BoxFit.contain,
                                        )
                                      : Center(
                                          child: Text(
                                            'Nutri-score unavailable',
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  String _getNovaText(int novaGroup) {
    switch (novaGroup) {
      case 1:
        return 'Un-processed product';
        break;
      case 2:
        return 'Processed ingredient';
        break;
      case 3:
        return 'Processed product';
        break;
      case 4:
        return 'ultra-processed product';
        break;
      default:
        return '';
        break;
    }
  }

  Color _getEnvironmentImpactColor(
      EnvironmentImpactLevels environmentImpactLevels) {
    if (environmentImpactLevels == null ||
        environmentImpactLevels.levels.isEmpty) {
      return Colors.black.withAlpha(15);
    }

    switch (environmentImpactLevels.levels.first) {
      case Level.LOW:
        return Colors.green;
        break;
      case Level.MODERATE:
        return Colors.orange;
        break;
      case Level.HIGH:
        return Colors.red;
        break;
      case Level.UNDEFINED:
        return Colors.black.withAlpha(15);
        break;
      default:
        return Colors.black.withAlpha(15);
        break;
    }
  }

  /*void _openSneakPeek(BuildContext context) {
    Navigator.push<dynamic>(
        context,
        SmoothSneakPeekRoute<dynamic>(
            builder: (BuildContext context) {
              return Material(
                color: Colors.transparent,
                child: Center(
                  child: SmoothProductSneakPeekView(
                    product: product,
                    context: context,
                    heroTag: heroTag,
                  ),
                ),
              );
            },
            duration: 250));
  }*/
}
