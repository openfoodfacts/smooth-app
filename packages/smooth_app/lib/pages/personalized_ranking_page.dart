import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/personalized_search/matched_product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/smooth_it_model.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';

class PersonalizedRankingPage extends StatefulWidget {
  const PersonalizedRankingPage(this.productList);

  final ProductList productList;

  @override
  State<PersonalizedRankingPage> createState() =>
      _PersonalizedRankingPageState();
}

class _PersonalizedRankingPageState extends State<PersonalizedRankingPage> {
  static const Map<int, Color> _COLORS = <int, Color>{
    SmoothItModel.MATCH_INDEX_YES: Colors.green,
    SmoothItModel.MATCH_INDEX_MAYBE: Colors.grey,
    SmoothItModel.MATCH_INDEX_NO: Colors.red,
    SmoothItModel.MATCH_INDEX_ALL: Colors.black,
  };

  static const List<int> _ORDERED_MATCH_INDEXES = <int>[
    SmoothItModel.MATCH_INDEX_ALL,
    SmoothItModel.MATCH_INDEX_YES,
    SmoothItModel.MATCH_INDEX_NO,
    SmoothItModel.MATCH_INDEX_MAYBE,
  ];

  final SmoothItModel _model = SmoothItModel();
  final List<List<MatchedProduct>> _matchedProducts = <List<MatchedProduct>>[];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    _model.refresh(widget.productList, productPreferences);
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final List<String> titles = <String>[];
    _matchedProducts.clear();
    for (int i = 0; i < _ORDERED_MATCH_INDEXES.length; i++) {
      final int matchIndex = _ORDERED_MATCH_INDEXES[i];
      final List<MatchedProduct> products =
          _model.getMatchedProducts(matchIndex);
      _matchedProducts.add(products);
      titles.add(
        matchIndex == SmoothItModel.MATCH_INDEX_ALL
            ? appLocalizations.ranking_tab_all
            : products.length.toString(),
      );
    }
    return DefaultTabController(
      length: _ORDERED_MATCH_INDEXES.length,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          bottom: TabBar(
            indicator: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey), // provides to left side
                right: BorderSide(color: Colors.grey), // for right side
              ),
            ),
            isScrollable: false,
            tabs: <Tab>[
              ...List<Tab>.generate(
                _ORDERED_MATCH_INDEXES.length,
                (final int index) => Tab(
                  child: Text(
                    titles[index],
                    style: TextStyle(
                      color: _COLORS[_ORDERED_MATCH_INDEXES[index]],
                    ),
                  ),
                ),
              ),
            ],
          ),
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Flexible(
                child: Text(
                  ProductQueryPageHelper.getProductListLabel(
                    widget.productList,
                    context,
                  ),
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: List<Widget>.generate(
            _ORDERED_MATCH_INDEXES.length,
            (final int index) => _getStickyHeader(
              _ORDERED_MATCH_INDEXES[index],
              appLocalizations,
              daoProductList,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmoothProductCard(
    final MatchedProduct matchedProduct,
    final DaoProductList daoProductList,
    final AppLocalizations appLocalizations,
  ) =>
      Dismissible(
        key: Key(matchedProduct.product.barcode!),
        onDismissed: (final DismissDirection direction) async {
          final bool removed =
              widget.productList.remove(matchedProduct.product.barcode!);
          if (removed) {
            await daoProductList.put(widget.productList);
            setState(() {});
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                removed
                    ? appLocalizations.product_removed
                    : appLocalizations.product_could_not_remove,
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: SmoothProductCardFound(
            heroTag: matchedProduct.product.barcode!,
            product: matchedProduct.product,
            elevation: 4.0,
          ),
        ),
      );

  Widget _getStickyHeader(
    final int matchIndex,
    final AppLocalizations appLocalizations,
    final DaoProductList daoProductList,
  ) {
    final List<MatchedProduct> matchedProducts = _matchedProducts[matchIndex];
    if (matchedProducts.isEmpty) {
      return Center(
        child: Text(appLocalizations.no_product_in_section,
            style: Theme.of(context).textTheme.subtitle1),
      );
    }
    final String? subtitle = _getSubtitle(matchIndex, appLocalizations);
    final int additional = subtitle == null ? 0 : 1;
    return ListView.builder(
      itemCount: matchedProducts.length + additional,
      itemBuilder: (BuildContext context, int index) => index < additional
          ? Container(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Text(
                  subtitle!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              color: _COLORS[matchIndex],
            )
          : _buildSmoothProductCard(
              matchedProducts[index - additional],
              daoProductList,
              appLocalizations,
            ),
    );
  }

  String? _getSubtitle(
    final int matchIndex,
    final AppLocalizations appLocalizations,
  ) {
    switch (matchIndex) {
      case SmoothItModel.MATCH_INDEX_ALL:
      case SmoothItModel.MATCH_INDEX_MAYBE:
        return null;
      case SmoothItModel.MATCH_INDEX_YES:
        return appLocalizations.ranking_subtitle_match_yes;
      case SmoothItModel.MATCH_INDEX_NO:
        return appLocalizations.ranking_subtitle_match_no;
    }
  }
}
