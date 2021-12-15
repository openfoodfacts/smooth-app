import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/personalized_search/matched_product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/smooth_it_model.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/user_preferences_page.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

class PersonalizedRankingPage extends StatefulWidget {
  const PersonalizedRankingPage(this.productList);

  final ProductList productList;

  @override
  State<PersonalizedRankingPage> createState() =>
      _PersonalizedRankingPageState();

  static const Map<int, MaterialColor> _COLORS = <int, MaterialColor>{
    SmoothItModel.MATCH_INDEX_YES: Colors.green,
    SmoothItModel.MATCH_INDEX_MAYBE: Colors.grey,
    SmoothItModel.MATCH_INDEX_NO: Colors.red,
  };

  static Color? getColor({
    required final ColorScheme colorScheme,
    final int? matchIndex,
    required final ColorDestination colorDestination,
  }) =>
      _COLORS[matchIndex] == null
          ? null
          : SmoothTheme.getColor(
              colorScheme,
              _COLORS[matchIndex]!,
              colorDestination,
            );
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

  final SmoothItModel _model = SmoothItModel();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    _model.refresh(widget.productList, productPreferences);
    final List<BottomNavigationBarItem> bottomNavigationBarItems =
        <BottomNavigationBarItem>[];
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    for (final int matchIndex in _ORDERED_MATCH_INDEXES) {
      bottomNavigationBarItems.add(
        BottomNavigationBarItem(
          icon: Icon(
            _ICONS[matchIndex],
            color: PersonalizedRankingPage.getColor(
              colorScheme: colorScheme,
              matchIndex: matchIndex,
              colorDestination: ColorDestination.SURFACE_FOREGROUND,
            ),
          ),
          label: _model.getMatchedProducts(matchIndex).length.toString(),
        ),
      );
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
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
        actions: <Widget>[
          IconButton(
            icon: SvgPicture.asset(
              'assets/actions/food-cog.svg',
              color: Colors.white,
            ),
            onPressed: () async {
              await Navigator.push<Widget>(
                context,
                MaterialPageRoute<Widget>(
                  builder: (BuildContext context) =>
                      const UserPreferencesPage(),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(appLocalizations.reloaded_with_new_preferences),
                  duration: const Duration(milliseconds: 1500),
                ),
              );
            },
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
        _model.getMatchedProducts(_ORDERED_MATCH_INDEXES[_currentTabIndex]),
        colorScheme,
        appLocalizations,
        daoProductList,
      ),
    );
  }

  Widget _buildSmoothProductCard(
    final MatchedProduct matchedProduct,
    final ColorScheme colorScheme,
    final DaoProductList daoProductList,
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
                  removed ? 'Product removed' : 'Could not remove product'),
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
            backgroundColor: PersonalizedRankingPage.getColor(
              colorScheme: colorScheme,
              matchIndex: SmoothItModel.getMatchIndex(matchedProduct),
              colorDestination: ColorDestination.SURFACE_BACKGROUND,
            ),
          ),
        ),
      );

  Widget _getStickyHeader(
    final List<MatchedProduct> matchedProducts,
    final ColorScheme colorScheme,
    final AppLocalizations appLocalizations,
    final DaoProductList daoProductList,
  ) =>
      matchedProducts.isEmpty
          ? Center(
              child: Text(appLocalizations.no_product_in_section,
                  style: Theme.of(context).textTheme.subtitle1),
            )
          : ListView.builder(
              itemCount: matchedProducts.length,
              itemBuilder: (BuildContext context, int index) =>
                  _buildSmoothProductCard(
                matchedProducts[index],
                colorScheme,
                daoProductList,
              ),
            );
}
