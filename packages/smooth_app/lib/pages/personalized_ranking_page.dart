// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:smooth_app/bottom_sheet_views/user_preferences_view.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/smooth_it_model.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:smooth_app/pages/product_query_page_helper.dart';
import 'package:smooth_app/structures/ranked_product.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

class PersonalizedRankingPage extends StatefulWidget {
  const PersonalizedRankingPage(this.productList);

  final ProductList productList;

  @override
  _PersonalizedRankingPageState createState() =>
      _PersonalizedRankingPageState();
}

class _PersonalizedRankingPageState extends State<PersonalizedRankingPage> {
  static const List<int> _ORDERED_MATCH_INDEXES = <int>[
    SmoothItModel.MATCH_INDEX_ALL,
    SmoothItModel.MATCH_INDEX_YES,
    SmoothItModel.MATCH_INDEX_MAYBE,
    SmoothItModel.MATCH_INDEX_NO,
  ];

  static const Map<int, IconData> _ICONS = <int, IconData>{
    SmoothItModel.MATCH_INDEX_ALL: Icons.sort,
    SmoothItModel.MATCH_INDEX_YES: Icons.check_circle,
    SmoothItModel.MATCH_INDEX_MAYBE: CupertinoIcons.question_diamond,
    SmoothItModel.MATCH_INDEX_NO: Icons.cancel,
  };

  static const Map<int, MaterialColor> _COLORS = <int, MaterialColor>{
    SmoothItModel.MATCH_INDEX_YES: Colors.green,
    SmoothItModel.MATCH_INDEX_MAYBE: Colors.grey,
    SmoothItModel.MATCH_INDEX_NO: Colors.red,
  };

  final SmoothItModel _model = SmoothItModel();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final UserPreferencesModel userPreferencesModel =
        context.watch<UserPreferencesModel>();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    _model.refresh(widget.productList, userPreferences, userPreferencesModel);
    final List<BottomNavigationBarItem> bottomNavigationBarItems =
        <BottomNavigationBarItem>[];
    for (final int matchIndex in _ORDERED_MATCH_INDEXES) {
      bottomNavigationBarItems.add(
        BottomNavigationBarItem(
          icon: Icon(
            _ICONS[matchIndex],
            color: _COLORS[matchIndex] == null
                ? null
                : SmoothTheme.getColor(
                    colorScheme,
                    _COLORS[matchIndex],
                    ColorDestination.SURFACE_FOREGROUND,
                  ),
          ),
          label: _model.getRankedProducts(matchIndex).length.toString(),
        ),
      );
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          ProductQueryPageHelper.getProductListLabel(widget.productList),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => UserPreferencesView.showModal(
              context,
              callback: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reloaded with new preferences'),
                    duration: Duration(milliseconds: 1500),
                  ),
                );
              },
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentTabIndex,
        items: bottomNavigationBarItems,
        onTap: (int tapped) => setState(() {
          _currentTabIndex = tapped;
          _model.setNextRefreshAsJustChangingTabs();
        }),
      ),
      body: _getStickyHeader(
        _model.getRankedProducts(_ORDERED_MATCH_INDEXES[_currentTabIndex]),
        colorScheme,
      ),
    );
  }

  Widget _buildSmoothProductCard(
    final RankedProduct rankedProduct,
    final ColorScheme colorScheme,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: SmoothProductCardFound(
          heroTag: rankedProduct.product.barcode,
          product: rankedProduct.product,
          elevation: 4.0,
          backgroundColor: SmoothTheme.getColor(
            colorScheme,
            _COLORS[SmoothItModel.getMatchIndex(rankedProduct)],
            ColorDestination.SURFACE_BACKGROUND,
          ),
        ),
      );

  Widget _getStickyHeader(
    final List<RankedProduct> products,
    final ColorScheme colorScheme,
  ) =>
      products.isEmpty
          ? Center(
              child: Text('There is no product in this section',
                  style: Theme.of(context).textTheme.subtitle1),
            )
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) =>
                  _buildSmoothProductCard(products[index], colorScheme),
            );
}
