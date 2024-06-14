import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';

/// Meta version of a product, coming from OFF or from Prices.
class PriceMetaProduct {
  PriceMetaProduct.product(Product this.product) : priceProduct = null;
  PriceMetaProduct.priceProduct(PriceProduct this.priceProduct)
      : product = null;

  final Product? product;
  final PriceProduct? priceProduct;

  String get barcode =>
      product != null ? product!.barcode! : priceProduct!.code;

  String getName(final AppLocalizations appLocalizations) => product != null
      ? getProductNameAndBrands(
          product!,
          appLocalizations,
        )
      : priceProduct!.name ?? priceProduct!.code;

  String? get imageUrl => product != null ? null : priceProduct!.imageURL;
}
