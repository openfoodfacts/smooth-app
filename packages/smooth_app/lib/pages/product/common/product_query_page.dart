import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iso_countries/iso_countries.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
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
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_error_card.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/product/common/product_list_item_simple.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/query/paged_product_query.dart';
import 'package:smooth_app/widgets/ranking_floating_action_button.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class ProductQueryPage extends StatefulWidget {
  const ProductQueryPage({
    required this.productListSupplier,
    required this.name,
  });

  final ProductListSupplier productListSupplier;
  final String name;

  @override
  State<ProductQueryPage> createState() => _ProductQueryPageState();
}

class _ProductQueryPageState extends State<ProductQueryPage>
    with TraceableClientMixin {
  static const int _OVERSCROLL_TEMPLATE_COUNT = 1;

  late ProductQueryModel _model;

  @override
  String get traceTitle => 'search_page';

  @override
  String get traceName => 'Opened search_page';

  @override
  void initState() {
    super.initState();
    _model = _getModel(widget.productListSupplier);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Size screenSize = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);

    return ChangeNotifierProvider<ProductQueryModel>.value(
      value: _model,
      builder: (BuildContext context, _) {
        context.watch<ProductQueryModel>();

        switch (_model.loadingStatus) {
          // TODO(m123): Don't block the whole screen, just the not loaded part
          case LoadingStatus.ERROR:
            return _PageQueryError(
              pageName: widget.name,
              onRetryConnection: retryConnection,
            );
          case LoadingStatus.LOADING:
            if (_model.isEmpty()) {
              return _PageQueryEmptyScreen(
                screenSize: screenSize,
                name: widget.name,
                emptiness: const CircularProgressIndicator.adaptive(),
              );
            }
            break;
          case LoadingStatus.LOADED:
            if (_model.isEmpty()) {
              // TODO(monsieurtanuki): should be tracked as well, shouldn't it?
              return _PageQueryEmptyScreen(
                screenSize: screenSize,
                name: widget.name,
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
        return _PageQueryContentList(
          pageName: widget.name,
          onRefresh: _refreshList,
          country: widget.productListSupplier.productQuery.country,
        );
      },
    );
  }

  Future<bool> _refreshList() async {
    bool successfullyLoaded = false;
    bool scrollToTop = false;
    try {
      successfullyLoaded = await _model.loadFromTop();
    } catch (e) {
      await LoadingDialog.error(
        context: context,
        title: _model.loadingError,
      );
    } finally {
      if (successfullyLoaded) {
        scrollToTop = true;
      }
      setState(() {});
    }

    return scrollToTop;
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
              style: themeData.textTheme.subtitle1!.copyWith(fontSize: 18.0),
            ),
          ),
          if (worldQuery != null)
            _getLargeButtonWithIcon(
              _getWorldAction(
                context,
                appLocalizations,
                worldQuery,
                widget.name,
              ),
            ),
        ],
      ),
    );
  }

  Widget _getLargeButtonWithIcon(final _PageQueryAction action) =>
      SmoothLargeButtonWithIcon(
        text: action.text,
        icon: action.iconData,
        onPressed: action.onPressed,
      );

  void retryConnection() =>
      setState(() => _model = _getModel(widget.productListSupplier));

  ProductQueryModel _getModel(final ProductListSupplier supplier) =>
      ProductQueryModel(supplier);
}

class _PageQueryEmptyScreen extends StatelessWidget {
  const _PageQueryEmptyScreen({
    required this.screenSize,
    required this.name,
    required this.emptiness,
    Key? key,
  }) : super(key: key);

  final Size screenSize;
  final String name;
  final Widget emptiness;

  @override
  Widget build(BuildContext context) {
    return SmoothScaffold(
      appBar: _PageQueryAppBar(
        title: name,
      ),
      body: Center(child: emptiness),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({
    required this.name,
    Key? key,
  }) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(ProductQueryPageResult.editProductQuery);
      },
      child: Tooltip(
        message: appLocalizations.tap_to_edit_search,
        child: AutoSizeText(
          name,
          maxLines: 2,
        ),
      ),
    );
  }
}

