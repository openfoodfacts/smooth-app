import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_data_widget.dart';
import 'package:smooth_app/pages/prices/price_location_widget.dart';
import 'package:smooth_app/pages/prices/price_product_widget.dart';
import 'package:smooth_app/pages/prices/product_price_refresher.dart';
import 'package:smooth_app/pages/product/common/loading_status.dart';

/// List of the latest prices for a given model.
class ProductPricesList extends StatefulWidget {
  const ProductPricesList(
    this.model, {
    this.pricesResult,
  });

  final GetPricesModel model;
  final GetPricesResult? pricesResult;

  @override
  State<ProductPricesList> createState() => _ProductPricesListState();
}

class _ProductPricesListState extends State<ProductPricesList>
    with TraceableClientMixin {
  late final ProductPriceRefresher _productPriceRefresher;
  late final ScrollController _scrollController;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  List<Price> _allItems = <Price>[];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _productPriceRefresher = ProductPriceRefresher(
      model: widget.model,
      userPreferences: context.read<UserPreferences>(),
      pricesResult: widget.pricesResult,
      refreshDisplay: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_isLoadingMore) {
      return;
    }

    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    final GetPricesResult? currentResult = _productPriceRefresher.pricesResult;

    if (currentResult == null ||
        currentResult.numberOfPages == null ||
        _currentPage >= currentResult.numberOfPages!) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;

    final LoadMorePricesHelper loadMoreHelper = LoadMorePricesHelper(
      model: widget.model,
      page: _currentPage,
      onComplete: (List<Price> newItems) {
        setState(() {
          if (newItems.isNotEmpty) {
            _allItems.addAll(newItems);
          }
          _isLoadingMore = false;
        });
      },
      onError: (String error) {
        setState(() {
          _isLoadingMore = false;
        });
      },
    );

    await loadMoreHelper.load();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _currentPage = 1;
      _allItems = <Price>[];
    });
    await _productPriceRefresher.refresh();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocalDatabase>();
    unawaited(_productPriceRefresher.runIfNeeded());

    switch (_productPriceRefresher.loadingStatus) {
      case null:
      case LoadingStatus.LOADING:
        return const Center(child: CircularProgressIndicator());
      case LoadingStatus.ERROR:
        return Text(_productPriceRefresher.loadingError.toString());
      case LoadingStatus.LOADED:
        // Initialize _allItems with the first page of results
        if (_allItems.isEmpty &&
            _productPriceRefresher.pricesResult?.items != null) {
          _allItems =
              List<Price>.from(_productPriceRefresher.pricesResult!.items!);
        }
        break;
    }

    // highly improbable
    if (_allItems.isEmpty) {
      return const Text('empty list');
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: _ActualList(
        model: widget.model,
        items: _allItems,
        scrollController: _scrollController,
        isLoadingMore: _isLoadingMore,
        currentPage: _currentPage,
        totalPages: _productPriceRefresher.pricesResult?.numberOfPages ?? 1,
        totalItems:
            _productPriceRefresher.pricesResult?.total ?? _allItems.length,
      ),
    );
  }
}

/// Helper class to load more prices
class LoadMorePricesHelper {
  LoadMorePricesHelper({
    required this.model,
    required this.page,
    required this.onComplete,
    required this.onError,
  });

  final GetPricesModel model;
  final int page;
  final Function(List<Price>) onComplete;
  final Function(String) onError;

  Future<void> load() async {
    try {
      // Clone the parameters for the next request
      final GetPricesParameters parameters = model.parameters;

      final MaybeError<GetPricesResult> result =
          await OpenPricesAPIClient.getPrices(
        parameters,
      );

      if (result.isError) {
        onError(result.detailError);
        return;
      }

      if (result.value.items != null) {
        onComplete(result.value.items!);
      } else {
        onComplete(<Price>[]);
      }
    } catch (e) {
      onError(e.toString());
    }
  }
}

class _ActualList extends StatelessWidget {
  const _ActualList({
    required this.model,
    required this.items,
    required this.scrollController,
    required this.isLoadingMore,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final GetPricesModel model;
  final List<Price> items;
  final ScrollController scrollController;
  final bool isLoadingMore;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];

    if (!model.displayEachProduct) {
      // in that case we display the product only once, if possible.
      for (final Price price in items) {
        final PriceProduct? priceProduct = price.product;
        if (priceProduct == null) {
          continue;
        }
        children.add(
          SmoothCard(
            child: PriceProductWidget(
              priceProduct,
              enableCountButton: model.enableCountButton,
            ),
          ),
        );
        break;
      }
    }
    if (!model.displayEachLocation) {
      // in that case we display the location only once, if possible.
      for (final Price price in items) {
        final Location? location = price.location;
        if (location == null) {
          continue;
        }
        children.add(
          SmoothCard(
            child: PriceLocationWidget(location),
          ),
        );
        break;
      }
    }

    for (final Price price in items) {
      final PriceProduct? priceProduct = price.product;
      children.add(
        SmoothCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (model.displayEachProduct && priceProduct != null)
                PriceProductWidget(
                  priceProduct,
                  enableCountButton: model.enableCountButton,
                ),
              PriceDataWidget(
                price,
                model: model,
              ),
            ],
          ),
        ),
      );
    }
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    String title;
    if (totalPages > 1) {
      title = appLocalizations.prices_list_length_many_pages(
        items.length,
        totalItems,
      );
      title = '$title ($currentPage / $totalPages)';
    } else {
      title = appLocalizations.prices_list_length_one_page(
        items.length,
      );
    }

    children.insert(
      0,
      SmoothCard(child: ListTile(title: Text(title))),
    );
    if (isLoadingMore) {
      children.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    children.add(
      const SizedBox(height: 2 * MINIMUM_TOUCH_SIZE),
    );

    return ListView(
      controller: scrollController,
      children: children,
    );
  }
}
