import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_controller.dart';
import 'package:smooth_app/pages/prices/price_data_widget.dart';
import 'package:smooth_app/pages/prices/price_location_widget.dart';
import 'package:smooth_app/pages/prices/price_product_widget.dart';

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
  late final InfiniteScrollController<Price, GetPricesParameters>
      _scrollController;

  @override
  void initState() {
    super.initState();
    final List<Price> initialItems = widget.pricesResult?.items ?? <Price>[];

    _scrollController = InfiniteScrollController<Price, GetPricesParameters>(
      initialItems: initialItems,
      fetchItems: _fetchPrices,
      onError: (dynamic error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching prices: $error')),
        );
      },
    );

    if (widget.pricesResult != null) {
      _scrollController.updatePaginationInfo(
        newTotalItems: widget.pricesResult!.total,
        newTotalPages: widget.pricesResult!.numberOfPages,
      );
    }
  }

  Future<(List<Price>, bool)> _fetchPrices(
    GetPricesParameters parameters,
    int page,
  ) async {
    try {
      final MaybeError<GetPricesResult> result =
          await OpenPricesAPIClient.getPrices(
        parameters,
      );

      if (result.isError) {
        throw result.detailError;
      }

      final List<Price> items = result.value.items ?? <Price>[];
      final bool hasMore = page < (result.value.numberOfPages ?? 1);

      // Update pagination info
      _scrollController.updatePaginationInfo(
        newTotalItems: result.value.total,
        newTotalPages: result.value.numberOfPages,
      );

      return (items, hasMore);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocalDatabase>();

    return InfiniteScrollList<Price, GetPricesParameters>(
      controller: _scrollController,
      parameters: widget.model.parameters,
      loadMoreTriggerOffset: 200.0,
      loadingBuilder: (BuildContext context) =>
          const Center(child: CircularProgressIndicator()),
      errorBuilder: (BuildContext context, dynamic error) =>
          Text(error.toString()),
      emptyBuilder: (BuildContext context) => const Text('No prices available'),
      loadingMoreBuilder: (BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      headerBuilder: (BuildContext context) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);

        String title;
        final int totalPages = _scrollController.totalPages ?? 1;
        final int currentPage = _scrollController.currentPage;
        final int itemsCount = _scrollController.items.length;
        final int totalItems = _scrollController.totalItems ?? itemsCount;

        if (totalPages > 1) {
          title = appLocalizations.prices_list_length_many_pages(
            itemsCount,
            totalItems,
          );
          title = '$title ($currentPage / $totalPages)';
        } else {
          title = appLocalizations.prices_list_length_one_page(
            itemsCount,
          );
        }

        final List<Widget> headerChildren = <Widget>[];

        headerChildren.add(
          SmoothCard(child: ListTile(title: Text(title))),
        );

        if (!widget.model.displayEachProduct) {
          // Display the product only once if possible
          for (final Price price in _scrollController.items) {
            final PriceProduct? priceProduct = price.product;
            if (priceProduct == null) {
              continue;
            }
            headerChildren.add(
              SmoothCard(
                child: PriceProductWidget(
                  priceProduct,
                  enableCountButton: widget.model.enableCountButton,
                ),
              ),
            );
            break;
          }
        }

        if (!widget.model.displayEachLocation) {
          // Display the location only once if possible
          for (final Price price in _scrollController.items) {
            final Location? location = price.location;
            if (location == null) {
              continue;
            }
            headerChildren.add(
              SmoothCard(
                child: PriceLocationWidget(location),
              ),
            );
            break;
          }
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: headerChildren,
        );
      },
      footerBuilder: (BuildContext context) =>
          const SizedBox(height: 2 * MINIMUM_TOUCH_SIZE),
      itemBuilder: (BuildContext context, Price price) {
        final PriceProduct? priceProduct = price.product;

        return SmoothCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (widget.model.displayEachProduct && priceProduct != null)
                PriceProductWidget(
                  priceProduct,
                  enableCountButton: widget.model.enableCountButton,
                ),
              PriceDataWidget(
                price,
                model: widget.model,
              ),
            ],
          ),
        );
      },
    );
  }
}
