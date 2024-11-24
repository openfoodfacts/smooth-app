import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/collections_helper.dart';
import 'package:smooth_app/query/barcode_product_query.dart';
import 'package:smooth_app/services/smooth_services.dart';

enum ScannedProductState {
  FOUND,
  NOT_FOUND,
  LOADING,
  CACHED,
  ERROR_INTERNET,
  ERROR_INVALID_CODE,
}

class ContinuousScanModel with ChangeNotifier {
  ContinuousScanModel();

  final Map<String, ScannedProductState> _states =
      <String, ScannedProductState>{};
  final List<String> _barcodes = <String>[];
  final ProductList _productList = ProductList.scanSession();
  final ProductList _scanHistory = ProductList.scanHistory();
  final ProductList _history = ProductList.history();

  String? _latestScannedBarcode;
  String? _latestFoundBarcode;
  String? _latestConsultedBarcode;
  late DaoProduct _daoProduct;
  late DaoProductList _daoProductList;

  ProductList get productList => _productList;

  /// List all barcodes scanned (even products being loaded or not found)
  List<String> getBarcodes() => _barcodes;

  /// List only barcodes where the product exists
  Iterable<String> getAvailableBarcodes() => _states
      .where((MapEntry<String, ScannedProductState> entry) =>
          entry.value == ScannedProductState.FOUND ||
          entry.value == ScannedProductState.CACHED)
      .keys;

  String? get latestConsultedBarcode => _latestConsultedBarcode;

  set lastConsultedBarcode(String? barcode) {
    _latestConsultedBarcode = barcode;
    if (barcode != null) {
      notifyListeners();
    }
  }

  Future<ContinuousScanModel?> load(final LocalDatabase localDatabase) async {
    try {
      _daoProduct = DaoProduct(localDatabase);
      _daoProductList = DaoProductList(localDatabase);

      if (!await _refresh()) {
        return null;
      }
      return this;
    } catch (e) {
      Logs.e('Load database error', ex: e);
    }
    return null;
  }

  Future<bool> _refresh() async {
    try {
      _latestScannedBarcode = null;
      _latestFoundBarcode = null;
      _barcodes.clear();
      _states.clear();
      _latestScannedBarcode = null;
      await refreshProductList();
      for (final String barcode in _productList.barcodes) {
        _barcodes.add(barcode);
        _states[barcode] = ScannedProductState.CACHED;
        _latestScannedBarcode = barcode;
      }

      return true;
    } catch (e) {
      Logs.e('Refresh database error', ex: e);
    }
    return false;
  }

  Future<void> refreshProductList() async => _daoProductList.get(_productList);

  void _setBarcodeState(
    final String barcode,
    final ScannedProductState state,
  ) {
    _states[barcode] = state;
    notifyListeners();
  }

  ScannedProductState? getBarcodeState(final String barcode) =>
      _states[barcode];

  /// Adds a barcode
  /// Will return [true] if this barcode is successfully added
  Future<bool> onScan(String? code) async {
    if (code == null) {
      return false;
    }

    code = _fixBarcodeIfNecessary(code);

    if (_latestScannedBarcode == code || _barcodes.contains(code)) {
      lastConsultedBarcode = code;
      return false;
    }

    AnalyticsHelper.trackEvent(
      AnalyticsEvent.scanAction,
      barcode: code,
    );

    _latestScannedBarcode = code;
    return _addBarcode(code);
  }

  Future<bool> onCreateProduct(String? barcode) async {
    if (barcode == null) {
      return false;
    }
    return _addBarcode(barcode);
  }

  Future<void> retryBarcodeFetch(String barcode) async {
    _setBarcodeState(barcode, ScannedProductState.LOADING);
    await _updateBarcode(barcode);
  }

  Future<bool> _addBarcode(final String barcode) async {
    final ScannedProductState? state = getBarcodeState(barcode);
    if (state == null || state == ScannedProductState.NOT_FOUND) {
      if (!_barcodes.contains(barcode)) {
        _barcodes.add(barcode);
      }
      _setBarcodeState(barcode, ScannedProductState.LOADING);
      _cacheOrLoadBarcode(barcode);
      lastConsultedBarcode = barcode;
      return true;
    }
    if (state == ScannedProductState.FOUND ||
        state == ScannedProductState.CACHED) {
      _barcodes.remove(barcode);
      _barcodes.add(barcode);
      _addProduct(barcode, state);
      if (state == ScannedProductState.CACHED) {
        _updateBarcode(barcode);
      }
      lastConsultedBarcode = barcode;
      return true;
    }
    return false;
  }

