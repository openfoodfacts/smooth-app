import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_button.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/prices_page.dart';

/// Price Count display.
class PriceCountWidget extends StatelessWidget {
  const PriceCountWidget(
    this.count, {
    required this.priceProduct,
    required this.enableCountButton,
  });

  final int count;
  final PriceProduct priceProduct;
  final bool enableCountButton;

  @override
  Widget build(BuildContext context) => PriceButton(
        onPressed: !enableCountButton
            ? null
            : () async {
                final LocalDatabase localDatabase =
                    context.read<LocalDatabase>();
                final Product? newProduct =
                    await DaoProduct(localDatabase).get(priceProduct.code);
                if (!context.mounted) {
                  return;
                }
                return Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => PricesPage(
                      GetPricesModel.product(
                        product: newProduct != null
                            ? PriceMetaProduct.product(newProduct)
                            : PriceMetaProduct.priceProduct(priceProduct),
                        context: context,
                      ),
                    ),
                  ),
                );
              },
        iconData: Icons.label,
        title: '$count',
        buttonStyle: ElevatedButton.styleFrom(
          disabledForegroundColor:
              enableCountButton ? null : _getForegroundColor(),
          disabledBackgroundColor:
              enableCountButton ? null : _getBackgroundColor(),
          foregroundColor: !enableCountButton ? null : _getForegroundColor(),
          backgroundColor: !enableCountButton ? null : _getBackgroundColor(),
        ),
      );

  Color? _getForegroundColor() => switch (count) {
        0 => Colors.red,
        1 => Colors.orange,
        _ => Colors.green,
      };

  Color? _getBackgroundColor() => switch (count) {
        0 => Colors.red[100],
        1 => Colors.orange[100],
        _ => Colors.green[100],
      };
}
