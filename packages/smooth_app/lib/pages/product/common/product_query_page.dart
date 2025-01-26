import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iso_countries/iso_countries.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_template.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/data_models/product_query_model.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/animations/smooth_reveal_animation.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_app_logo.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_error_card.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/product/common/loading_status.dart';
import 'package:smooth_app/pages/product/common/product_list_item_simple.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/product/common/search_app_bar_title.dart';
import 'package:smooth_app/pages/product/common/search_empty_screen.dart';
import 'package:smooth_app/pages/product/common/search_loading_screen.dart';
import 'package:smooth_app/query/paged_product_query.dart';
import 'package:smooth_app/widgets/ranking_floating_action_button.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// A page that can be used like a screen, if [includeAppBar] is true.
/// Otherwise, it can be embedded in another screen.
class ProductQueryPage extends StatefulWidget {
  const ProductQueryPage({
    required this.productListSupplier,
    required this.name,
    this.includeAppBar = true,
    this.searchResult = true,
  });

  final ProductListSupplier productListSupplier;
  final String name;
  final bool includeAppBar;
  final bool searchResult;

  @override
  State<ProductQueryPage> createState() => _ProductQueryPageState();
}

class _ProductQueryPageState extends State<ProductQueryPage>
    with TraceableClientMixin {
  static const int _OVERSCROLL_TEMPLATE_COUNT = 3;

  bool _showBackToTopButton = false;
  late ScrollController _scrollController;

  late ProductQueryModel _model;
  late OpenFoodFactsCountry? _country;

  @override
  String get actionName => 'Opened search_page';

  @override
  void initState() {
    super.initState();
    _model = _getModel(widget.productListSupplier);
    _country = widget.productListSupplier.productQuery.country;
    _scrollController = ScrollController()
      ..addListener(() {
        // Also checking for the value of [_showBackToTopButton] to not rebuild
        // on every scroll call
        if (_scrollController.offset >= 400) {
          if (!_showBackToTopButton) {
            _showBackToTopButton = true;
            if (mounted) {
              setState(() {});
            }
          }
        } else if (_showBackToTopButton) {
          _showBackToTopButton = false;
          if (mounted) {
            setState(() {});
          }
        }
      });
  }

  @override
  void didUpdateWidget(ProductQueryPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.productListSupplier != widget.productListSupplier) {
      _model = _getModel(widget.productListSupplier);
      _country = widget.productListSupplier.productQuery.country;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Size screenSize = MediaQuery.sizeOf(context);
    final ThemeData themeData = Theme.of(context);

    return ChangeNotifierProvider<ProductQueryModel>.value(
      value: _model,
      builder: (BuildContext context, _) {
        context.watch<ProductQueryModel>();

        switch (_model.loadingStatus) {
          // TODO(m123): Don't block the whole screen, just the not loaded part
          case LoadingStatus.ERROR:
            return _getErrorWidget(
              screenSize,
              themeData,
              _model.loadingError ?? '',
            );
          case LoadingStatus.LOADING:
            if (_model.isEmpty()) {
              return SearchLoadingScreen(
                title: widget.name,
              );
            }
            break;
          case LoadingStatus.LOADED:
            if (_model.isEmpty()) {
              // TODO(monsieurtanuki): should be tracked as well, shouldn't it?
              return SearchEmptyScreen(
                name: widget.name,
                includeAppBar: widget.includeAppBar,
                emptiness: _getEmptyText(
                  themeData,
                  appLocalizations.no_product_found,
                ),
              );
            }
            AnalyticsHelper.trackSearch(
              search: widget.name,
              searchCount: _model.displayBarcodes.length,
            );
            break;
        }
        // Now used in two cases.
        // 1. we have data downloaded and we display it (normal mode)
        // 2. we are downloading extra data, and display what we already knew
        return _getNotEmptyScreen(
          screenSize,
          themeData,
          appLocalizations,
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // TODO(monsieurtanuki): put that in a specific Widget class
  Widget _getNotEmptyScreen(
    final Size screenSize,
    final ThemeData themeData,
    final AppLocalizations appLocalizations,
  ) {
    final int itemCount = _getItemCount();

    return SmoothSharedAnimationController(
      child: SmoothScaffold(
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: RankingFloatingActionButton(
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).push<Widget>(
                  MaterialPageRoute<Widget>(
                    builder: (BuildContext context) => PersonalizedRankingPage(
                      barcodes: _model.displayBarcodes,
                      title: widget.name,
                    ),
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
                    child: SizedBox(
                      height: MINIMUM_TOUCH_SIZE,
                      child: ElevatedButton(
                        onPressed: () {
                          _scrollToTop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeData.colorScheme.secondary,
                          foregroundColor: themeData.colorScheme.onSecondary,
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_upward,
                            color: themeData.colorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        appBar: widget.includeAppBar
            ? SmoothAppBar(
                backgroundColor: themeData.scaffoldBackgroundColor,
                elevation: 2,
                automaticallyImplyLeading: false,
                leading: const SmoothBackButton(),
                title: SearchAppBarTitle(
                  title: widget.searchResult
                      ? widget.name
                      : appLocalizations.product_search_same_category,
                  editableAppBarTitle: widget.searchResult,
                  multiLines: !widget.searchResult,
                ),
                subTitle: !widget.searchResult ? Text(widget.name) : null,
              )
            : null,
        body: RefreshIndicator(
          onRefresh: () async => _refreshList(),
          child: ListView.separated(
            controller: _scrollController,
            padding: widget.includeAppBar ? null : EdgeInsets.zero,
            // To allow refresh even when not the whole page is filled
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                // on top, a message
                return _getTopMessagesCard();
              }
              index--;

              final int barcodesCount = _model.displayBarcodes.length;

              // TODO(monsieurtanuki): maybe call it earlier, like for first unknown page index - 5?
              if (index >= barcodesCount) {
                _downloadNextPage();
              }

              if (index >= barcodesCount) {
                // When scrolling below the last loaded item (index > barcodesCount)
                // We first show a [SmoothProductCardTemplate]
                // and after that a loading indicator + some space below it as the next item.

                // The amount you scrolled over the index
                final int overscrollIndex =
                    index - barcodesCount + 1 - _OVERSCROLL_TEMPLATE_COUNT;

                if (overscrollIndex < _OVERSCROLL_TEMPLATE_COUNT - 2) {
                  return SmoothProductCardTemplate(
                    message: appLocalizations.loading_dialog_default_title,
                  );
                } else {
                  return const SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        top: VERY_LARGE_SPACE,
                        bottom: VERY_LARGE_SPACE + 60.0,
                      ),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
              }
              return ProductListItemSimple(
                barcode: _model.displayBarcodes[index],
              );
            },
            itemCount: itemCount,
            separatorBuilder: (BuildContext context, int index) {
              if (index > 0 && index < itemCount - 1) {
                return const Divider();
              } else {
                return EMPTY_WIDGET;
              }
            },
          ),
        ),
      ),
    );
  }

  int _getItemCount() {
    //  1 additional widget, on top of ALL expected products
    final int count = _model.displayBarcodes.length + 1;

    // +x loading tiles
    // +2 further indicator that more products are loading and some space below
    // but only while more are possible
    if (_model.supplier.partialProductList.totalSize >
        _model.displayBarcodes.length) {
      return count + _OVERSCROLL_TEMPLATE_COUNT + 1;
    }
    return count;
  }

  Widget _getErrorWidget(
    final Size screenSize,
    final ThemeData themeData,
    final String errorMessage,
  ) {
    return SearchEmptyScreen(
      name: widget.name,
      includeAppBar: false,
      emptiness: Padding(
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
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final PagedProductQuery pagedProductQuery = _model.supplier.productQuery;
    final PagedProductQuery? worldQuery = pagedProductQuery.getWorldQuery();

    return Padding(
      padding: const EdgeInsets.all(SMALL_SPACE),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: LARGE_SPACE),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: themeData.textTheme.titleMedium!.copyWith(fontSize: 18.0),
            ),
          ),
          if (worldQuery != null)
            _getLargeButtonWithIcon(
              _getWorldAction(
                appLocalizations,
                worldQuery,
                widget.includeAppBar,
              ),
            ),
        ],
      ),
    );
  }

  Widget _getTopMessagesCard() {
    final PagedProductQuery pagedProductQuery = _model.supplier.productQuery;
    final PagedProductQuery? worldQuery = pagedProductQuery.getWorldQuery();

    return FutureBuilder<String?>(
      future: _getTranslatedCountry(),
      builder: (
        final BuildContext context,
        final AsyncSnapshot<String?> snapshot,
      ) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);
        final List<String> messages = <String>[];
        String counting = appLocalizations.user_list_length(
          _model.supplier.partialProductList.totalSize,
        );
        if (pagedProductQuery.hasDifferentCountryWorldData()) {
          if (pagedProductQuery.world) {
            counting += ' (${appLocalizations.world_results_label})';
          } else {
            if (snapshot.data != null) {
              counting += ' (${snapshot.data})';
            }
          }
        }
        messages.add(counting);
        final int? lastUpdate = _model.supplier.timestamp;
        if (lastUpdate != null) {
          final String lastTime =
              ProductQueryPageHelper.getDurationStringFromTimestamp(
                  lastUpdate, context);
          messages.add('${appLocalizations.cached_results_from} $lastTime');
        }
        return SizedBox(
          width: double.infinity,
          child: SmoothCard(
            child: Padding(
              padding: const EdgeInsets.all(SMALL_SPACE),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(messages.join('\n'))),
                  if (pagedProductQuery.getWorldQuery() != null)
                    _getIconButton(
                      _getWorldAction(
                        appLocalizations,
                        worldQuery!,
                        widget.includeAppBar,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String?> _getTranslatedCountry() async {
    if (_country == null) {
      return null;
    }
    final String locale = Localizations.localeOf(context).languageCode;
    final List<Country> localizedCountries =
        await IsoCountries.isoCountriesForLocale(locale);
    for (final Country country in localizedCountries) {
      if (country.countryCode.toLowerCase() == _country?.offTag.toLowerCase()) {
        return country.name;
      }
    }
    return null;
  }

  Widget _getLargeButtonWithIcon(final _Action action) =>
      SmoothLargeButtonWithIcon(
        text: action.text,
        leadingIcon: Icon(action.iconData),
        onPressed: action.onPressed,
      );

  Widget _getIconButton(final _Action action) => IconButton(
        tooltip: action.text,
        icon: Icon(action.iconData),
        onPressed: action.onPressed,
      );

  _Action _getWorldAction(
    final AppLocalizations appLocalizations,
    final PagedProductQuery worldQuery,
    final bool editableAppBarTitle,
  ) =>
      _Action(
        text: appLocalizations.world_results_action,
        iconData: Icons.public,
        onPressed: () async => ProductQueryPageHelper.openBestChoice(
          productQuery: worldQuery,
          localDatabase: context.read<LocalDatabase>(),
          name: widget.name,
          context: context,
          editableAppBarTitle: editableAppBarTitle,
        ),
      );

  void retryConnection() {
    if (mounted) {
      setState(() => _model = _getModel(widget.productListSupplier));
    }
  }

  ProductQueryModel _getModel(final ProductListSupplier supplier) =>
      ProductQueryModel(supplier);

  Future<void> _refreshList() async {
    bool successfullyLoaded = false;
    try {
      successfullyLoaded = await _model.loadFromTop();
    } catch (e) {
      if (mounted) {
        await LoadingDialog.error(
          context: context,
          title: _model.loadingError,
        );
      }
    } finally {
      if (successfullyLoaded) {
        _scrollToTop(instant: true);
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _scrollToTop({bool instant = false}) {
    if (instant) {
      _scrollController.jumpTo(0);
    } else {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 6),
        curve: Curves.linear,
      );
    }
  }

  /// Flags if the next page is currently being downloaded.
  bool _loadingNext = false;

  /// Downloads the next page, asynchronously.
  Future<void> _downloadNextPage() async {
    if (_loadingNext) {
      return;
    }
    _loadingNext = true;
    try {
      final bool result = await _model.loadNextPage();
      if (result) {
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      //
    }
    _loadingNext = false;
  }
}

// TODO(monsieurtanki): put it in a specific reusable class
class _Action {
  _Action({
    required this.iconData,
    required this.text,
    required this.onPressed,
  });

  final IconData iconData;
  final String text;
  final VoidCallback onPressed;
}
