import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_list.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_manager.dart';
import 'package:smooth_app/pages/prices/price_data_widget.dart';
import 'package:smooth_app/pages/prices/price_product_widget.dart';
import 'package:smooth_app/query/product_query.dart';

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
  late final InfiniteScrollPriceManager _priceManager;

  @override
  void initState() {
    super.initState();
    _priceManager = InfiniteScrollPriceManager(
      initialItems: widget.pricesResult?.items ?? <Price>[],
      model: widget.model,
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocalDatabase>();
    return InfiniteScrollList<Price>(
      manager: _priceManager,
    );
  }
}

/// A manager for handling price data with infinite scrolling
class InfiniteScrollPriceManager extends InfiniteScrollManager<Price> {
  InfiniteScrollPriceManager({
    super.initialItems,
    required this.model,
  });

  /// The model containing price query parameters
  final GetPricesModel model;

  @override
  Future<void> fetchData(int pageNumber) async {
    final GetPricesParameters parameters = model.parameters;
    parameters.pageNumber = pageNumber;

    // Use ProductQuery.uriPricesHelper as shown in the example
    final MaybeError<GetPricesResult> result =
        await OpenPricesAPIClient.getPrices(parameters,
            uriHelper: ProductQuery.uriPricesHelper);

    if (result.isError) {
      throw result.detailError;
    }

    final GetPricesResult value = result.value;
    updateItems(
      newItems: value.items!,
      pageNumber: value.pageNumber!,
      totalItems: value.total,
      totalPages: value.numberOfPages,
    );
  }

  @override
  Widget buildItem({
    required BuildContext context,
    required Price item,
  }) {
    final PriceProduct? priceProduct = item.product;
    return SmoothCard(
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
            item,
            model: model,
          ),
        ],
      ),
    );
  }
}
