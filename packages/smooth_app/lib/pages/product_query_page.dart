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
import 'package:smooth_app/themes/constant_icons.dart';

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
  ProductQueryModel _model;
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = true;

  @override
  void initState() {
    super.initState();
    _model = ProductQueryModel(widget.productQuery);
    _scrollController.addListener(() {
      if (_scrollController.offset <=
              _scrollController.position.minScrollExtent &&
          !_scrollController.position.outOfRange) {
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
    return ChangeNotifierProvider<ProductQueryModel>.value(
        value: _model,
        builder: (BuildContext context, Widget wtf) {
          context.watch<ProductQueryModel>();
          final Size screenSize = MediaQuery.of(context).size;
          final ThemeData themeData = Theme.of(context);
          if (_model.loadingStatus == LoadingStatus.LOADED) {
            final UserPreferences userPreferences =
                context.watch<UserPreferences>();
            final UserPreferencesModel userPreferencesModel =
                context.watch<UserPreferencesModel>();
            final LocalDatabase localDatabase = context.watch<LocalDatabase>();
            _model.sort(userPreferences, userPreferencesModel, localDatabase);
          }
          switch (_model.loadingStatus) {
            case LoadingStatus.POST_LOAD_STARTED:
            case LoadingStatus.LOADING:
            case LoadingStatus.LOADED:
              return _getEmptyScreen(
                screenSize,
                themeData,
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(widget.mainColor),
                ),
              );
            case LoadingStatus.COMPLETE:
              if (_model.isNotEmpty()) {
                return _getNotEmptyScreen(screenSize, themeData);
              }
              return _getEmptyScreen(
                screenSize,
                themeData,
                _getEmptyText(
                  themeData,
                  widget.mainColor,
                  'No product found',
                ),
              );
            case LoadingStatus.ERROR:
              return _getEmptyScreen(
                screenSize,
                themeData,
                _getEmptyText(
                  themeData,
                  widget.mainColor,
                  'An error occurred: ${_model.loadingError}',
                ),
              );
          }
          throw Exception('unknown LoadingStatus: ${_model.loadingStatus}');
        });
  }

  Widget _getEmptyScreen(
    final Size screenSize,
    final ThemeData themeData,
    final Widget emptiness,
  ) =>
      Scaffold(
          body: Stack(
        children: <Widget>[
          _getHero(screenSize, themeData),
          Center(child: emptiness),
          AnimatedOpacity(
            opacity: _showTitle ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                getBackArrow(context, widget.mainColor),
              ],
            ),
          ),
        ],
      ));

  Widget _getNotEmptyScreen(
    final Size screenSize,
    final ThemeData themeData,
  ) =>
      Scaffold(
          floatingActionButton: SmoothRevealAnimation(
            animationCurve: Curves.easeInOutBack,
            startOffset: const Offset(0.0, 1.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: screenSize.width * 0.09),
                FloatingActionButton.extended(
                  elevation: 12.0,
                  icon: SvgPicture.asset(
                    'assets/actions/smoothie.svg',
                    width: 24.0,
                    height: 24.0,
                    color: widget.mainColor,
                  ),
                  label: Text(
                    'My personalized ranking',
                    style: TextStyle(color: widget.mainColor),
                  ),
                  backgroundColor: Colors.white,
                  onPressed: () {
                    Navigator.push<dynamic>(
                      context,
                      MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) =>
                              PersonalizedRankingPage(
                                  input: _model.displayProducts)),
                    );
                  },
                ),
              ],
            ),
          ),
          body: Stack(
            children: <Widget>[
              _getHero(screenSize, themeData),
              ListView.builder(
                itemCount: _model.displayProducts.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    child: SmoothProductCardFound(
                      heroTag: _model.displayProducts[index].barcode,
                      product: _model.displayProducts[index],
                      elevation:
                          Theme.of(context).brightness == Brightness.light
                              ? 0.0
                              : 4.0,
                      translucentBackground:
                          Theme.of(context).brightness == Brightness.light,
                    ).build(context),
                  );
                },
                padding: EdgeInsets.only(
                    top: screenSize.height * 0.25, bottom: 80.0),
                controller: _scrollController,
              ),
              AnimatedOpacity(
                opacity: _showTitle ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    getBackArrow(context, widget.mainColor),
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
                            builder: (BuildContext context) =>
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
                  ],
                ),
              ),
            ],
          ));

  Widget _getHero(final Size screenSize, final ThemeData themeData) => Hero(
        tag: widget.heroTag,
        child: Container(
            width: screenSize.width,
            height: screenSize.height,
            decoration: BoxDecoration(
              color: widget.mainColor.withAlpha(32),
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
                            opacity: _showTitle ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              widget.name,
                              textAlign: TextAlign.center,
                              style: themeData.textTheme.headline1
                                  .copyWith(color: widget.mainColor),
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      );

  Widget _getEmptyText(
    final ThemeData themeData,
    final Color color,
    final String message,
  ) =>
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: Text(message,
                textAlign: TextAlign.center,
                style: themeData.textTheme.subtitle1
                    .copyWith(color: color, fontSize: 18.0)),
          ),
        ],
      );

  // TODO(monsieurtanuki): move to an appropriate class?
  static Widget getBackArrow(final BuildContext context, final Color color) =>
      Padding(
        padding: const EdgeInsets.only(top: 28.0),
        child: IconButton(
          icon: Icon(
            ConstantIcons.getBackIcon(),
            color: color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      );
}
