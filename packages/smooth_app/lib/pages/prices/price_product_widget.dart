import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/price_header_container.dart';

/// Price Product display (no price data here).
///
/// See also [PriceCategoryWidget], that deals with "no barcode" products.
class PriceProductWidget extends StatelessWidget {
  const PriceProductWidget(this.priceProduct);

  final PriceProduct priceProduct;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String name = priceProduct.name ?? priceProduct.code;
    final bool unknown = priceProduct.name == null;
    final String? imageURL = priceProduct.imageURL;
    final int? priceCount = priceProduct.priceCount;
    final List<String>? brands = priceProduct.brands == ''
        ? null
        : priceProduct.brands?.split(',');
    final String? quantity = priceProduct.quantity == null
        ? null
        : '${priceProduct.quantity} ${priceProduct.quantityUnit ?? 'g'}';

    return PriceHeaderContainer(
      imageProvider: imageURL != null ? NetworkImage(imageURL) : null,
      line1: name,
      line2: brands?.join(',${appLocalizations.sep}'),
      line3: quantity,
      count: priceCount,
      warningIndicator: unknown,
      semanticsLabel: _generateSemanticsLabel(
        appLocalizations,
        name,
        brands,
        quantity,
        priceCount,
      ),
    );
  }

  String _generateSemanticsLabel(
    AppLocalizations appLocalizations,
    String productName,
    List<String>? brands,
    String? quantity,
    int? priceCount,
  ) {
    final StringBuffer product = StringBuffer(productName);
    if (brands?.isNotEmpty == true) {
      product.write(' - ${brands!.join(', ')}');
    }
    if (quantity?.isNotEmpty == true) {
      product.write(' ($quantity)');
    }

    return appLocalizations.prices_product_accessibility_summary(
      priceCount ?? 0,
      product.toString(),
    );
  }
}