class _PageQueryError extends StatelessWidget {
  const _PageQueryError({
    required this.pageName,
    required this.onRetryConnection,
    Key? key,
  }) : super(key: key);

  final String pageName;
  final VoidCallback onRetryConnection;

  @override
  Widget build(BuildContext context) {
    final ProductQueryModel model = context.watch<ProductQueryModel>();
    final Size screenSize = MediaQuery.of(context).size;

    return _PageQueryEmptyScreen(
      screenSize: screenSize,
      name: pageName,
      emptiness: Padding(
        padding: const EdgeInsets.all(SMALL_SPACE),
        child: SmoothErrorCard(
          errorMessage: model.loadingError ?? '',
          tryAgainFunction: onRetryConnection,
        ),
      ),
    );
  }
}

class _PageQueryContentList extends StatefulWidget {
  _PageQueryContentList({
    required this.pageName,
    required this.onRefresh,
    required this.country,
    Key? key,
  })  : assert(pageName.isNotEmpty),
        super(key: key);

  final String pageName;
  final _PageQueryRefreshCallback onRefresh;
  final OpenFoodFactsCountry? country;

  @override
  State<_PageQueryContentList> createState() => _PageQueryContentListState();
}

class _PageQueryContentListState extends State<_PageQueryContentList> {
  final ScrollController _scrollController = ScrollController();

  bool _showBackToTopButton = false;

  /// Flags if the next page is currently being downloaded.
  bool _loadingNext = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      // Also checking for the value of [_showBackToTopButton] to not rebuild
      // on every scroll call
      if (_scrollController.offset >= 400) {
        if (!_showBackToTopButton) {
          _showBackToTopButton = true;
          setState(() {});
        }
      } else if (_showBackToTopButton) {
        _showBackToTopButton = false;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    final ProductQueryModel model = context.watch<ProductQueryModel>();

    return SmoothScaffold(
      floatingActionButton: Row(
        mainAxisAlignment: _showBackToTopButton
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          RankingFloatingActionButton(
            onPressed: () => Navigator.push<Widget>(
              context,
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) => PersonalizedRankingPage(
                  barcodes: model.displayBarcodes,
                  title: widget.pageName,
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
      appBar: _PageQueryAppBar(
        title: widget.pageName,
        elevation: 2.0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (await widget.onRefresh.call() == true) {
            _scrollToTop(instant: true);
          }
        },
        child: ListView.builder(
          controller: _scrollController,
          // To allow refresh even when not the whole page is filled
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              // on top, a message
              return _PageQueryTopMessageCard(
                country: widget.country,
              );
            }
            index--;

            final int barcodesCount = model.displayBarcodes.length;

            // TODO(monsieurtanuki): maybe call it earlier, like for first unknown page index - 5?
            if (index >= barcodesCount) {
              _downloadNextPage(model);
            }

            if (index >= barcodesCount) {
              // When scrolling below the last loaded item (index > barcodesCount)
              // We first show a [SmoothProductCardTemplate]
              // and after that a loading indicator + some space below it as the next item.

              // The amount you scrolled over the index
              final int overscrollIndex = index -
                  barcodesCount +
                  1 -
                  _ProductQueryPageState._OVERSCROLL_TEMPLATE_COUNT;

              if (overscrollIndex <= 0) {
                return const SmoothProductCardTemplate();
              } else if (overscrollIndex == 1) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return SizedBox(
                  height: MediaQuery.of(context).size.height / 4.0,
                );
              }
            }

            return ProductListItemSimple(
              barcode: model.displayBarcodes[index],
            );
          },
          itemCount: _getItemCount(model),
        ),
      ),
    );
  }

  int _getItemCount(ProductQueryModel model) {
    //  1 additional widget, on top of ALL expected products
    final int count = model.displayBarcodes.length + 1;

    // +x loading tiles
    // +2 further indicator that more products are loading and some space below
    // but only while more are possible
    if (model.supplier.partialProductList.totalSize >
        model.displayBarcodes.length) {
      return count + _ProductQueryPageState._OVERSCROLL_TEMPLATE_COUNT + 2;
    }
    return count;
  }

  void _scrollToTop({
    bool instant = false,
  }) {
    if (instant) {
      _scrollController.jumpTo(0);
    } else {
      _scrollController.animateTo(
        0,
        duration: SnackBarDuration.medium,
        curve: Curves.linear,
      );
    }
  }

  /// Downloads the next page, asynchronously.
  Future<void> _downloadNextPage(ProductQueryModel model) async {
    if (_loadingNext) {
      return;
    }
    _loadingNext = true;
    try {
      final bool result = await model.loadNextPage();
      if (result) {
        setState(() {});
      }
    } catch (e) {
      //
    }
    _loadingNext = false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class _PageQueryTopMessageCard extends StatelessWidget {
  const _PageQueryTopMessageCard({
    required this.country,
    Key? key,
  }) : super(key: key);

  final OpenFoodFactsCountry? country;

  @override
  Widget build(BuildContext context) {
    final ProductQueryModel model = context.watch<ProductQueryModel>();
    final PagedProductQuery pagedProductQuery = model.supplier.productQuery;

    return FutureBuilder<String?>(
      future: _getTranslatedCountry(context, country),
      builder: (
        final BuildContext context,
        final AsyncSnapshot<String?> snapshot,
      ) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);
        final List<String> messages = <String>[];
        String counting = appLocalizations.user_list_length(
          model.supplier.partialProductList.totalSize,
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
        final int? lastUpdate = model.supplier.timestamp;
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
              child: Text(messages.join('\n')),
            ),
          ),
        );
      },
    );
  }

  Future<String?> _getTranslatedCountry(
    BuildContext context,
    OpenFoodFactsCountry? country,
  ) async {
    if (country == null) {
      return null;
    }

    final String locale = Localizations.localeOf(context).languageCode;
    final List<Country> localizedCountries =
        await IsoCountries.iso_countries_for_locale(locale);
    for (final Country lCountry in localizedCountries) {
      if (lCountry.countryCode.toLowerCase() ==
          country.iso2Code.toLowerCase()) {
        return country.name;
      }
    }

    return null;
  }
}