  Future<void> _cacheOrLoadBarcode(final String barcode) async {
    final bool cached = await _cachedBarcode(barcode);
    if (!cached) {
      _loadBarcode(barcode);
    }
  }

  Future<bool> _cachedBarcode(final String barcode) async {
    final Product? product = await _daoProduct.get(barcode);
    if (product != null) {
      try {
        // We try to load the fresh copy of product from the server
        final FetchedProduct fetchedProduct =
            await _queryBarcode(barcode).timeout(SnackBarDuration.long);
        if (fetchedProduct.product != null) {
          _addProduct(barcode, ScannedProductState.CACHED);
          return true;
        }
      } on TimeoutException {
        // We tried to load the product from the server,
        // but it was taking more than 5 seconds.
        // So we'll just show the already cached product.
        _addProduct(barcode, ScannedProductState.CACHED);
        return true;
      }
      _addProduct(barcode, ScannedProductState.CACHED);
      return true;
    }
    return false;
  }

  Future<FetchedProduct> _queryBarcode(
    final String barcode,
  ) async =>
      BarcodeProductQuery(
        barcode: barcode,
        daoProduct: _daoProduct,
        isScanned: true,
      ).getFetchedProduct();

  Future<void> _loadBarcode(
    final String barcode,
  ) async {
    final FetchedProduct fetchedProduct = await _queryBarcode(barcode);
    switch (fetchedProduct.status) {
      case FetchedProductStatus.ok:
        _addProduct(barcode, ScannedProductState.FOUND);
        return;
      case FetchedProductStatus.internetNotFound:
        _setBarcodeState(barcode, ScannedProductState.NOT_FOUND);
        return;
      case FetchedProductStatus.internetError:
        _setBarcodeState(barcode, ScannedProductState.ERROR_INTERNET);
        return;
      case FetchedProductStatus.userCancelled:
        // we do nothing
        return;
    }
  }

  Future<void> _updateBarcode(
    final String barcode,
  ) async {
    final FetchedProduct fetchedProduct = await _queryBarcode(barcode);
    switch (fetchedProduct.status) {
      case FetchedProductStatus.ok:
        _addProduct(barcode, ScannedProductState.FOUND);
        return;
      case FetchedProductStatus.internetNotFound:
        _setBarcodeState(barcode, ScannedProductState.NOT_FOUND);
        return;
      case FetchedProductStatus.internetError:
        _setBarcodeState(barcode, ScannedProductState.ERROR_INTERNET);
        return;
      case FetchedProductStatus.userCancelled:
        // we do nothing
        return;
    }
  }

  Future<void> _addProduct(
    final String barcode,
    final ScannedProductState state,
  ) async {
    if (_latestFoundBarcode != barcode) {
      _latestFoundBarcode = barcode;
      await _daoProductList.push(productList, _latestFoundBarcode!);
      await _daoProductList.push(_scanHistory, _latestFoundBarcode!);
      await _daoProductList.push(_history, _latestFoundBarcode!);
      _daoProductList.localDatabase.notifyListeners();
    }
    _setBarcodeState(barcode, state);
  }

  Future<void> clearScanSession() async {
    await _daoProductList.clear(productList);
    await refresh();
  }

  Future<void> removeBarcode(
    final String barcode,
  ) async {
    await _daoProductList.set(
      productList,
      barcode,
      false,
    );

    _barcodes.remove(barcode);
    _states.remove(barcode);

    if (barcode == _latestScannedBarcode) {
      _latestScannedBarcode = null;
    }

    notifyListeners();
  }

  Future<void> refresh() async {
    await _refresh();
    notifyListeners();
  }

  /// Sometimes the scanner may fail, this is a simple fix for now
  /// But could be improved in the future
  String _fixBarcodeIfNecessary(String code) {
    code = code.replaceAll('-', '');

    if (code.length == 12) {
      return '0$code';
    } else {
      return code;
    }
  }

  /// Whether we can show the user an interface to compare products
  /// BUT it doesn't necessary we can't compare yet.
  /// Please refer instead to [compareFeatureAvailable]
  bool get compareFeatureEnabled => getAvailableBarcodes().isNotEmpty;

  /// If we can compare products
  /// (= meaning we have at least two existing products)
  bool get compareFeatureAvailable => getAvailableBarcodes().length >= 2;
}
