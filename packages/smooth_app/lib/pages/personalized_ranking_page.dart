import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/data_models/smooth_it_model.dart';
import 'package:smooth_app/structures/ranked_product.dart';
import 'package:smooth_app/temp/filter_ranking_helper.dart';
import 'package:sticky_headers/sticky_headers.dart';

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
              ListView.builder(
                itemCount: personalizedRakingModel.products.length,
                itemBuilder: (BuildContext context, int index) {
                  final RankedProduct rankedProduct =
                      personalizedRakingModel.products[index];
                  if (rankedProduct.isHeader) {
                    return StickyHeader(
                      header: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: 40.0,
                            margin:
                                const EdgeInsets.only(top: 32.0, bottom: 8.0),
                            decoration: BoxDecoration(
                                color: FilterRankingHelper.getRankingTypeColor(
                                    rankedProduct.type),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(50.0))),
                            child: Center(
                              child: Text(
                                  FilterRankingHelper.getRankingTypeTitle(
                                      rankedProduct.type),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline3
                                      .copyWith(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                      content: rankedProduct.product != null
                          ? _buildSmoothProductCard(
                              rankedProduct.product, context)
                          : Container(
                              height: 80.0,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Flexible(
                                    child: Text(
                                        'There is no product in this section', style: Theme.of(context)
                                        .textTheme
                                        .subtitle1.copyWith(color: Colors.black)),
                                  )
                                ],
                              ),
                            ),
                    );
                  }
                  return _buildSmoothProductCard(
                      rankedProduct.product, context);
                },
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.25),
                controller: personalizedRakingModel.scrollController,
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
                        icon: const Icon(
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

  Widget _buildSmoothProductCard(Product product, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: SmoothProductCardFound(
              heroTag: product.barcode, product: product, elevation: 4.0)
          .build(context),
    );
  }
}
