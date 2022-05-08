import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/barcode_product_query.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';

enum ScannedProductState {
  FOUND,
  NOT_FOUND,
  LOADING,
  THANKS,
  CACHED,
  ERROR,
}

class ContinuousScanModel with ChangeNotifier {
  ContinuousScanModel();

  final Map<String, ScannedProductState> _states =
      <String, ScannedProductState>{};
  final List<String> _barcodes = <String>[];
  final ProductList _productList = ProductList.scanSession();
  final ProductList _history = ProductList.history();

  String? _latestScannedBarcode;
  String? _latestFoundBarcode;
  String? _latestConsultedBarcode;
  String? _barcodeTrustCheck; // TODO(monsieurtanuki): could probably be removed
  late DaoProduct _daoProduct;
  late DaoProductList _daoProductList;

  ProductList get productList => _productList;

  List<String> getBarcodes() => _barcodes;

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
      debugPrint('exception: $e');
    }
    return null;
  }

  Future<bool> _refresh() async {
    try {
      _latestScannedBarcode = null;
      _latestFoundBarcode = null;
      _barcodeTrustCheck = null;
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
      debugPrint('exception: $e');
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

  Product getProduct(final String barcode) => _productList.getProduct(barcode);

  Future<void> onScan(String? code) async {
    if (code == null) {
      return;
    }

    if (_barcodeTrustCheck != code) {
      _barcodeTrustCheck = code;
      return;
    }
    if (_latestScannedBarcode == code || _barcodes.contains(code)) {
      lastConsultedBarcode = code;
      return;
    }
    AnalyticsHelper.trackScannedProduct(barcode: code);

    _latestScannedBarcode = code;
    _addBarcode(code);
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
    if (state == null) {
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
      final Product product = getProduct(barcode);
      _barcodes.remove(barcode);
      _barcodes.add(barcode);
      _addProduct(product, state);

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
      _addProduct(product, ScannedProductState.CACHED);
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
      ).getFetchedProduct();

  Future<void> _loadBarcode(
    final String barcode,
  ) async {
    final FetchedProduct fetchedProduct = await _queryBarcode(barcode);
    switch (fetchedProduct.status) {
      case FetchedProductStatus.ok:
        _addProduct(fetchedProduct.product!, ScannedProductState.FOUND);
        return;
      case FetchedProductStatus.internetNotFound:
        _setBarcodeState(barcode, ScannedProductState.NOT_FOUND);
        return;
      case FetchedProductStatus.internetError:
        _setBarcodeState(barcode, ScannedProductState.ERROR);
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
        _addProduct(fetchedProduct.product!, ScannedProductState.FOUND);
        return;
      case FetchedProductStatus.internetNotFound:
        _setBarcodeState(barcode, ScannedProductState.NOT_FOUND);
        return;
      case FetchedProductStatus.internetError:
        _setBarcodeState(barcode, ScannedProductState.ERROR);
        return;
      case FetchedProductStatus.userCancelled:
        // we do nothing
        return;
    }
  }

  Future<void> _addProduct(
    final Product product,
    final ScannedProductState state,
  ) async {
    _productList.refresh(product);
    if (_latestFoundBarcode != product.barcode!) {
      _latestFoundBarcode = product.barcode;
      await _daoProductList.push(productList, _latestFoundBarcode!);
      await _daoProductList.push(_history, _latestFoundBarcode!);
    }
    _setBarcodeState(product.barcode!, state);
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
    await refresh();
    notifyListeners();
  }

  Future<void> refresh() async {
    await _refresh();
    notifyListeners();
  }
}
