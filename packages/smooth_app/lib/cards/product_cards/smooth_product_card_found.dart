import 'dart:ui';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/pages/product_page.dart';
import 'package:smooth_ui_library/widgets/smooth_product_image.dart';
import 'package:smooth_app/cards/category_cards/attribute_card.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';

class SmoothProductCardFound extends StatelessWidget {
  const SmoothProductCardFound({
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

    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final UserPreferencesModel userPreferencesModel =
        context.watch<UserPreferencesModel>();

    final List<String> orderedVariables =
        userPreferencesModel.getOrderedVariables(userPreferences);
    final List<Widget> scores = <Widget>[];
    for (final String variable in orderedVariables) {
      if (scores.isNotEmpty) {
        scores.add(_getDivider());
      }
      scores.add(AttributeCard(product, variable));
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

  Widget _getDivider() => Container(
        height: 35.0,
        width: 1.0,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        color: Colors.grey,
      );

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
}
