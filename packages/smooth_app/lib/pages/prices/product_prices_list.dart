import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/prices/product_price_item.dart';
import 'package:smooth_app/query/product_query.dart';

/// List of the latest prices for a given product.
class ProductPricesList extends StatefulWidget {
  const ProductPricesList(this.barcode);

  final String barcode;

  @override
  State<ProductPricesList> createState() => _ProductPricesListState();
}

class _ProductPricesListState extends State<ProductPricesList> {
  late final Future<MaybeError<GetPricesResult>> _prices =
      _showProductPrices(widget.barcode);

  static const int _pageSize = 10;

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
          // highly improbable
          if (result.items == null) {
            return const Text('empty list');
          }
          final List<Widget> children = <Widget>[];
          for (final Price price in result.items!) {
            children.add(ProductPriceItem(price));
          }
          final AppLocalizations appLocalizations =
              AppLocalizations.of(context);
          final String title = result.numberOfPages == 1
              ? appLocalizations.prices_list_length_one_page(children.length)
              : appLocalizations.prices_list_length_many_pages(
                  _pageSize,
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

  static Future<MaybeError<GetPricesResult>> _showProductPrices(
    final String barcode, {
    final int pageSize = _pageSize,
    final int pageNumber = 1,
  }) async =>
      OpenPricesAPIClient.getPrices(
        GetPricesParameters()
          ..productCode = barcode
          ..orderBy = <OrderBy<GetPricesOrderField>>[
            const OrderBy<GetPricesOrderField>(
              field: GetPricesOrderField.created,
              ascending: false,
            ),
          ]
          ..pageSize = pageSize
          ..pageNumber = pageNumber,
        uriHelper: ProductQuery.uriProductHelper,
      );
}
