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
    required this.editableAppBarTitle,
  });

  final ProductListSupplier productListSupplier;
  final String name;
  final bool editableAppBarTitle;

  @override
  State<ProductQueryPage> createState() => _ProductQueryPageState();
}

class _ProductQueryPageState extends State<ProductQueryPage>
    with TraceableClientMixin {
  static const int _OVERSCROLL_TEMPLATE_COUNT = 1;

  bool _showBackToTopButton = false;
  late ScrollController _scrollController;

  late ProductQueryModel _model;
  late final OpenFoodFactsCountry? _country;

  @override
  String get traceTitle => 'search_page';

  @override
  String get traceName => 'Opened search_page';

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
            setState(() {});
          }
        } else if (_showBackToTopButton) {
          _showBackToTopButton = false;
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
            return _getErrorWidget(
              screenSize,
              themeData,
              _model.loadingError ?? '',
            );
          case LoadingStatus.LOADING:
            if (_model.isEmpty()) {
              return _EmptyScreen(
                screenSize: screenSize,
                name: widget.name,
                emptiness: const CircularProgressIndicator.adaptive(),
              );
            }
            break;
          case LoadingStatus.LOADED:
            if (_model.isEmpty()) {
              // TODO(monsieurtanuki): should be tracked as well, shouldn't it?
              return _EmptyScreen(
                screenSize: screenSize,
                name: widget.name,
                emptiness: _getEmptyText(
                  themeData,
                  appLocalizations.no_product_found,
                ),
                actions: _getAppBarButtons(),
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

  // TODO(monsieurtanuki): put that in a specific Widget class
  Widget _getNotEmptyScreen(
    final Size screenSize,
    final ThemeData themeData,
    final AppLocalizations appLocalizations,
  ) =>
      SmoothScaffold(
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
          elevation: 2,
          automaticallyImplyLeading: false,
          leading: const SmoothBackButton(),
          title: _AppBarTitle(
            name: widget.name,
            editableAppBarTitle: widget.editableAppBarTitle,
          ),
          actions: _getAppBarButtons(),
        ),
        body: RefreshIndicator(
          onRefresh: () async => _refreshList(),
          child: ListView.builder(
            controller: _scrollController,
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

                if (overscrollIndex <= 0) {
                  return const SmoothProductCardTemplate();
                }
                if (overscrollIndex == 1) {
                  return const Center(child: CircularProgressIndicator());
                }
                return SizedBox(
                  height: MediaQuery.of(context).size.height / 4,
                );
              }
              return ProductListItemSimple(
                barcode: _model.displayBarcodes[index],
              );
            },
            itemCount: _getItemCount(),
          ),
        ),
      );

  int _getItemCount() {
    //  1 additional widget, on top of ALL expected products
    final int count = _model.displayBarcodes.length + 1;

    // +x loading tiles
    // +2 further indicator that more products are loading and some space below
    // but only while more are possible
    if (_model.supplier.partialProductList.totalSize >
        _model.displayBarcodes.length) {
      return count + _OVERSCROLL_TEMPLATE_COUNT + 2;
    }
    return count;
  }

  Widget _getErrorWidget(
    final Size screenSize,
    final ThemeData themeData,
    final String errorMessage,
  ) {
    return _EmptyScreen(
      screenSize: screenSize,
      name: widget.name,
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
              style: themeData.textTheme.subtitle1!.copyWith(fontSize: 18.0),
            ),
          ),
          if (worldQuery != null)
            _getLargeButtonWithIcon(
              _getWorldAction(appLocalizations, worldQuery),
            ),
        ],
      ),
    );
  }

  List<Widget> _getAppBarButtons() {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final PagedProductQuery pagedProductQuery = _model.supplier.productQuery;
    final PagedProductQuery? worldQuery = pagedProductQuery.getWorldQuery();
    return <Widget>[
      if (worldQuery != null)
        _getIconButton(_getWorldAction(appLocalizations, worldQuery)),
    ];
  }

  Widget _getTopMessagesCard() {
    final PagedProductQuery pagedProductQuery = _model.supplier.productQuery;
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
              child: Text(messages.join('\n')),
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
        await IsoCountries.iso_countries_for_locale(locale);
    for (final Country country in localizedCountries) {
      if (country.countryCode.toLowerCase() == _country!.offTag.toLowerCase()) {
        return country.name;
      }
    }
    return null;
  }

  Widget _getLargeButtonWithIcon(final _Action action) =>
      SmoothLargeButtonWithIcon(
        text: action.text,
        icon: action.iconData,
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
  ) =>
      _Action(
        text: appLocalizations.world_results_action,
        iconData: Icons.public,
        onPressed: () async => ProductQueryPageHelper().openBestChoice(
          productQuery: worldQuery,
          localDatabase: context.read<LocalDatabase>(),
          name: widget.name,
          context: context,
        ),
      );

  void retryConnection() =>
      setState(() => _model = _getModel(widget.productListSupplier));

  ProductQueryModel _getModel(final ProductListSupplier supplier) =>
      ProductQueryModel(supplier);

  Future<void> _refreshList() async {
    bool successfullyLoaded = false;
    try {
      successfullyLoaded = await _model.loadFromTop();
    } catch (e) {
      await LoadingDialog.error(
        context: context,
        title: _model.loadingError,
      );
    } finally {
      if (successfullyLoaded) {
        _scrollToTop(instant: true);
      }
      setState(() {});
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
        setState(() {});
      }
    } catch (e) {
      //
    }
    _loadingNext = false;
  }
}

class _EmptyScreen extends StatelessWidget {
  const _EmptyScreen({
    required this.screenSize,
    required this.name,
    required this.emptiness,
    this.actions,
    Key? key,
  }) : super(key: key);

  final Size screenSize;
  final String name;
  final Widget emptiness;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return SmoothScaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: const SmoothBackButton(),
        title: _AppBarTitle(
          name: name,
          editableAppBarTitle: false,
        ),
        actions: actions,
      ),
      body: Center(child: emptiness),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({
    required this.name,
    required this.editableAppBarTitle,
    Key? key,
  }) : super(key: key);

  final String name;
  final bool editableAppBarTitle;

  @override
  Widget build(BuildContext context) {
    final Widget child = AutoSizeText(
      name,
      maxLines: 2,
    );

    if (editableAppBarTitle) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);

      return GestureDetector(
        onTap: () {
          Navigator.of(context).pop(ProductQueryPageResult.editProductQuery);
        },
        child: Tooltip(
          message: appLocalizations.tap_to_edit_search,
          child: child,
        ),
      );
    } else {
      return child;
    }
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

enum ProductQueryPageResult {
  editProductQuery,
  unknown,
}
