import 'dart:async';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_product_image.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';

/// Meta version of a product, coming from OFF or from Prices.
class PriceMetaProduct {
  PriceMetaProduct.category({
    required final String categoryName,
    required final List<String> originNames,
    required final OpenFoodFactsLanguage language,
  })  : _product = null,
        _categoryName = categoryName,
        _categoryTag = _getTag(categoryName, language),
        _originNames = originNames,
        _originTags = _getTags(originNames, language),
        _priceProduct = null,
        _barcode = null;

  PriceMetaProduct.product(final Product product)
      : _product = product,
        _categoryTag = null,
        _categoryName = null,
        _priceProduct = null,
        _barcode = null;

  PriceMetaProduct.priceProduct(final PriceProduct priceProduct)
      : _product = null,
        _categoryTag = null,
        _categoryName = null,
        _priceProduct = priceProduct,
        _barcode = null;

  PriceMetaProduct.unknown(
    final String barcode,
    final LocalDatabase localDatabase,
    final PriceModel priceModel,
  )   : _product = null,
        _categoryTag = null,
        _categoryName = null,
        _priceProduct = null,
        _barcode = barcode {
    unawaited(_search(localDatabase, priceModel));
  }

  static String _getTag(
    final String name,
    final OpenFoodFactsLanguage language,
  ) =>
      '${language.offTag}:$name';

  static List<String> _getTags(
    final List<String> names,
    final OpenFoodFactsLanguage language,
  ) {
    final List<String> result = <String>[];
    for (final String name in names) {
      result.add(_getTag(name, language));
    }
    return result;
  }

  final String? _categoryTag;
  final String? _categoryName;
  List<String>? _originTags;
  List<String>? _originNames;

  PricePer pricePer = PricePer.kilogram;
  Product? _product;
  final PriceProduct? _priceProduct;
  bool _loading = false;
  final String? _barcode;

  String get barcode {
    if (_categoryTag != null) {
      return '';
    }
    if (_product != null) {
      return _product!.barcode!;
    }
    if (_priceProduct != null) {
      return _priceProduct.code;
    }
    return _barcode!;
  }

  String get categoryTag => _categoryTag ?? '';

  String get categoryName => _categoryName ?? '';

  List<String> get originTags =>
      _categoryTag == null ? <String>[] : _originTags!;

  List<String> get originNames =>
      _categoryTag == null ? <String>[] : _originNames!;

  String getName(final AppLocalizations appLocalizations) {
    if (_categoryName != null) {
      return _categoryName;
    }
    if (_product != null) {
      return getProductNameAndBrands(
        _product!,
        appLocalizations,
      );
    }
    if (_priceProduct != null) {
      return _priceProduct.name ?? _priceProduct.code;
    }
    if (barcode.isEmpty) {
      return appLocalizations.prices_barcode_search_none_yet;
    }
    if (_loading) {
      return appLocalizations.prices_barcode_search_running(barcode);
    }
    return appLocalizations.prices_barcode_search_not_found;
  }

  Widget getImageWidget(final double size) {
    if (_product != null) {
      return SmoothMainProductImage(
        product: _product!,
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

  Future<void> _search(
    final LocalDatabase localDatabase,
    final PriceModel priceModel,
  ) async {
    _loading = true;
    try {
      final Product? product = await DaoProduct(localDatabase).get(barcode);
      if (product != null) {
        _product = product;
        return;
      }
      final FetchedProduct fetchAndRefreshed =
          await ProductRefresher().silentFetchAndRefresh(
        localDatabase: localDatabase,
        barcode: barcode,
      );
      if (fetchAndRefreshed.product == null) {
        return;
      }
      _product = fetchAndRefreshed.product;
    } catch (e) {
      // we don't care, it will end up as "unknown product"
    } finally {
      _loading = false;
      priceModel.notifyListeners();
    }
  }
}
