import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_product_image.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';

/// Meta version of a product, coming from OFF or from Prices.
class PriceMetaProduct {
  PriceMetaProduct.product(final Product product)
      : _product = product,
        _priceProduct = null,
        _barcode = null;
  PriceMetaProduct.priceProduct(final PriceProduct priceProduct)
      : _product = null,
        _priceProduct = priceProduct,
        _barcode = null;
  PriceMetaProduct.empty()
      : _product = null,
        _priceProduct = null,
        _barcode = null;
  PriceMetaProduct.unknown(final String barcode)
      : _product = null,
        _priceProduct = null,
        _barcode = barcode;

  final Product? _product;
  final PriceProduct? _priceProduct;
  final String? _barcode;

  // TODO(monsieurtanuki): refine this test
  bool get isValid => barcode.length >= 8;

  String get barcode {
    if (_product != null) {
      return _product.barcode!;
    }
    if (_priceProduct != null) {
      return _priceProduct.code;
    }
    return _barcode ?? '';
  }

  String getName(final AppLocalizations appLocalizations) {
    if (_product != null) {
      return getProductNameAndBrands(
        _product,
        appLocalizations,
      );
    }
    if (_priceProduct != null) {
      return _priceProduct.name ?? _priceProduct.code;
    }
    if (barcode.isEmpty) {
      return appLocalizations.prices_barcode_search_none_yet;
    }
    return appLocalizations.prices_barcode_search_not_found;
  }

  Widget getImageWidget(final double size) {
    if (_product != null) {
      return SmoothMainProductImage(
        product: _product,
        width: size,
        height: size,
      );
    }
    if (_priceProduct != null) {
      final String? imageURL = _priceProduct.imageURL;
      return SmoothImage(
        width: size,
        height: size,
        imageProvider: imageURL == null ? null : NetworkImage(imageURL),
      );
    }
    return SmoothImage(
      width: size,
      height: size,
    );
  }
}
