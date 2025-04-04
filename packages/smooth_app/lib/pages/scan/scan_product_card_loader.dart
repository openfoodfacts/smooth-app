import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_base_card.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_not_supported.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/scan/scan_product_card.dart';

/// Display of product for the scan page, after async load from local database.
class ScanProductCardLoader extends StatelessWidget {
  const ScanProductCardLoader({
    required this.barcode,
    required this.onRemoveProduct,
  });

  final String barcode;
  final OnRemoveCallback onRemoveProduct;

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
          return ScanProductCardFound(
            product: snapshot.data!,
            onRemoveProduct: onRemoveProduct,
          );
        } else {
          return ScanProductCardNotSupported(
            barcode: barcode,
            onRemoveProduct: onRemoveProduct,
          );
        }
      },
    );
  }
}
