import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/data_models/category_query_model.dart';
import 'package:smooth_app/data_models/category_tree_supplier.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/data_models/product_query_model.dart';
import 'package:smooth_app/data_models/smooth_category.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/widgets/ranking_floating_action_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_category_picker.dart';

class ProductQueryPage extends StatefulWidget {
  const ProductQueryPage({
    required this.productListSupplier,
    required this.categoryTreeSupplier,
    required this.heroTag,
    required this.mainColor,
    required this.name,
    this.lastUpdate,
  });

  final ProductListSupplier productListSupplier;
  final CategoryTreeSupplier categoryTreeSupplier;
  final String heroTag;
  final Color mainColor;
  final String name;
  final int? lastUpdate;

  @override
  State<ProductQueryPage> createState() => _ProductQueryPageState();
}

class _ProductQueryPageState extends State<ProductQueryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKeyEmpty = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldKeyNotEmpty =
      GlobalKey<ScaffoldState>();

  late ProductQueryModel _productModel;
  late CategoryQueryModel _categoryModel;
  int? _lastUpdate;
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = true;

  @override
  void initState() {
    super.initState();
    _lastUpdate = widget.lastUpdate;
    _productModel = ProductQueryModel(widget.productListSupplier);
    _categoryModel = CategoryQueryModel(widget.categoryTreeSupplier);
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
      value: _productModel,
      builder: (BuildContext context, Widget? wtf) {
        context.watch<ProductQueryModel>();
        final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
        final Size screenSize = MediaQuery.of(context).size;
        final ThemeData themeData = Theme.of(context);
        if (_productModel.loadingStatus == LoadingStatus.LOADED) {
          _productModel.process(appLocalizations.category_all);
        }
        switch (_productModel.loadingStatus) {
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
            if (_productModel.isNotEmpty()) {
              _showRefreshSnackBar(_scaffoldKeyNotEmpty);
              return _getNotEmptyScreen(screenSize, themeData);
            }
            _showRefreshSnackBar(_scaffoldKeyEmpty);
            return _getEmptyScreen(
              screenSize,
              themeData,
              _getEmptyText(
                themeData,
                widget.mainColor,
                appLocalizations.no_product_found,
              ),
            );
          case LoadingStatus.ERROR:
            return _getEmptyScreen(
              screenSize,
              themeData,
              _getEmptyText(
                themeData,
                widget.mainColor,
                '${appLocalizations.error_occurred}: ${_productModel.loadingError}',
              ),
            );
        }
      },
    );
  }

  Widget _getEmptyScreen(
    final Size screenSize,
    final ThemeData themeData,
    final Widget emptiness,
  ) =>
      Scaffold(
          key: _scaffoldKeyEmpty,
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
        key: _scaffoldKeyNotEmpty,
        floatingActionButton: RankingFloatingActionButton(
          color: widget.mainColor,
          onPressed: () => Navigator.push<Widget>(
            context,
            MaterialPageRoute<Widget>(
              builder: (BuildContext context) => PersonalizedRankingPage(
                _productModel.supplier.getProductList(),
              ),
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            _getHero(screenSize, themeData),
            ListView.builder(
              itemCount: _productModel.displayProducts!.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  child: SmoothProductCardFound(
                    heroTag: _productModel.displayProducts![index].barcode!,
                    product: _productModel.displayProducts![index],
                    elevation: Theme.of(context).brightness == Brightness.light
                        ? 0.0
                        : 4.0,
                  ).build(context),
                );
              },
              padding:
                  EdgeInsets.only(top: screenSize.height * 0.25, bottom: 80.0),
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
                    child: TextButton.icon(
                      icon: Icon(
                        Icons.filter_list,
                        color: widget.mainColor,
                      ),
                      label: Text(AppLocalizations.of(context)!.filter),
                      style: TextButton.styleFrom(
                        textStyle: TextStyle(
                          color: widget.mainColor,
                        ),
                      ),
                      onPressed: () {
                        showCupertinoModalBottomSheet<Widget>(
                          expand: false,
                          context: context,
                          backgroundColor: Colors.transparent,
                          bounce: true,
                          builder: (BuildContext context) {
                            return ChangeNotifierProvider<
                                CategoryQueryModel>.value(
                              value: _categoryModel,
                              builder: (BuildContext context, Widget? wtf) {
                                return SmoothCategoryPicker<Category>(
                                  categoryFinder: _categoryModel.getCategory,
                                  currentCategories:
                                      _categoryModel.selectedCategories,
                                  currentPath: _categoryModel.categoryPath,
                                  onPathChanged: _categoryModel.setCategoryPath,
                                  onCategoriesChanged:
                                      (Set<Category> categories) {
                                    _productModel.selectCategories(categories
                                        .map<String>((Category category) =>
                                            category.getLabel(
                                                ProductQuery.getLanguage()!))
                                        .toSet());
                                    _categoryModel.setCategories(categories);
                                  },
                                  language: ProductQuery.getLanguage()!,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

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
                SizedBox(
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
                              style: themeData.textTheme.headline1!
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
                style: themeData.textTheme.subtitle1!
                    .copyWith(color: color, fontSize: 18.0)),
          ),
        ],
      );

  void _showRefreshSnackBar(final GlobalKey<ScaffoldState> scaffoldKey) {
    if (_lastUpdate == null) {
      return;
    }
    final ProductListSupplier? refreshSupplier =
        widget.productListSupplier.getRefreshSupplier();
    if (refreshSupplier == null) {
      return;
    }
    final String lastTime =
        ProductQueryPageHelper.getDurationStringFromTimestamp(
            _lastUpdate!, context);
    final String message =
        '${AppLocalizations.of(context)!.cached_results_from} $lastTime';
    _lastUpdate = null;

    Future<void>.delayed(
      Duration.zero,
      () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.label_refresh,
            onPressed: () => setState(
              () => _productModel = ProductQueryModel(refreshSupplier),
            ),
          ),
        ),
      ),
    );
  }

  // TODO(monsieurtanuki): move to an appropriate class?
  static Widget getBackArrow(final BuildContext context, final Color color) =>
      Padding(
        padding: const EdgeInsets.only(top: 28.0),
        child: IconButton(
          icon: Icon(
            ConstantIcons.instance.getBackIcon(),
            color: color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      );
}
