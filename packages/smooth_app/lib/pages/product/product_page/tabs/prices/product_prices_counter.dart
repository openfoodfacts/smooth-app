import 'dart:async';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/product_price_refresher.dart';

class PricesCounter extends StatefulWidget {
  const PricesCounter({
    required this.product,
    required this.builder,
    super.key,
  });

  final Product product;
  final Widget Function(
    GetPricesModel model,
    ProductPriceRefresher productPriceRefresher,
    int? count,
  )
  builder;

  @override
  State<PricesCounter> createState() => _PricesCounterState();
}

class _PricesCounterState extends State<PricesCounter> {
  GetPricesModel? _model;
  ProductPriceRefresher? _productPriceRefresher;

  @override
  Widget build(BuildContext context) {
    _model ??= GetPricesModel.product(
      product: PriceMetaProduct.product(widget.product),
      context: context,
    );
    _productPriceRefresher ??= ProductPriceRefresher(
      model: _model!,
      userPreferences: context.read<UserPreferences>(),
      pricesResult: null,
      refreshDisplay: () {
        if (mounted) {
          setState(() {});
        }
      },
    );

    context.watch<LocalDatabase>();
    unawaited(_productPriceRefresher!.runIfNeeded());

    final int? total = _productPriceRefresher!.pricesResult?.total;
    return widget.builder.call(_model!, _productPriceRefresher!, total);
  }
}
