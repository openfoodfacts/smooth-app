import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
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
          final String title;
          if (children.isEmpty) {
            title = 'No price for that product yet!';
          } else if (result.total == 1) {
            title = 'Only one price found for that product.';
          } else if (result.numberOfPages == 1) {
            title = 'All ${result.total} prices for that product';
          } else {
            title =
                'Latest $_pageSize prices for that product (total: ${result.total})';
          }
          children.insert(
            0,
            SmoothCard(child: ListTile(title: Text(title))),
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
