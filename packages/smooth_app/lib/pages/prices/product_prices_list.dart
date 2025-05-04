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
    final List<Price> initialItems = widget.pricesResult?.items ?? <Price>[];

    _priceManager = InfiniteScrollPriceManager(
      initialItems: initialItems,
      model: widget.model,
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocalDatabase>();
    return InfiniteScrollList<Price>(
      manager: _priceManager,
      itemBuilder: (BuildContext context, Price price) =>
          _buildPriceItem(context, price),
    );
  }

  Widget _buildPriceItem(BuildContext context, Price price) {
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
  }
}

/// A manager for handling price data with infinite scrolling
class InfiniteScrollPriceManager extends InfiniteScrollManager<Price> {
  InfiniteScrollPriceManager({
    required List<Price> initialItems,
    required this.model,
  }) : super(initialItems: initialItems);

  /// The model containing price query parameters
  final GetPricesModel model;

  @override
  Future<void> fetchData(int pageNumber) async {
    final GetPricesParameters parameters = model.parameters;
    parameters.pageNumber = pageNumber;

    final MaybeError<GetPricesResult> result =
        await OpenPricesAPIClient.getPrices(parameters);

    if (result.isError) {
      throw result.detailError;
    }

    final GetPricesResult value = result.value;
    updateItems(
      newItems: value.items ?? <Price>[],
      pageNumber: value.pageNumber ?? pageNumber,
      totalItems: value.total,
      totalPages: value.numberOfPages,
    );
  }

  @override
  Widget buildItem({
    required BuildContext context,
    required Price item,
    required int index,
  }) {
    return const SizedBox();
  }
}
