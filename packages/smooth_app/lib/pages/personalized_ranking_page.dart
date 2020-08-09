import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/bottom_sheet_views/user_preferences_view.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/data_models/smooth_it_model.dart';
import 'package:smooth_app/temp/filter_ranking_helper.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

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
            key: personalizedRakingModel.scaffoldKey,
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
              _buildGroupedStickyListView(context, personalizedRakingModel),
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
                    Padding(
                      padding: const EdgeInsets.only(top: 28.0),
                      child: IconButton(
                        icon: const Icon(
                          Icons.settings,
                        ),
                        onPressed: () => showCupertinoModalBottomSheet<Widget>(
                          expand: false,
                          context: context,
                          backgroundColor: Colors.transparent,
                          bounce: true,
                          barrierColor: Colors.black45,
                          builder: (BuildContext context, ScrollController scrollController) =>
                              UserPreferencesView(scrollController, callback: () {
                                personalizedRakingModel.processProductList();
                                const SnackBar snackBar = SnackBar(content: Text('Reloaded with new preferences',), duration: Duration(milliseconds: 1500),);
                                personalizedRakingModel.scaffoldKey.currentState.showSnackBar(snackBar);
                              }),
                        ),
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

  Widget _buildGroupedStickyListView(BuildContext context, SmoothItModel personalizedRakingModel) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(top: personalizedRakingModel.showTitle ? MediaQuery.of(context).size.height * 0.2 : 0.0),
      child: CustomScrollView(
        controller: personalizedRakingModel.scrollController,
        slivers: <Widget>[
          SliverStickyHeader(
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
                      color: FilterRankingHelper.getRankingTypeColor(RankingType.TOP_PICKS),
                      borderRadius: const BorderRadius.all(
                          Radius.circular(50.0))),
                  child: Center(
                    child: Text(
                        FilterRankingHelper.getRankingTypeTitle(RankingType.TOP_PICKS),
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
                    (BuildContext context, int index) => personalizedRakingModel.topPicks.first.product == null ? Container(
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
                ) : _buildSmoothProductCard(
                    personalizedRakingModel.topPicks[index].product, context),
                childCount: personalizedRakingModel.topPicks.length,
              ),
            ),
          ),
          SliverStickyHeader(
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
                      color: FilterRankingHelper.getRankingTypeColor(RankingType.CONTENDERS),
                      borderRadius: const BorderRadius.all(
                          Radius.circular(50.0))),
                  child: Center(
                    child: Text(
                        FilterRankingHelper.getRankingTypeTitle(RankingType.CONTENDERS),
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
                    (BuildContext context, int index) => personalizedRakingModel.contenders.first.product == null ? Container(
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
                ) : _buildSmoothProductCard(
                    personalizedRakingModel.contenders[index].product, context),
                childCount: personalizedRakingModel.contenders.length,
              ),
            ),
          ),
          SliverStickyHeader(
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
                      color: FilterRankingHelper.getRankingTypeColor(RankingType.DISMISSED),
                      borderRadius: const BorderRadius.all(
                          Radius.circular(50.0))),
                  child: Center(
                    child: Text(
                        FilterRankingHelper.getRankingTypeTitle(RankingType.DISMISSED),
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
                    (BuildContext context, int index) => personalizedRakingModel.dismissed.first.product == null ? Container(
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
                ) : _buildSmoothProductCard(
                    personalizedRakingModel.dismissed[index].product, context),
                childCount: personalizedRakingModel.dismissed.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
