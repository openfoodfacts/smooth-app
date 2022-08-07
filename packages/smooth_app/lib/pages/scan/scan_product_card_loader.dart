import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/scan/scan_product_card.dart';

/// Display of product for the scan page, after async load from local database.
class ScanProductCardLoader extends StatelessWidget {
  const ScanProductCardLoader(this.barcode);

  final String barcode;

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    return FutureBuilder<Product?>(
      future: DaoProduct(localDatabase).get(barcode),
      builder: (
        final BuildContext context,
        final AsyncSnapshot<Product?> snapshot,
      ) {
        if (snapshot.data != null) {
          return ScanProductCard(snapshot.data!);
        }
        // TODO(monsieurtanuki): something like "hey, no product found, click to download) + LOGS
        return Container();
      },
    );
  }
}
