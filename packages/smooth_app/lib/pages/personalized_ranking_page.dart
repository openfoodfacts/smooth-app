import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/data_models/smooth_it_model.dart';
import 'package:smooth_app/temp/filter_ranking_helper.dart';
import 'package:smooth_ui_library/widgets/smooth_sticky_list_view.dart';

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
              SmoothStickyListView(
                itemCount: personalizedRakingModel.products.length,
                hasSameHeader: (int indexA, int indexB) {
                  return personalizedRakingModel.products[indexA].type ==
                      personalizedRakingModel.products[indexB].type;
                },
                headerBuilder: (BuildContext context, int index) => Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 40.0,
                      margin: const EdgeInsets.only(top: 32.0, bottom: 8.0),
                      decoration: BoxDecoration(
                          color: FilterRankingHelper.getRankingTypeColor(
                              personalizedRakingModel.products[index].type),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50.0))),
                      child: Center(
                        child: Text(
                            FilterRankingHelper.getRankingTypeTitle(
                                personalizedRakingModel.products[index].type),
                            style: Theme.of(context)
                                .textTheme
                                .headline3
                                .copyWith(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                itemBuilder: (BuildContext context, int index) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  child: SmoothProductCardFound(
                          heroTag: personalizedRakingModel
                              .products[index].product.barcode,
                          product:
                              personalizedRakingModel.products[index].product,
                          elevation: 4.0)
                      .build(context),
                ),
                headerPadding: const EdgeInsets.only(
                    top: 0.0, left: 42.0),
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.25),
                itemExtend: 140.0,
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
}
