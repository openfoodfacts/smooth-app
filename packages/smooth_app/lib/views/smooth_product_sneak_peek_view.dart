import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/data_cards/smooth_data_card.dart';
import 'package:smooth_app/cards/data_cards/smooth_energy_card.dart';
import 'package:smooth_app/cards/data_cards/smooth_intake_recommendation_card.dart';
import 'package:smooth_app/cards/data_cards/smooth_quantity_selector_card.dart';
import 'package:smooth_app/data_models/sneak_peek_model.dart';
import 'package:smooth_ui_library/widgets/smooth_product_image.dart';

class SmoothProductSneakPeekView extends StatelessWidget {
  const SmoothProductSneakPeekView(
      {@required this.product, @required this.context, @required this.heroTag});

  final Product product;
  final BuildContext context;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
            padding:
                const EdgeInsets.only(right: 15.0, left: 15.0, bottom: 30.0),
            child: ChangeNotifierProvider<SneakPeakModel>(
              create: (BuildContext context) => SneakPeakModel(product),
              child: Consumer<SneakPeakModel>(
                builder: (BuildContext context, SneakPeakModel sneakPeakModel,
                    Widget child) {
                  return _generateSneakPeakBoard(sneakPeakModel);
                },
              ),
            )),
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Hero(
                tag: heroTag,
                child: Container(
                  margin: const EdgeInsets.all(15.0),
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
                            width: 100.0,
                            height: 120.0,
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 10.0),
                            padding: const EdgeInsets.only(top: 7.5),
                            width: 150.0,
                            height: 120.0,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Text(
                                          product.productName,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
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
                                      child: Material(
                                          color: Colors.transparent,
                                          child: Text(
                                            product.brands ?? 'Unknown brand',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w300,
                                                fontStyle: FontStyle.italic),
                                          )),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 8.0,
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
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                          ),
                          Container(
                            width: 50.0,
                            height: 50.0,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15.0)),
                              color: Colors.white,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 16.0,
                                  offset: const Offset(4.0, 4.0),
                                )
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.remove,
                                size: 32.0,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _generateSneakPeakBoard(SneakPeakModel sneakPeakModel) {
    final Map<Widget, SmoothDataCardFormat> board =
        <Widget, SmoothDataCardFormat>{
      SmoothEnergyCard(
        sneakPeakModel: sneakPeakModel,
      ): SmoothDataCardFormat.SQUARE,
      SmoothQuantitySelectorCard(
        sneakPeakModel: sneakPeakModel,
      ): SmoothDataCardFormat.SQUARE,
      SmoothIntakeRecommendationCard(
        sneakPeakModel: sneakPeakModel,
      ): SmoothDataCardFormat.WIDE,
    };

    final List<Widget> boardCards = board.keys.toList();

    return StaggeredGridView.countBuilder(
      crossAxisCount: 2,
      itemCount: boardCards.length + 1,
      reverse: true,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return const SizedBox(
            height: 200.0,
          );
        }
        return boardCards[index - 1];
      },
      staggeredTileBuilder: (int index) {
        if (index == 0) {
          return const StaggeredTile.fit(2);
        }
        return StaggeredTile.count(
            board[boardCards[index - 1]] == SmoothDataCardFormat.SQUARE ? 1 : 2,
            1);
      },
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
    );
  }
}
