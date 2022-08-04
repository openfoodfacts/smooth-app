import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/data_models/product_query_model.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/animations/smooth_reveal_animation.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_error_card.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/product/common/product_list_item_simple.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/query/paged_product_query.dart';
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/widgets/ranking_floating_action_button.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class ProductQueryPage extends StatefulWidget {
  const ProductQueryPage({
    required this.productListSupplier,
    required this.name,
    this.lastUpdate,
  });

  final ProductListSupplier productListSupplier;
  final String name;
  final int? lastUpdate;

  @override
  State<ProductQueryPage> createState() => _ProductQueryPageState();
}

class _ProductQueryPageState extends State<ProductQueryPage>
    with TraceableClientMixin {
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
  String get traceTitle => 'search_page';

  @override
  String get traceName => 'Opened search_page';

  @override
  void initState() {
    super.initState();
    _lastUpdate = widget.lastUpdate;
    _model = _getModel(widget.productListSupplier);
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
        final AppLocalizations appLocalizations = AppLocalizations.of(context);
        final Size screenSize = MediaQuery.of(context).size;
        final ThemeData themeData = Theme.of(context);
        switch (_model.loadingStatus) {
          case LoadingStatus.LOADING:
            return _getEmptyScreen(
              screenSize,
              themeData,
              const CircularProgressIndicator(),
            );
          case LoadingStatus.LOADED:
            if (_model.isNotEmpty()) {
              _showRefreshSnackBar(_scaffoldKeyNotEmpty);
              AnalyticsHelper.trackSearch(
                search: widget.name,
                searchCount: _model.displayBarcodes.length,
              );
              return _getNotEmptyScreen(
                screenSize,
                themeData,
                appLocalizations,
              );
            }
            _showRefreshSnackBar(_scaffoldKeyEmpty);
            return _getEmptyScreen(
              screenSize,
              themeData,
              _getEmptyText(
                themeData,
                appLocalizations.no_product_found,
              ),
            );
          case LoadingStatus.ERROR:
            return _getErrorWidget(
                screenSize, themeData, '${_model.loadingError}');
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
        child: SmoothScaffold(
          appBar: AppBar(
            backgroundColor: themeData.scaffoldBackgroundColor,
            leading: const _BackButton(),
            title: _getAppBarTitle(),
          ),
          body: Center(child: emptiness),
        ),
      );

  Widget _getAppBarTitle() => AutoSizeText(widget.name, maxLines: 2);

  Widget _getNotEmptyScreen(
    final Size screenSize,
    final ThemeData themeData,
    final AppLocalizations appLocalizations,
  ) =>
      ScaffoldMessenger(
        key: _scaffoldKeyNotEmpty,
        child: SmoothScaffold(
          floatingActionButton: Row(
            mainAxisAlignment: _showBackToTopButton
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: <Widget>[
              RankingFloatingActionButton(
                onPressed: () => Navigator.push<Widget>(
                  context,
                  MaterialPageRoute<Widget>(
                    builder: (BuildContext context) => PersonalizedRankingPage(
                      barcodes: _model.displayBarcodes,
                      title: widget.name,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _showBackToTopButton,
                child: AnimatedOpacity(
                  duration: SmoothAnimationsDuration.short,
                  opacity: _showBackToTopButton ? 1.0 : 0.0,
                  child: SmoothRevealAnimation(
                    animationCurve: Curves.easeInOutBack,
                    startOffset: const Offset(0.0, 1.0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: SMALL_SPACE,
                      ),
                      child: FloatingActionButton(
                        backgroundColor: themeData.colorScheme.secondary,
                        onPressed: () {
                          _scrollToTop();
                        },
                        tooltip: appLocalizations.go_back_to_top,
                        child: Icon(
                          Icons.arrow_upward,
                          color: themeData.colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          appBar: AppBar(
            backgroundColor: themeData.scaffoldBackgroundColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: const _BackButton(),
            title: _getAppBarTitle(),
          ),
          body: RefreshIndicator(
            onRefresh: () => refreshList(),
            child: ListView.builder(
              controller: _scrollController,
              itemBuilder: (BuildContext context, int index) {
                if (index >= _model.displayBarcodes.length) {
                  // final button
                  final int already = _model.displayBarcodes.length;
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
                    child = Text(
                      appLocalizations.product_search_no_more_results(
                        totalSize,
                      ),
                    );
                  } else {
                    child = SmoothLargeButtonWithIcon(
                      text:
                          appLocalizations.product_search_button_download_more(
                        next,
                        already,
                        totalSize,
                      ),
                      icon: Icons.download_rounded,
                      onPressed: () async =>
                          _loadAndRefreshDisplay(_model.loadNextPage()),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(
                      bottom: 90.0,
                      start: VERY_LARGE_SPACE,
                      end: VERY_LARGE_SPACE,
                    ),
                    child: child,
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MEDIUM_SPACE,
                    vertical: SMALL_SPACE,
                  ),
                  child: ProductListItemSimple(
                    barcode: _model.displayBarcodes[index],
                  ),
                );
              },
              itemCount: _model.displayBarcodes.length + 1,
            ),
          ),
        ),
      );

  Widget _getErrorWidget(
    final Size screenSize,
    final ThemeData themeData,
    final String errorMessage,
  ) {
    return _getEmptyScreen(
      screenSize,
      themeData,
      Padding(
        padding: const EdgeInsets.all(SMALL_SPACE),
        child: SmoothErrorCard(
          errorMessage: errorMessage,
          tryAgainFunction: retryConnection,
        ),
      ),
    );
  }

  Widget _getEmptyText(
    final ThemeData themeData,
    final String message,
  ) =>
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: themeData.textTheme.subtitle1!.copyWith(fontSize: 18.0),
            ),
          ),
        ],
      );

  void _showRefreshSnackBar(
    final GlobalKey<ScaffoldMessengerState> scaffoldKey,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final List<String> messages = <String>[];
    final PagedProductQuery pagedProductQuery = _model.supplier.productQuery;
    final PagedProductQuery? worldQuery = pagedProductQuery.getWorldQuery();
    messages.add(
      appLocalizations.user_list_length(
        _model.supplier.partialProductList.totalSize,
      ),
    );
    if (_lastUpdate != null) {
      final String lastTime =
          ProductQueryPageHelper.getDurationStringFromTimestamp(
              _lastUpdate!, context);
      messages.add('${appLocalizations.cached_results_from} $lastTime');
    }
    if (pagedProductQuery.hasDifferentCountryWorldData() &&
        pagedProductQuery.world) {
      messages.add(appLocalizations.world_results_label);
    }
    _lastUpdate = null;

    Future<void>.delayed(
      Duration.zero,
      () => scaffoldKey.currentState?.showMaterialBanner(
        MaterialBanner(
          content: Text(messages.join('\n')),
          actions: <Widget>[
            TextButton(
              child: Text(appLocalizations.close.toUpperCase()),
              onPressed: () =>
                  scaffoldKey.currentState?.hideCurrentMaterialBanner(),
            ),
            if (worldQuery != null)
              TextButton(
                child: Text(
                  appLocalizations.world_results_action.toUpperCase(),
                ),
                onPressed: () async {
                  scaffoldKey.currentState?.hideCurrentMaterialBanner();
                  await ProductQueryPageHelper().openBestChoice(
                    productQuery: worldQuery,
                    localDatabase: context.read<LocalDatabase>(),
                    name: widget.name,
                    context: context,
                  );
                },
              ),
            TextButton(
              child: Text(appLocalizations.label_refresh.toUpperCase()),
              onPressed: () async {
                scaffoldKey.currentState?.hideCurrentMaterialBanner();
                final bool? success =
                    await _loadAndRefreshDisplay(_model.loadFromTop());
                if (success == true) {
                  _scrollToTop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void retryConnection() =>
      setState(() => _model = _getModel(widget.productListSupplier));

  ProductQueryModel _getModel(final ProductListSupplier supplier) =>
      ProductQueryModel(supplier);

  Future<void> refreshList() async {
    final ProductListSupplier? refreshSupplier =
        widget.productListSupplier.getRefreshSupplier();
    setState(
      // How do we refresh a supplier that has no refresher? With itself.
      () => _model = _getModel(refreshSupplier ?? widget.productListSupplier),
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(seconds: 3),
      curve: Curves.linear,
    );
  }

  Future<bool?> _loadAndRefreshDisplay(final Future<bool> loader) async {
    final bool? success = await LoadingDialog.run<bool>(
      context: context,
      future: loader,
    );
    if (success == false) {
      await LoadingDialog.error(
        context: context,
        title: _model.loadingError,
      );
    } else if (success == true) {
      setState(() {});
    }
    return success;
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(ConstantIcons.instance.getBackIcon()),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () {
          Navigator.maybePop(context);
        },
      );
}
