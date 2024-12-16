import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
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
  late final Future<MaybeError<GetPricesResult>> _prices = _showProductPrices();

  // TODO(monsieurtanuki): add a refresh gesture
  // TODO(monsieurtanuki): add a "download the next 10" items
  @override
  Widget build(BuildContext context) =>
      FutureBuilder<MaybeError<GetPricesResult>>(
        future: _prices,
        builder: (
          final BuildContext context,
          final AsyncSnapshot<MaybeError<GetPricesResult>> snapshot,
        ) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text(snapshot.error!.toString());
          }
          // highly improbable
          if (!snapshot.hasData) {
            return const Text('no data');
          }
          if (snapshot.data!.isError) {
            return Text(snapshot.data!.error!);
          }
          final GetPricesResult result = snapshot.data!.value;
          if (widget.model.lazyCounterPrices != null && result.total != null) {
            unawaited(
              widget.model.lazyCounterPrices!.setLocalCount(
                result.total!,
                context.read<UserPreferences>(),
                notify: true,
              ),
            );
          }
          // highly improbable
          if (result.items == null) {
            return const Text('empty list');
          }
          final List<Widget> children = <Widget>[];

          if (!widget.model.displayProduct) {
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
                    model: widget.model,
                  ),
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
                    if (widget.model.displayProduct && priceProduct != null)
                      PriceProductWidget(
                        priceProduct,
                        model: widget.model,
                      ),
                    PriceDataWidget(
                      price,
                      model: widget.model,
                    ),
                  ],
                ),
              ),
            );
          }
          final AppLocalizations appLocalizations =
              AppLocalizations.of(context);
          final String title =
              result.numberOfPages != null && result.numberOfPages! <= 1
                  ? appLocalizations.prices_list_length_one_page(
                      result.items!.length,
                    )
                  : appLocalizations.prices_list_length_many_pages(
                      widget.model.parameters.pageSize!,
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
        },
      );

  Future<MaybeError<GetPricesResult>> _showProductPrices() async {
    if (widget.pricesResult != null) {
      return MaybeError<GetPricesResult>.value(widget.pricesResult!);
    }
    return OpenPricesAPIClient.getPrices(
      widget.model.parameters,
      uriHelper: ProductQuery.uriPricesHelper,
    );
  }
}
