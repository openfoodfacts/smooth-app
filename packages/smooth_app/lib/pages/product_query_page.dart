import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/bottom_sheet_views/group_query_filter_view.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:smooth_app/data_models/product_query_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';
import 'package:openfoodfacts/model/Product.dart';

class ProductQueryPage extends StatefulWidget {
  const ProductQueryPage({
    @required this.productQuery,
    @required this.heroTag,
    @required this.mainColor,
    @required this.name,
  });

  final ProductQuery productQuery;
  final String heroTag;
  final Color mainColor;
  final String name;

  @override
  _ProductQueryPageState createState() => _ProductQueryPageState();
}

class _ProductQueryPageState extends State<ProductQueryPage> {
  final ProductQueryModel _model = ProductQueryModel();
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = true;

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
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final Size screenSize = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);
    return FutureBuilder<bool>(
        future: _model.loadData(
          widget.productQuery,
          userPreferences,
          userPreferencesModel,
          localDatabase,
        ),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
                floatingActionButton: _model.isNotEmpty()
                    ? _getFAB(
                        screenSize,
                        context,
                        _model.displayProducts,
                        widget.mainColor,
                      )
                    : null,
                body: Stack(
                  children: <Widget>[
                    _innerGetHero(screenSize, themeData),
                    _getList(
                      _model.displayProducts,
                      screenSize,
                      themeData,
                      widget.mainColor,
                      _scrollController,
                    ),
                    AnimatedOpacity(
                      opacity: _showTitle ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 28.0),
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: widget.mainColor,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          if (_model.isNotEmpty())
                            Padding(
                              padding: const EdgeInsets.only(top: 24.0),
                              child: FlatButton.icon(
                                icon: Icon(
                                  Icons.filter_list,
                                  color: widget.mainColor,
                                ),
                                label: const Text('Filter'),
                                textColor: widget.mainColor,
                                onPressed: () {
                                  showCupertinoModalBottomSheet<Widget>(
                                    expand: false,
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    bounce: true,
                                    barrierColor: Colors.black45,
                                    builder: (BuildContext context,
                                            ScrollController
                                                scrollController) =>
                                        GroupQueryFilterView(
                                      categories: _model.categories,
                                      categoriesList: _model.sortedCategories,
                                      callback: (String category) {
                                        _model.selectCategory(category);
                                        setState(() {});
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          /*Container(
                              margin:
                                  const EdgeInsets.only(top: 28.0, right: 8.0),
                              padding: const EdgeInsets.only(left: 10.0),
                              width: screenSize.width * 0.75,
                              decoration: const BoxDecoration(
                                color: Colors.white30,
                                borderRadius: BorderRadius.all(Radius.circular(12.0))
                              ),
                              child: DropdownButton<String>(
                                items: productGroupQueryModel.sortedCategories
                                    .map((String key) {
                                  return DropdownMenuItem<String>(
                                    value: key,
                                    child: Container(
                                      width: screenSize.width * 0.65,
                                      child: Text(productGroupQueryModel.categories[key] ?? 'error', style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .copyWith(
                                          color: mainColor, fontSize: 12.0)),
                                    ),
                                  );
                                }).toList(),
                                value: productGroupQueryModel.selectedCategory,
                                onChanged: (String value) => productGroupQueryModel.selectCategory(value),
                                icon: Icon(Icons.arrow_drop_down, color: mainColor,),
                                underline: Container(),
                              ),
                            ),*/
                        ],
                      ),
                    ),
                  ],
                ));
          }
          return Scaffold(
              floatingActionButton: null,
              body: Stack(
                children: <Widget>[
                  _innerGetHero(screenSize, themeData),
                  Center(
                    child: Container(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(widget.mainColor),
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: _showTitle ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 28.0),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: widget.mainColor,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ));
        });
  }

  Widget _innerGetHero(final Size screenSize, final ThemeData themeData) =>
      _getHero(
        screenSize,
        themeData,
        _showTitle,
        widget.heroTag,
        widget.name,
        widget.mainColor,
      );

  Widget _getFAB(
    final Size screenSize,
    final BuildContext context,
    final List<Product> products,
    final Color color,
  ) =>
      SmoothRevealAnimation(
        animationCurve: Curves.easeInOutBack,
        startOffset: const Offset(0.0, 1.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: screenSize.width * 0.09,
            ),
            FloatingActionButton.extended(
              elevation: 12.0,
              icon: SvgPicture.asset(
                'assets/actions/smoothie.svg',
                width: 24.0,
                height: 24.0,
                color: color,
              ),
              label: Text(
                'My personalized ranking',
                style: TextStyle(color: color),
              ),
              backgroundColor: Colors.white,
              onPressed: () {
                Navigator.push<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) =>
                          PersonalizedRankingPage(input: products)),
                );
              },
            ),
          ],
        ),
      );

  static Widget _getList(
    final List<Product> products,
    final Size screenSize,
    final ThemeData themeData,
    final Color color,
    final ScrollController scrollController,
  ) =>
      products.isNotEmpty
          ? ListView.builder(
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  child: SmoothProductCardFound(
                          heroTag: products[index].barcode,
                          product: products[index],
                          elevation: 4.0)
                      .build(context),
                );
              },
              padding:
                  EdgeInsets.only(top: screenSize.height * 0.25, bottom: 80.0),
              controller: scrollController,
            )
          : Center(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Text('No product found in this category',
                        textAlign: TextAlign.center,
                        style: themeData.textTheme.subtitle1
                            .copyWith(color: color, fontSize: 18.0)),
                  ),
                ],
              ),
            );

  Widget _getHero(
    final Size screenSize,
    final ThemeData themeData,
    final bool showTitle,
    final String heroTag,
    final String keywords,
    final Color color,
  ) =>
      Hero(
        tag: heroTag,
        child: Container(
            width: screenSize.width,
            height: screenSize.height,
            decoration: BoxDecoration(
              color: color.withAlpha(32),
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0)),
            ),
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 96.0),
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
                            opacity: showTitle ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 250),
                            child: Text(keywords,
                                textAlign: TextAlign.center,
                                style: themeData.textTheme.headline1
                                    .copyWith(color: color))),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      );
}
