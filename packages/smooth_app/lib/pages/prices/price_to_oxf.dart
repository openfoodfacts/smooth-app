import 'dart:async';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/simple_input/simple_input_page_helpers.dart';
import 'package:smooth_app/query/product_query.dart';

/// Tool to update OxF data from Prices data.
class PriceToOxF {
  PriceToOxF._(this._name, this._helper);

  PriceToOxF._store(final Location location)
    : this._(location.name?.trim(), SimpleInputPageStoreHelper());

  PriceToOxF._country(final Location location)
    : this._(
        OpenFoodFactsCountry.fromOffTag(location.countryCode?.trim())?.name,
        SimpleInputPageCountryHelper(null),
      );

  final String? _name;
  final AbstractSimpleInputPageHelper _helper;

  static Future<void> updateOxF({
    required final LocalDatabase localDatabase,
    required final List<String> initialBarcodes,
    required final int locationOSMId,
    required final LocationOSMType locationOSMType,
  }) async {
    final List<String> actualBarcodes = <String>[];
    for (final String barcode in initialBarcodes) {
      if (barcode.isNotEmpty) {
        actualBarcodes.add(barcode);
      }
    }
    if (actualBarcodes.isEmpty) {
      return;
    }

    final MaybeError<Location> maybeLocation =
        await OpenPricesAPIClient.getOSMLocation(
          locationOSMId: locationOSMId,
          locationOSMType: locationOSMType,
          uriHelper: ProductQuery.uriPricesHelper,
        );
    if (maybeLocation.isError) {
      return;
    }
    final Location location = maybeLocation.value;

    final List<PriceToOxF> priceToOxFList = <PriceToOxF>[
      PriceToOxF._store(location),
      PriceToOxF._country(location),
    ];
    bool atLeastOne = false;
    for (final PriceToOxF priceToOxF in priceToOxFList) {
      if (priceToOxF._isOk()) {
        atLeastOne = true;
        break;
      }
    }
    if (!atLeastOne) {
      return;
    }

    final List<String>? refreshedBarcodes = await ProductRefresher()
        .silentFetchAndRefreshList(
          barcodes: actualBarcodes,
          localDatabase: localDatabase,
          productType: ProductType.food,
        );
    if (refreshedBarcodes == null || refreshedBarcodes.isEmpty) {
      return;
    }

    final Map<String, Product> products = await DaoProduct(
      localDatabase,
    ).getAll(refreshedBarcodes);

    for (final Product product in products.values) {
      for (final PriceToOxF priceToOxF in priceToOxFList) {
        await priceToOxF._addTaskIfChanged(
          product: product,
          localDatabase: localDatabase,
        );
      }
    }
  }

  bool _isOk() => _name?.isNotEmpty == true;

  bool _changedNames() {
    for (final String item in _helper.terms) {
      if (item.toLowerCase() == _name!.toLowerCase()) {
        return false;
      }
    }
    _helper.terms.add(_name!);
    return true;
  }

  Future<void> _addTaskIfChanged({
    required final Product product,
    required final LocalDatabase localDatabase,
  }) async {
    if (!_isOk()) {
      return;
    }
    _helper.reInit(product, backgroundTask: true);
    final bool changed = _changedNames();
    if (!changed) {
      return;
    }
    final Product newProduct = Product(barcode: product.barcode)
      ..productType = product.productType;
    _helper.changeProduct(newProduct);
    await BackgroundTaskDetails.addTask(
      newProduct,
      context: null,
      localDatabase: localDatabase,
      stamp: _helper.getStamp(),
      productType: newProduct.productType,
    );
  }
}
