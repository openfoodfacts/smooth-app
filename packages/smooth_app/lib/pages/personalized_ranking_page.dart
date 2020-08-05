import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/data_models/smooth_it_model.dart';
import 'package:smooth_app/structures/ranked_product.dart';
import 'package:smooth_app/temp/filter_ranking_helper.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

class PersonalizedRankingPage extends StatelessWidget {
  const PersonalizedRankingPage({@required this.input});

  final List<Product> input;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SmoothItModel>(
      create: (BuildContext context) => SmoothItModel(input),
      child: Consumer<SmoothItModel>(
        builder: (BuildContext context, SmoothItModel personalizedRakingModel,
            Widget child) {
          return Scaffold(
              body: Stack(
            children: <Widget>[
              Container(
                  padding:
                      const EdgeInsets.only(left: 10.0, right: 10.0, top: 96.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 80.0,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                              child: AnimatedOpacity(
                                  opacity: personalizedRakingModel.showTitle
                                      ? 1.0
                                      : 0.0,
                                  duration: const Duration(milliseconds: 250),
                                  child: Text('My personalized ranking',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline1)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
              StickyGroupedListView<RankedProduct, String>(
                elements: personalizedRakingModel.products,
                groupBy: (RankedProduct element) => element.type.toString(),
                groupSeparatorBuilder: (RankedProduct element) => Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 40.0,
                      margin: const EdgeInsets.only(top: 32.0, bottom: 8.0),
                      decoration: BoxDecoration(
                          color: FilterRankingHelper.getRankingTypeColor(
                              element.type),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50.0))),
                      child: Center(
                        child: Text(
                            FilterRankingHelper.getRankingTypeTitle(
                                element.type),
                            style: Theme.of(context)
                                .textTheme
                                .headline3
                                .copyWith(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                itemBuilder: (BuildContext context, RankedProduct element) =>
                    Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  child: SmoothProductCardFound(
                          heroTag: element.product.barcode,
                          product: element.product,
                          elevation: 4.0)
                      .build(context),
                ),
                itemScrollController: GroupedItemScrollController(),
                order: StickyGroupedListOrder.ASC,
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.25),
              ),
              AnimatedOpacity(
                opacity: personalizedRakingModel.showTitle ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 28.0),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));
        },
      ),
    );
  }
}
