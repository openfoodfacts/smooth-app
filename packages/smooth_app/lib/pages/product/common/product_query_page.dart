import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/data_models/product_query_model.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
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

  late ProductQueryModel _model;
  int? _lastUpdate;

  @override
  void initState() {
    super.initState();
    _lastUpdate = widget.lastUpdate;
    _model = ProductQueryModel(widget.productListSupplier);
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
                            _getBackArrow(context, widget.mainColor),
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
          floatingActionButton: RankingFloatingActionButton(
            color: widget.mainColor,
            onPressed: () => Navigator.push<Widget>(
              context,
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) => PersonalizedRankingPage(
                  products: _model.displayProducts!,
                  title: widget.name,
                ),
              ),
            ),
          ),
          body: Stack(
            children: <Widget>[
              _getHero(screenSize, themeData),
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
                        _getBackArrow(context, widget.mainColor),
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
                                  .copyWith(color: widget.mainColor),
                            ),
                            style: TextButton.styleFrom(
                              textStyle: TextStyle(color: widget.mainColor),
                            ),
                            onPressed: () =>
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
                            ),
                          ),
                        )
                      ],
                    ),
                    flexibleSpace: LayoutBuilder(
                      builder: (
                        BuildContext context,
                        BoxConstraints constraints,
                      ) =>
                          FlexibleSpaceBar(
                        centerTitle: true,
                        title: Text(
                          widget.name,
                          textAlign: TextAlign.center,
                          style: themeData.textTheme.headline1!
                              .copyWith(color: widget.mainColor),
                        ),
                        background: _getHero(screenSize, themeData),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext _context, int index) {
                        if (index >= _model.displayProducts!.length) {
                          // final button
                          final int already = _model.displayProducts!.length;
                          final int totalSize =
                              _model.supplier.partialProductList.totalSize;
                          final int next = max(
                            0,
                            min(
                              _model.supplier.productQuery.pageSize,
                              totalSize - already,
                            ),
                          );
                          final Widget child;
                          if (next == 0) {
                            child = Text(// TODO(monsieurtanuki): localize
                                "You've downloaded all the $totalSize products.");
                          } else {
                            child = ElevatedButton.icon(
                              icon: const Icon(Icons.download_rounded),
                              label: Text(
                                'Download $next more products'
                                '\n'
                                'Already downloaded $already out of $totalSize.',
                              ),
                              onPressed: () async {
                                final bool? error =
                                    await LoadingDialog.run<bool>(
                                  context: context,
                                  future: _model.loadNextPage(),
                                );
                                if (error != true) {
                                  await LoadingDialog.error(context: context);
                                }
                              },
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: 90.0, left: 20, right: 20),
                            child: child,
                          );
                        }
                        final Product product = _model.displayProducts![index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          child: SmoothProductCardFound(
                            heroTag: product.barcode!,
                            product: product,
                            elevation: themeData.brightness == Brightness.light
                                ? 0.0
                                : 4.0,
                          ).build(_context),
                        );
                      },
                      childCount: _model.displayProducts!.length + 1,
                    ),
                  )
                ],
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
        _model.supplier.getRefreshSupplier();
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
            onPressed: () async {
              final bool? error = await LoadingDialog.run<bool>(
                context: context,
                future: _model.loadFromTop(),
              );
              if (error != true) {
                await LoadingDialog.error(context: context);
              }
            },
          ),
        ),
      ),
    );
  }

  static Widget _getBackArrow(final BuildContext context, final Color color) =>
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
