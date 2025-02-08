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

  @override
  void initState() {
    super.initState();
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

  // TODO(monsieurtanuki): add a refresh gesture
  // TODO(monsieurtanuki): add a "download the next 10" items
  @override
  Widget build(BuildContext context) {
    context.watch<LocalDatabase>();
    unawaited(_productPriceRefresher.runIfNeeded());

    switch (_productPriceRefresher.loadingStatus) {
      case null:
      case LoadingStatus.LOADING:
        return const CircularProgressIndicator();
      case LoadingStatus.ERROR:
        return Text(_productPriceRefresher.loadingError.toString());
      case LoadingStatus.LOADED:
        break;
    }
    // highly improbable
    if (_productPriceRefresher.pricesResult!.items == null) {
      return const Text('empty list');
    }

    return _ActualList(
      model: widget.model,
      result: _productPriceRefresher.pricesResult!,
    );
  }
}

class _ActualList extends StatelessWidget {
  const _ActualList({
    required this.model,
    required this.result,
  });

  final GetPricesModel model;
  final GetPricesResult result;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];

    if (!model.displayEachProduct) {
      // in that case we display the product only once, if possible.
      for (final Price price in result.items!) {
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
      for (final Price price in result.items!) {
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

    for (final Price price in result.items!) {
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
    final String title =
        result.numberOfPages != null && result.numberOfPages! <= 1
            ? appLocalizations.prices_list_length_one_page(
                result.items!.length,
              )
            : appLocalizations.prices_list_length_many_pages(
                model.parameters.pageSize!,
                result.total!,
              );
    children.insert(
      0,
      SmoothCard(child: ListTile(title: Text(title))),
    );
    // so that the last content gets not hidden by the FAB
    children.add(
      const SizedBox(height: 2 * MINIMUM_TOUCH_SIZE),
    );
    return ListView(
      children: children,
    );
  }
}
