import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/data_models/product_query_model.dart';
import 'package:smooth_app/generic_lib/animations/smooth_reveal_animation.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/views/bottom_sheet_views/group_query_filter_view.dart';
import 'package:smooth_app/widgets/ranking_floating_action_button.dart';

class ProductQueryPage extends StatefulWidget {
  const ProductQueryPage({
    required this.productListSupplier,
    required this.heroTag,
    required this.mainColor,
    required this.name,
    this.lastUpdate,
  });

  final ProductListSupplier productListSupplier;
  final String heroTag;
  final Color mainColor;
  final String name;
  final int? lastUpdate;

  @override
  State<ProductQueryPage> createState() => _ProductQueryPageState();
}

class _ProductQueryPageState extends State<ProductQueryPage> {
  // we have to use GlobalKey's for SnackBar's because of nested Scaffold's:
  // not the 2 Scaffold's here but one of them and the one on top (PageManager)
  final GlobalKey<ScaffoldMessengerState> _scaffoldKeyEmpty =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKeyNotEmpty =
      GlobalKey<ScaffoldMessengerState>();
  bool _showBackToTopButton = false;
  late ScrollController _scrollController;

  late ProductQueryModel _model;
  int? _lastUpdate;

  @override
  void initState() {
    super.initState();
    _lastUpdate = widget.lastUpdate;
    _model = ProductQueryModel(widget.productListSupplier);
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          if (_scrollController.offset >= 400) {
            _showBackToTopButton = true;
          } else {
            _showBackToTopButton = false;
          }
        });
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProductQueryModel>.value(
      value: _model,
      builder: (BuildContext context, Widget? wtf) {
        context.watch<ProductQueryModel>();
        final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
        final Size screenSize = MediaQuery.of(context).size;
        final ThemeData themeData = Theme.of(context);
        if (_model.loadingStatus == LoadingStatus.LOADED) {
          _model.process(appLocalizations.category_all);
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
              _showRefreshSnackBar(_scaffoldKeyNotEmpty);
              AnalyticsHelper.trackSearch(
                search: widget.name,
                searchCategory: _model.currentCategory,
                searchCount: _model.displayProducts?.length,
              );
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
                '${appLocalizations.error_occurred}: ${_model.loadingError}',
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
      ScaffoldMessenger(
        key: _scaffoldKeyEmpty,
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              _getHero(screenSize, themeData),
              Center(child: emptiness),
              CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                      backgroundColor: themeData.scaffoldBackgroundColor,
                      expandedHeight: screenSize.height * 0.15,
                      collapsedHeight: screenSize.height * 0.09,
                      pinned: true,
                      elevation: 0,
                      automaticallyImplyLeading: false,
                      title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            getBackArrow(context, widget.mainColor),
                          ]),
                      flexibleSpace: LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return FlexibleSpaceBar(
                            centerTitle: true,
                            title: Text(
                              widget.name,
                              textAlign: TextAlign.center,
                              style: themeData.textTheme.headline1!
                                  .copyWith(color: widget.mainColor),
                            ),
                            background: _getHero(screenSize, themeData));
                      })),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _getNotEmptyScreen(
    final Size screenSize,
    final ThemeData themeData,
  ) =>
      ScaffoldMessenger(
        key: _scaffoldKeyNotEmpty,
        child: Scaffold(
          floatingActionButton: Row(
            mainAxisAlignment: _showBackToTopButton
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: <Widget>[
              RankingFloatingActionButton(
                color: widget.mainColor,
                onPressed: () => Navigator.push<Widget>(
                  context,
                  MaterialPageRoute<Widget>(
                    builder: (BuildContext context) => PersonalizedRankingPage(
                      productList: _model.supplier.getProductList(),
                      title: widget.name,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _showBackToTopButton,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _showBackToTopButton ? 1.0 : 0.0,
                  child: SmoothRevealAnimation(
                    animationCurve: Curves.easeInOutBack,
                    startOffset: const Offset(0.0, 1.0),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: FloatingActionButton(
                        backgroundColor: Colors.white,
                        onPressed: () {
                          _scrollToTop();
                        },
                        child: Icon(
                          Icons.arrow_upward,
                          color: widget.mainColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: <Widget>[
              _getHero(screenSize, themeData),
              RefreshIndicator(
                onRefresh: () => refreshlist(),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: <Widget>[
                    SliverAppBar(
                      backgroundColor: themeData.scaffoldBackgroundColor,
                      expandedHeight: screenSize.height * 0.15,
                      collapsedHeight: screenSize.height * 0.09,
                      pinned: true,
                      elevation: 0,
                      automaticallyImplyLeading: false,
                      title: Row(
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
                                label: Text(
                                    AppLocalizations.of(context)!.filter,
                                    style: themeData.textTheme.subtitle1!
                                        .copyWith(color: widget.mainColor)),
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
                            )
                          ]),
                      flexibleSpace: LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return FlexibleSpaceBar(
                            centerTitle: true,
                            title: Text(
                              widget.name,
                              textAlign: TextAlign.center,
                              style: themeData.textTheme.headline1!
                                  .copyWith(color: widget.mainColor),
                            ),
                            background: _getHero(screenSize, themeData));
                      }),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            child: SmoothProductCardFound(
                              heroTag: _model.displayProducts![index].barcode!,
                              product: _model.displayProducts![index],
                              elevation: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? 0.0
                                  : 4.0,
                            ).build(context),
                          );
                        },
                        childCount: _model.displayProducts!.length,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _getHero(final Size screenSize, final ThemeData themeData) => Hero(
      tag: widget.heroTag,
      child: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: BoxDecoration(
          color: widget.mainColor.withAlpha(32),
        ),
        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 96.0),
      ));

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

  void _showRefreshSnackBar(
    final GlobalKey<ScaffoldMessengerState> scaffoldKey,
  ) {
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
      () => scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.label_refresh,
            onPressed: () => setState(
              () => _model = ProductQueryModel(refreshSupplier),
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

  Future<void> refreshlist() async {
    final ProductListSupplier? refreshSupplier =
        widget.productListSupplier.getRefreshSupplier();
    setState(
      () => _model = ProductQueryModel(refreshSupplier!),
    );
    return;
  }

  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(seconds: 3), curve: Curves.linear);
  }
}
