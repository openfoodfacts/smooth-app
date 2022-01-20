import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:openfoodfacts/utils/LanguageHelper.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKeyResults =
      GlobalKey<ScaffoldState>();

  late ProductQueryModel _productModel;
  late CategoryFilterModel _categoryModel;
  int? _lastUpdate;
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = true;

  @override
  void initState() {
    super.initState();
    _lastUpdate = widget.lastUpdate;
    _productModel = ProductQueryModel(widget.productListSupplier);
    _categoryModel = CategoryFilterModel(widget.categoryTreeSupplier);
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
      builder: (BuildContext context, Widget? ignoredChild) {
        context.watch<ProductQueryModel>();
        final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
        if (_productModel.loadingStatus == LoadingStatus.LOADED) {
          _productModel.process(appLocalizations.category_all);
        }
        switch (_productModel.loadingStatus) {
          case LoadingStatus.POST_LOAD_STARTED:
          case LoadingStatus.LOADING:
          case LoadingStatus.LOADED:
            return _ProductEmptyScreen(
              categoryModel: _categoryModel,
              heroTag: widget.heroTag,
              mainColor: widget.mainColor,
              name: widget.name,
              scaffoldKey: _scaffoldKeyEmpty,
              showTitle: _showTitle,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(widget.mainColor),
              ),
            );
          case LoadingStatus.COMPLETE:
            if (_productModel.isNotEmpty()) {
              _showRefreshSnackBar(_scaffoldKeyResults);
              return _ProductResultsScreen(
                categoryModel: _categoryModel,
                heroTag: widget.heroTag,
                mainColor: widget.mainColor,
                name: widget.name,
                productModel: _productModel,
                scaffoldKey: _scaffoldKeyResults,
                scrollController: _scrollController,
                showTitle: _showTitle,
              );
            }
            _showRefreshSnackBar(_scaffoldKeyEmpty);
            return _ProductEmptyScreen(
              categoryModel: _categoryModel,
              heroTag: widget.heroTag,
              mainColor: widget.mainColor,
              name: widget.name,
              scaffoldKey: _scaffoldKeyEmpty,
              child: _ProductEmptyText(
                color: widget.mainColor,
                message: appLocalizations.no_product_found,
              ),
            );
          case LoadingStatus.ERROR:
            return _ProductEmptyScreen(
              categoryModel: _categoryModel,
              heroTag: widget.heroTag,
              mainColor: widget.mainColor,
              name: widget.name,
              scaffoldKey: _scaffoldKeyEmpty,
              child: _ProductEmptyText(
                color: widget.mainColor,
                // TODO(gspencergoog): Fix to use single localized string with
                // argument to accommodate RTL languages.
                message:
                    '${appLocalizations.error_occurred}: ${_productModel.loadingError}',
              ),
            );
        }
      },
    );
  }

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
}

class ProductCategoryPicker extends StatefulWidget {
  const ProductCategoryPicker({
    Key? key,
    required this.categoryModel,
  }) : super(key: key);

  final CategoryFilterModel categoryModel;

  @override
  State<ProductCategoryPicker> createState() => _ProductCategoryPickerState();
}

class _ProductCategoryPickerState extends State<ProductCategoryPicker> {
  @override
  void initState() {
    super.initState();
    widget.categoryModel.addListener(_handleStateChange);
  }

  @override
  void dispose() {
    widget.categoryModel.removeListener(_handleStateChange);
    super.dispose();
  }

  void _handleStateChange() {
    setState(() {
      // Nothing
    });
  }

  @override
  Widget build(BuildContext context) {
    return SmoothCategoryPicker<Category>(
      categoryFinder: widget.categoryModel.getCategory,
      currentCategories: widget.categoryModel.selectedCategories.toSet(),
      currentPath: widget.categoryModel.categoryPath.toList(),
      onPathChanged: widget.categoryModel.setCategoryPath,
      onCategoriesChanged: widget.categoryModel.setCategories,
      onApply: (Set<Category> categories) {
        Navigator.of(context).pop(categories);
      },
      language: ProductQuery.getLanguage()!,
    );
  }
}

class ProductCategoryDisplay extends StatelessWidget {
  const ProductCategoryDisplay(
      {required this.categoryModel, required this.language});

  final CategoryFilterModel categoryModel;
  final OpenFoodFactsLanguage language;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CategoryFilterModel>.value(
      value: categoryModel,
      builder: (BuildContext context, Widget? ignoredChild) {
        return SmoothCategoryDisplay<Category>(
          categories: categoryModel.selectedCategories.toSet(),
          language: language,
          onDeleted: (Category category) {
            debugPrint('Deleting $category');
            categoryModel.setCategories(
              categoryModel.selectedCategories.difference(<Category>{category}),
            );
          },
        );
      },
    );
  }
}

