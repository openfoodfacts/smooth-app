// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:rubber/rubber.dart';
import 'package:smooth_ui_library/widgets/smooth_product_image.dart';

// Project imports:
import 'package:smooth_app/cards/data_cards/attribute_chip.dart';
import 'package:smooth_app/cards/data_cards/smooth_data_card.dart';
import 'package:smooth_app/cards/data_cards/smooth_energy_card.dart';
import 'package:smooth_app/cards/data_cards/smooth_intake_recommendation_card.dart';
import 'package:smooth_app/cards/data_cards/smooth_quantity_selector_card.dart';
import 'package:smooth_app/data_models/sneak_peek_model.dart';
import 'package:smooth_app/temp/product_extra.dart';
import 'package:smooth_app/temp/attribute_group_referential.dart';

// TODO(stephanegigandet): remove if not useful anymore?
@deprecated
class SmoothProductSneakPeekView extends StatefulWidget {
  const SmoothProductSneakPeekView(
      {@required this.product, @required this.context, @required this.heroTag});

  final Product product;
  final BuildContext context;
  final String heroTag;

  @override
  State<StatefulWidget> createState() => SmoothProductSneakPeekViewState();
}

// TODO(stephanegigandet): remove if not useful anymore?
@deprecated
class SmoothProductSneakPeekViewState extends State<SmoothProductSneakPeekView>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SneakPeakModel>(
      create: (BuildContext context) => SneakPeakModel(
          widget.product,
          RubberAnimationController(
              vsync: this, duration: const Duration(milliseconds: 200))),
      child: Consumer<SneakPeakModel>(builder:
          (BuildContext context, SneakPeakModel sneakPeakModel, Widget child) {
        return RubberBottomSheet(
          lowerLayer: Padding(
            padding:
                const EdgeInsets.only(right: 15.0, left: 15.0, bottom: 30.0),
            child: _generateSneakPeakBoard(sneakPeakModel),
          ),
          headerHeight: 220.0,
          header: Container(
            height: 220.0,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0)),
            ),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: 4.0,
                      margin: const EdgeInsets.only(bottom: 8.0),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        color: Colors.black26,
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SmoothProductImage(
                      product: widget.product,
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
                                    widget.product.productName,
                                    style: const TextStyle(
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
                                      widget.product.brands ?? 'Unknown brand',
                                      style: const TextStyle(
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
                    AttributeChip(
                      ProductExtra.getAttribute(widget.product,
                          AttributeGroupReferential.ATTRIBUTE_NUTRISCORE),
                      width: 100.0,
                    ),
                    Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 16.0,
                            offset: Offset(4.0, 4.0),
                          )
                        ],
                      ),
                      child: const Center(
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
          animationController: sneakPeakModel.rubberAnimationController,
          upperLayer: Container(
            color: Colors.white,
          ),
        );
      }),
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
