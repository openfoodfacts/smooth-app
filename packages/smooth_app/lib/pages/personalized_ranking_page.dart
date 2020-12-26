import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/bottom_sheet_views/user_preferences_view.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/data_models/smooth_it_model.dart';
import 'package:smooth_app/structures/ranked_product.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PersonalizedRankingPage extends StatelessWidget {
  const PersonalizedRankingPage({@required this.input});

  final List<Product> input;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SmoothItModel>(
      create: (BuildContext context) => SmoothItModel(input, context),
      child: Consumer<SmoothItModel>(
        builder: (BuildContext context, SmoothItModel personalizedRankingModel,
            Widget child) {
          return Scaffold(
            key: personalizedRankingModel.scaffoldKey,
            floatingActionButton: AnimatedOpacity(
              opacity: !personalizedRankingModel.showTitle ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: FloatingActionButton(
                heroTag: 'do_not_use_hero_animation',
                child: const Icon(Icons.arrow_upward),
                onPressed: () {
                  personalizedRankingModel.scrollController.animateTo(0.0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.ease);
                },
              ),
            ),
            body:
                _buildGroupedStickyListView(context, personalizedRankingModel),
            /*Stack(
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 96.0),
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
                                      opacity: personalizedRankingModel.showTitle
                                          ? 1.0
                                          : 0.0,
                                      duration:
                                          const Duration(milliseconds: 250),
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
                  _buildGroupedStickyListView(context, personalizedRankingModel),
                  AnimatedOpacity(
                    opacity: personalizedRankingModel.showTitle ? 1.0 : 0.0,
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
                        Padding(
                          padding: const EdgeInsets.only(top: 28.0),
                          child: IconButton(
                            icon: const Icon(
                              Icons.settings,
                            ),
                            onPressed: () =>
                                showCupertinoModalBottomSheet<Widget>(
                              expand: false,
                              context: context,
                              backgroundColor: Colors.transparent,
                              bounce: true,
                              barrierColor: Colors.black45,
                              builder: (BuildContext context,
                                      ScrollController scrollController) =>
                                  UserPreferencesView(scrollController,
                                      callback: () {
                                personalizedRankingModel.processProductList();
                                const SnackBar snackBar = SnackBar(
                                  content: Text(
                                    'Reloaded with new preferences',
                                  ),
                                  duration: Duration(milliseconds: 1500),
                                );
                                personalizedRankingModel.scaffoldKey.currentState
                                    .showSnackBar(snackBar);
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )*/
          );
        },
      ),
    );
  }

  Widget _buildSmoothProductCard(
      RankedProduct rankedProduct, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        children: <Widget>[
          //Text(rankedProduct.score.toString()),
          SmoothProductCardFound(
                  heroTag: rankedProduct.product.barcode,
                  product: rankedProduct.product,
                  elevation: 4.0)
              .build(context),
        ],
      ),
    );
  }

  Widget _buildGroupedStickyListView(
      BuildContext context, SmoothItModel personalizedRankingModel) {
    if (!personalizedRankingModel.dataLoaded) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(
          top: personalizedRankingModel.showTitle
              ? MediaQuery.of(context).size.height * 0.0
              : 0.0),
      child: CustomScrollView(
        controller: personalizedRankingModel.scrollController,
        slivers: <Widget>[
          SliverAppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            snap: true,
            elevation: 8,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text('My personalized ranking',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(color: Colors.black)),
            ),
            actions: <IconButton>[
              IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: Colors.black,
                ),
                onPressed: () => showCupertinoModalBottomSheet<Widget>(
                  expand: false,
                  context: context,
                  backgroundColor: Colors.transparent,
                  bounce: true,
                  barrierColor: Colors.black45,
                  builder: (BuildContext context,
                          ScrollController scrollController) =>
                      UserPreferencesView(scrollController, callback: () {
                    personalizedRankingModel.processProductList(context);
                    const SnackBar snackBar = SnackBar(
                      content: Text(
                        'Reloaded with new preferences',
                      ),
                      duration: Duration(milliseconds: 1500),
                    );
                    personalizedRankingModel.scaffoldKey.currentState
                        .showSnackBar(snackBar);
                  }),
                ),
              )
            ],
          ),
          SliverStickyHeader(
            header: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 40.0,
                  margin: const EdgeInsets.only(top: 32.0, bottom: 8.0),
                  decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.all(Radius.circular(50.0))),
                  child: Center(
                    child: Text(
                        'Products', // TODO(monsieurtanuki): better text?
                        style: Theme.of(context)
                            .textTheme
                            .headline3
                            .copyWith(color: Colors.white)),
                  ),
                ),
              ],
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) =>
                    personalizedRankingModel.products.first.product == null
                        ? Container(
                            height: 80.0,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                      'There is no product in this section',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .copyWith(color: Colors.black)),
                                )
                              ],
                            ),
                          )
                        : _buildSmoothProductCard(
                            personalizedRankingModel.products[index], context),
                childCount: personalizedRankingModel.products.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
