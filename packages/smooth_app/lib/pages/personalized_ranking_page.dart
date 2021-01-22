import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/bottom_sheet_views/user_preferences_view.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/data_models/smooth_it_model.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:smooth_app/structures/ranked_product.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/themes/constant_icons.dart';

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

  static const Map<int, Color> _COLORS = <int, Color>{
    SmoothItModel.MATCH_INDEX_YES: Colors.green,
    SmoothItModel.MATCH_INDEX_MAYBE: Colors.grey,
    SmoothItModel.MATCH_INDEX_NO: Colors.red,
  };

  static const Map<int, IconData> _ICONS = <int, IconData>{
    SmoothItModel.MATCH_INDEX_ALL: Icons.sort,
    SmoothItModel.MATCH_INDEX_YES: Icons.check_circle,
    SmoothItModel.MATCH_INDEX_MAYBE: CupertinoIcons.question_diamond,
    SmoothItModel.MATCH_INDEX_NO: Icons.cancel,
  };

  final SmoothItModel _model = SmoothItModel();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _showTitle = true;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset <=
              _scrollController.position.minScrollExtent &&
          !_scrollController.position.outOfRange) {
        // Reached Top
        if (!_showTitle) {
          setState(() => _showTitle = true);
        }
      } else {
        if (_showTitle) {
          setState(() => _showTitle = false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final UserPreferencesModel userPreferencesModel =
        context.watch<UserPreferencesModel>();
    _model.refresh(widget.productList, userPreferences, userPreferencesModel);
    final List<BottomNavigationBarItem> bottomNavigationBarItems =
        <BottomNavigationBarItem>[];
    for (final int matchIndex in _ORDERED_MATCH_INDEXES) {
      bottomNavigationBarItems.add(
        BottomNavigationBarItem(
          icon: Icon(_ICONS[matchIndex],
              color: _COLORS[matchIndex] ??
                  Theme.of(context).colorScheme.onSurface),
          label: _model.getRankedProducts(matchIndex).length.toString(),
        ),
      );
    }
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context)
            .bottomNavigationBarTheme
            .backgroundColor
            .withAlpha(255),
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentTabIndex,
        selectedItemColor: Theme.of(context).colorScheme.onSurface,
        unselectedItemColor: Theme.of(context)
            .bottomNavigationBarTheme
            .unselectedIconTheme
            .color,
        items: bottomNavigationBarItems,
        onTap: (int tapped) => setState(() {
          _currentTabIndex = tapped;
          _model.setNextRefreshAsJustChangingTabs();
        }),
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: !_showTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: FloatingActionButton(
          //backgroundColor: Theme.of(context).colorScheme.primary,
          heroTag: 'do_not_use_hero_animation',
          child: const Icon(Icons.arrow_upward),
          onPressed: () {
            _scrollController.animateTo(0.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.ease);
          },
        ),
      ),
      body: _buildGroupedStickyListView(),
    );
  }

  Widget _buildSmoothProductCard(final RankedProduct rankedProduct) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: SmoothProductCardFound(
          heroTag: rankedProduct.product.barcode,
          product: rankedProduct.product,
          elevation: 4.0,
          backgroundColor: _COLORS[SmoothItModel.getMatchIndex(rankedProduct)],
        ),
      );

  Widget _buildGroupedStickyListView() => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              leading: IconButton(
                icon: Icon(
                  ConstantIcons.getBackIcon(),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              expandedHeight: 120.0,
              floating: true,
              pinned: true,
              snap: true,
              elevation: 8,
              backgroundColor: Theme.of(context).colorScheme.background,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(AppLocalizations.of(context).myPersonalizedRanking,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline4),
              ),
              actions: <IconButton>[
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  onPressed: () => showCupertinoModalBottomSheet<Widget>(
                    expand: false,
                    context: context,
                    backgroundColor: Colors.transparent,
                    bounce: true,
                    barrierColor: Colors.black45,
                    builder: (BuildContext context) => UserPreferencesView(
                        ModalScrollController.of(context), callback: () {
                      const SnackBar snackBar = SnackBar(
                        content: Text(
                          'Reloaded with new preferences',
                        ),
                        duration: Duration(milliseconds: 1500),
                      );
                      _scaffoldKey.currentState.showSnackBar(snackBar);
                    }),
                  ),
                )
              ],
            ),
            _getStickyHeader(_model
                .getRankedProducts(_ORDERED_MATCH_INDEXES[_currentTabIndex])),
          ],
        ),
      );

  Widget _getStickyHeader(final List<RankedProduct> products) =>
      products.isEmpty
          ? SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('There is no product in this section',
                          style: Theme.of(context).textTheme.subtitle1),
                    ],
                  ),
                ),
                childCount: 1,
              ),
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) =>
                    _buildSmoothProductCard(products[index]),
                childCount: products.length,
              ),
              //),
            );
}
