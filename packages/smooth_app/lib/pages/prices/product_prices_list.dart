import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_controller.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_list.dart';
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
  late final InfiniteScrollController<Price, GetPricesParameters,
      GetPricesResult> _scrollController;

  @override
  void initState() {
    super.initState();
    final List<Price> initialItems = widget.pricesResult?.items ?? <Price>[];

    _scrollController =
        InfiniteScrollController<Price, GetPricesParameters, GetPricesResult>(
      fetchResult: _fetchPricesResult,
      extractItems: _extractPriceItems,
      initialItems: initialItems,
    );
  }

  Future<GetPricesResult> _fetchPricesResult(
      GetPricesParameters parameters, int page,
      {void Function(int? totalItems, int? totalPages)?
          onPageInfoUpdated}) async {
    final MaybeError<GetPricesResult> result =
        await OpenPricesAPIClient.getPrices(
      parameters..pageNumber = page,
    );

    if (onPageInfoUpdated != null) {
      onPageInfoUpdated(result.value.total, result.value.numberOfPages);
    }

    return result.value;
  }

  List<Price> _extractPriceItems(GetPricesResult result) {
    return result.items ?? <Price>[];
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocalDatabase>();
    return InfiniteScrollList<Price, GetPricesParameters, GetPricesResult>(
      controller: _scrollController,
      parameters: widget.model.parameters,
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
