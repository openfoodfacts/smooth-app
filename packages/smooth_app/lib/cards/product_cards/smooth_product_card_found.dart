import 'dart:ui';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/pages/product_page.dart';
import 'package:smooth_ui_library/widgets/smooth_product_image.dart';
import 'package:smooth_app/cards/data_cards/attribute_chip.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:openfoodfacts/model/Attribute.dart';

class SmoothProductCardFound extends StatelessWidget {
  const SmoothProductCardFound({
    @required this.product,
    @required this.heroTag,
    this.elevation = 0.0,
    this.useNewStyle = true,
    this.translucentBackground = false,
    this.backgroundColor = Colors.white,
  });

  final Product product;
  final String heroTag;
  final double elevation;
  final bool useNewStyle;
  final bool translucentBackground;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    if (!useNewStyle) {
      return _getOldStyle(context);
    }

    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final UserPreferencesModel userPreferencesModel =
        context.watch<UserPreferencesModel>();
    final Size screenSize = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);

    final List<String> orderedVariables =
        userPreferencesModel.getOrderedVariables(userPreferences);
    final List<Widget> scores = <Widget>[];
    final double iconSize =
        screenSize.width / 10; // TODO(monsieurtanuki): target size?
    for (final String variable in orderedVariables) {
      final Attribute attribute =
          UserPreferencesModel.getAttribute(product, variable);
      scores.add(AttributeChip(attribute, height: iconSize));
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
      onLongPress: () => ProductPage.showLists(product, context),
      child: Hero(
        tag: heroTag,
        child: Material(
          elevation: elevation,
          borderRadius: const BorderRadius.all(Radius.circular(15.0)),
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: translucentBackground
                  ? backgroundColor.withOpacity(0.25)
                  : backgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            ),
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SmoothProductImage(
                  product: product,
                  width: screenSize.width * 0.20,
                  height: screenSize.width * 0.20,
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
                      width: screenSize.width * 0.65,
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  product.productName ?? 'Unknown product name',
                                  maxLines: 2,
                                  overflow: TextOverflow.fade,
                                  style: themeData.textTheme.headline4
                                      .copyWith(color: Colors.black),
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
                                  style: themeData.textTheme.subtitle1,
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
                      width: screenSize.width * 0.65,
                      child: Wrap(
                        direction: Axis.horizontal,
                        children: scores,
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
                                      ? SvgPicture.network(
                                          'https://static.openfoodfacts.org/images/misc/nutriscore-${product.nutriscore}.svg',
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
}