/// Returns if we should scroll to top
typedef _PageQueryRefreshCallback = Future<bool> Function();

class _PageQueryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _PageQueryAppBar({required this.title, this.elevation, Key? key})
      : super(key: key);

  final String title;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return AppBar(
      backgroundColor: themeData.scaffoldBackgroundColor,
      elevation: elevation,
      automaticallyImplyLeading: false,
      leading: const SmoothBackButton(),
      title: _AppBarTitle(name: title),
      actions: _getAppBarButtons(context),
    );
  }

  List<Widget> _getAppBarButtons(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ProductQueryModel model = context.watch<ProductQueryModel>();
    final PagedProductQuery pagedProductQuery = model.supplier.productQuery;
    final PagedProductQuery? worldQuery = pagedProductQuery.getWorldQuery();

    return <Widget>[
      if (worldQuery != null)
        _getIconButton(
          _getWorldAction(
            context,
            appLocalizations,
            worldQuery,
            title,
          ),
        ),
    ];
  }

  Widget _getIconButton(
    final _PageQueryAction action,
  ) =>
      IconButton(
        tooltip: action.text,
        icon: Icon(action.iconData),
        onPressed: action.onPressed,
      );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

_PageQueryAction _getWorldAction(
  final BuildContext context,
  final AppLocalizations appLocalizations,
  final PagedProductQuery worldQuery,
  final String title,
) =>
    _PageQueryAction(
      text: appLocalizations.world_results_action,
      iconData: Icons.public,
      onPressed: () async => ProductQueryPageHelper().openBestChoice(
        productQuery: worldQuery,
        localDatabase: context.read<LocalDatabase>(),
        name: title,
        context: context,
      ),
    );

// TODO(monsieurtanki): put it in a specific reusable class
class _PageQueryAction {
  _PageQueryAction({
    required this.iconData,
    required this.text,
    required this.onPressed,
  });

  final IconData iconData;
  final String text;
  final VoidCallback onPressed;
}

enum ProductQueryPageResult {
  editProductQuery,
  unknown,
}
