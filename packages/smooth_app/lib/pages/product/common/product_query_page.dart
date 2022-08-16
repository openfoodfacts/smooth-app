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
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
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
  });

  final ProductListSupplier productListSupplier;
  final String name;

  @override
  State<ProductQueryPage> createState() => _ProductQueryPageState();
}

class _ProductQueryPageState extends State<ProductQueryPage>
    with TraceableClientMixin {
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
          case LoadingStatus.ERROR:
            return _getErrorWidget(
                screenSize, themeData, '${_model.loadingError}');
          case LoadingStatus.LOADING:
            if (!_model.isNotEmpty()) {
              return _getEmptyScreen(
                screenSize,
                themeData,
                const CircularProgressIndicator(),
              );
            }
            break;
          case LoadingStatus.LOADED:
            if (!_model.isNotEmpty()) {
              // TODO(monsieurtanuki): should be tracked as well, shouldn't it?
              return _getEmptyScreen(
                screenSize,
                themeData,
                _getEmptyText(
                  themeData,
                  appLocalizations.no_product_found,
                ),
                actions: _getAppBarButtons(),
              );
            }
            // TODO(monsieurtanuki): add country, language?
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

  Widget _getEmptyScreen(
    final Size screenSize,
    final ThemeData themeData,
    final Widget emptiness, {
    final List<Widget>? actions,
  }) =>
      SmoothScaffold(
        appBar: AppBar(
          backgroundColor: themeData.scaffoldBackgroundColor,
          leading: const _BackButton(),
          title: _getAppBarTitle(),
          actions: actions,
        ),
        body: Center(child: emptiness),
      );

  Widget _getAppBarTitle() => AutoSizeText(widget.name, maxLines: 2);

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
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: const _BackButton(),
          title: _getAppBarTitle(),
          actions: _getAppBarButtons(),
        ),
        body: RefreshIndicator(
          onRefresh: () => refreshList(),
          child: ListView.builder(
            controller: _scrollController,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                // on top, a message
                return _getTopMessagesCard();
              }
              index--;
              // TODO(monsieurtanuki): maybe call it earlier, like for first unknown page index - 5?
              if (index >= _model.displayBarcodes.length) {
                _downloadNextPage();
              }
              if (index >= _model.displayBarcodes.length) {
                // TODO(monsieurtanuki): maybe display something specific for data being downloaded (the next page) and unknown data (beyond next page)
                return const SmoothProductCardTemplate();
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
            // 1 additional widget, on top of ALL expected products
            itemCount: _model.supplier.partialProductList.totalSize + 1,
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

  Future<String?> _getTranslatedCountry() async {
    if (_country == null) {
      return null;
    }
    final String locale = Localizations.localeOf(context).languageCode;
    final List<Country> localizedCountries =
        await IsoCountries.iso_countries_for_locale(locale);
    for (final Country country in localizedCountries) {
      if (country.countryCode.toLowerCase() ==
          _country!.iso2Code.toLowerCase()) {
        return country.name;
      }
    }
    return null;
  }

  Widget _getEmptyText(
    final ThemeData themeData,
    final String message,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final PagedProductQuery pagedProductQuery = _model.supplier.productQuery;
    final PagedProductQuery? worldQuery = pagedProductQuery.getWorldQuery();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _getTopMessagesCard(),
        Padding(
          padding: const EdgeInsets.all(SMALL_SPACE),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: LARGE_SPACE),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style:
                      themeData.textTheme.subtitle1!.copyWith(fontSize: 18.0),
                ),
              ),
              if (worldQuery != null)
                _getLargeButtonWithIcon(
                  _getWorldAction(appLocalizations, worldQuery),
                ),
            ],
          ),
        ),
        EMPTY_WIDGET,
      ],
    );
  }

  List<Widget> _getAppBarButtons() {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final PagedProductQuery pagedProductQuery = _model.supplier.productQuery;
    final PagedProductQuery? worldQuery = pagedProductQuery.getWorldQuery();
    return <Widget>[
      if (worldQuery != null)
        _getIconButton(_getWorldAction(appLocalizations, worldQuery)),
      _getIconButton(_getRefreshAction(appLocalizations)),
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

  _Action _getRefreshAction(
    final AppLocalizations appLocalizations,
  ) =>
      _Action(
        text: appLocalizations.label_refresh,
        iconData: Icons.refresh,
        onPressed: () async {
          final bool? success =
              await _loadAndRefreshDisplay(_model.loadFromTop());
          if (success == true) {
            _scrollToTop();
          }
        },
      );

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

// TODO(monsieurtanki): put it in a specific Widget class
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
