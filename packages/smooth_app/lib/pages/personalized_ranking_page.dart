import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/personalized_search/matched_product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/smooth_it_model.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';

class PersonalizedRankingPage extends StatefulWidget {
  PersonalizedRankingPage({
    required final ProductList productList,
    required this.title,
  }) : products = productList.getList();

  const PersonalizedRankingPage.fromItems({
    required this.products,
    required this.title,
  });

  final List<Product> products;
  final String title;

  @override
  State<PersonalizedRankingPage> createState() =>
      _PersonalizedRankingPageState();
}

class _PersonalizedRankingPageState extends State<PersonalizedRankingPage> {
  static const Map<MatchTab, Color> _COLORS = <MatchTab, Color>{
    MatchTab.YES: Colors.green,
    MatchTab.MAYBE: Colors.grey,
    MatchTab.NO: Colors.red,
    MatchTab.ALL: Colors.black,
  };

  static const List<MatchTab> _ORDERED_MATCH_TABS = <MatchTab>[
    MatchTab.ALL,
    MatchTab.YES,
    MatchTab.NO,
    MatchTab.MAYBE,
  ];

  final SmoothItModel _model = SmoothItModel();

  @override
  Widget build(BuildContext context) {
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    _model.refresh(widget.products, productPreferences);
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final List<Color> colors = <Color>[];
    final List<String> titles = <String>[];
    final List<List<MatchedProduct>> matchedProductsList =
        <List<MatchedProduct>>[];
    for (final MatchTab matchTab in _ORDERED_MATCH_TABS) {
      final List<MatchedProduct> products = _model.getMatchedProducts(matchTab);
      matchedProductsList.add(products);
      titles.add(
        matchTab == MatchTab.ALL
            ? appLocalizations.ranking_tab_all
            : products.length.toString(),
      );
      colors.add(_COLORS[matchTab]!);
    }
    return DefaultTabController(
      length: _ORDERED_MATCH_TABS.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          bottom: TabBar(
            unselectedLabelStyle: const TextStyle(
              fontSize: 15,
            ),
            labelStyle: const TextStyle(
              fontSize: 20,
              decoration: TextDecoration.underline,
            ),
            indicator: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey), // provides to left side
                right: BorderSide(color: Colors.grey), // for right side
              ),
            ),
            isScrollable: false,
            tabs: <Tab>[
              ...List<Tab>.generate(
                _ORDERED_MATCH_TABS.length,
                (final int index) => Tab(
                  child: Text(
                    titles[index],
                    style: TextStyle(color: colors[index]),
                  ),
                ),
              ),
            ],
          ),
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Flexible(
                child: Text(widget.title, overflow: TextOverflow.fade),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: List<Widget>.generate(
            _ORDERED_MATCH_TABS.length,
            (final int index) => _getStickyHeader(
              _ORDERED_MATCH_TABS[index],
              matchedProductsList[index],
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
          final bool removed = widget.products.remove(matchedProduct.product);
          if (removed) {
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
    final MatchTab matchTab,
    final List<MatchedProduct> matchedProducts,
    final AppLocalizations appLocalizations,
    final DaoProductList daoProductList,
  ) {
    final Widget? subtitleWidget = _getSubtitleWidget(
      _COLORS[matchTab],
      _getSubtitle(matchTab, appLocalizations),
    );
    if (matchedProducts.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          subtitleWidget ?? Container(),
          Text(
            appLocalizations.no_product_in_section,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Container(),
        ],
      );
    }
    final int additional = subtitleWidget == null ? 0 : 1;
    return ListView.builder(
      itemCount: matchedProducts.length + additional,
      itemBuilder: (BuildContext context, int index) => index < additional
          ? subtitleWidget!
          : _buildSmoothProductCard(
              matchedProducts[index - additional],
              daoProductList,
              appLocalizations,
            ),
    );
  }

  Widget? _getSubtitleWidget(
    final Color? color,
    final String? subtitle,
  ) =>
      subtitle == null
          ? null
          : Container(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              color: color,
            );

  String? _getSubtitle(
    final MatchTab matchTab,
    final AppLocalizations appLocalizations,
  ) {
    switch (matchTab) {
      case MatchTab.ALL:
        return null;
      case MatchTab.MAYBE:
        return appLocalizations.ranking_subtitle_match_maybe;
      case MatchTab.YES:
        return appLocalizations.ranking_subtitle_match_yes;
      case MatchTab.NO:
        return appLocalizations.ranking_subtitle_match_no;
    }
  }
}