class _ProductQueryHero extends StatelessWidget {
  const _ProductQueryHero({
    Key? key,
    required this.name,
    required this.categoryModel,
    required this.mainColor,
    required this.backgroundColor,
    required this.heroTag,
    this.showTitle = true,
  }) : super(key: key);

  final String name;
  final CategoryFilterModel categoryModel;
  final Color mainColor;
  final Color backgroundColor;
  final Object heroTag;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final Size screenSize = MediaQuery.of(context).size;
    return Hero(
      tag: heroTag,
      child: Container(
          width: screenSize.width,
          height: screenSize.height,
          decoration: BoxDecoration(
            color: backgroundColor,
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
                          opacity: showTitle ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          child: Column(
                            children: <Widget>[
                              Text(
                                name,
                                textAlign: TextAlign.center,
                                style: themeData.textTheme.headline1!
                                    .copyWith(color: mainColor),
                              ),
                              if (categoryModel.selectedCategories.isNotEmpty)
                                SmoothCategoryDisplay<Category>(
                                  categories: categoryModel.selectedCategories,
                                  onDeleted: (Category category) {
                                    categoryModel.setCategories(
                                      categoryModel.selectedCategories
                                          .difference(<Category>{category}),
                                    );
                                  },
                                  language: ProductQuery.getLanguage()!,
                                ),
                            ],
                          )),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

class _ProductEmptyScreen extends StatelessWidget {
  const _ProductEmptyScreen({
    Key? key,
    required this.name,
    required this.categoryModel,
    required this.scaffoldKey,
    required this.mainColor,
    required this.heroTag,
    this.showTitle = true,
    required this.child,
  }) : super(key: key);

  final String name;
  final CategoryFilterModel categoryModel;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Color mainColor;
  final Object heroTag;
  final bool showTitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        children: <Widget>[
          _ProductQueryHero(
            heroTag: heroTag,
            backgroundColor: mainColor.withAlpha(32),
            mainColor: mainColor,
            categoryModel: categoryModel,
            name: name,
            showTitle: showTitle,
          ),
          Center(child: child),
          AnimatedOpacity(
            opacity: showTitle ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _ProductBackArrow(color: mainColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductBackArrow extends StatelessWidget {
  const _ProductBackArrow({
    Key? key,
    required this.color,
  }) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
}

class _ProductEmptyText extends StatelessWidget {
  const _ProductEmptyText({
    Key? key,
    required this.color,
    required this.message,
  }) : super(key: key);

  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Row(
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
  }
}

class _ProductResultsScreen extends StatelessWidget {
  const _ProductResultsScreen({
    Key? key,
    required this.name,
    required this.productModel,
    required this.categoryModel,
    required this.heroTag,
    required this.mainColor,
    required this.scaffoldKey,
    required this.scrollController,
    this.showTitle = true,
  }) : super(key: key);

  final String name;
  final ProductQueryModel productModel;
  final CategoryFilterModel categoryModel;
  final Object heroTag;
  final Color mainColor;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final ScrollController scrollController;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: RankingFloatingActionButton(
        color: mainColor,
        onPressed: () => Navigator.push<Widget>(
          context,
          MaterialPageRoute<Widget>(
            builder: (BuildContext context) => PersonalizedRankingPage(
              productModel.supplier.getProductList(),
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          _ProductQueryHero(
            heroTag: heroTag,
            backgroundColor: mainColor.withAlpha(32),
            mainColor: mainColor,
            categoryModel: categoryModel,
            name: name,
            showTitle: showTitle,
          ),
          ListView.builder(
            itemCount: productModel.displayProducts!.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: SmoothProductCardFound(
                  heroTag: productModel.displayProducts![index].barcode!,
                  product: productModel.displayProducts![index],
                  elevation: Theme.of(context).brightness == Brightness.light
                      ? 0.0
                      : 4.0,
                ).build(context),
              );
            },
            padding:
                EdgeInsets.only(top: screenSize.height * 0.25, bottom: 80.0),
            controller: scrollController,
          ),
          AnimatedOpacity(
            opacity: showTitle ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _ProductBackArrow(color: mainColor),
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: TextButton.icon(
                    icon: Icon(
                      Icons.filter_list,
                      color: mainColor,
                    ),
                    label: Text(AppLocalizations.of(context)!.filter),
                    style: TextButton.styleFrom(
                      textStyle: TextStyle(
                        color: mainColor,
                      ),
                    ),
                    onPressed: () async {
                      final Set<Category>? categories =
                          await Navigator.of(context).push<Set<Category>>(
                        ModalBottomSheetRoute<Set<Category>>(
                          expanded: false,
                          builder: (BuildContext context) =>
                              ProductCategoryPicker(
                            categoryModel: categoryModel,
                          ),
                        ),
                      );
                      if (categories != null) {
                        debugPrint('Applying categories $categories');
                        productModel.selectCategories(categories
                            .map<String>((Category category) =>
                                category.getLabel(ProductQuery.getLanguage()!))
                            .toSet());
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
