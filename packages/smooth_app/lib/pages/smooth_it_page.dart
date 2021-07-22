/*import 'package:flutter/material.dart';

// Package imports:
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/data_models/smooth_it_model.dart';
import 'package:smooth_app/temp/filter_ranking_helper.dart';

class SmoothItPage extends StatelessWidget {
  const SmoothItPage({required this.input});

  final List<Product> input;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SmoothItModel>(
      create: (BuildContext context) => SmoothItModel(input),
      child: Consumer<SmoothItModel>(
        builder:
            (BuildContext context, SmoothItModel smoothItModel, Widget child) {
          return smoothItModel.dataLoaded
              ? DefaultTabController(
                  length: 3,
                  child: Scaffold(
                    appBar: AppBar(
                      title: const Text('My personalized ranking'),
                      backgroundColor: Colors.black,
                      bottom: const TabBar(
                        tabs: <Tab>[
                          Tab(text: 'Top Picks',),
                          Tab(text: 'Contenders',),
                          Tab(text: 'Dismissed',),
                        ],
                      ),
                    ),
                    body: TabBarView(
                      children: <Widget>[
                        _generateProductCardList(smoothItModel.products[RankingType.TOP_PICKS], 'top_picks'),
                        _generateProductCardList(smoothItModel.products[RankingType.CONTENDERS], 'contenders'),
                        _generateProductCardList(smoothItModel.products[RankingType.DISMISSED], 'dismissed'),
                      ],
                    ),
                  ),
                )
              : const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
        },
      ),
    );
  }

  Widget _generateProductCardList(List<Product> products, String tag) {
    return products.isNotEmpty ? ListView.builder(
      itemCount: products.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: SmoothProductCardFound(product: products[index], heroTag: '${tag}_card_$index', elevation: 8.0).build(context),
        );
      }
    ) : const Center(
      child: Text('No product in this selection'),
    );
  }
}*/
