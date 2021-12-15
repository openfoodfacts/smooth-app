import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:openfoodfacts/utils/LanguageHelper.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/barcode_product_query.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';

enum ScannedProductState {
  FOUND,
  NOT_FOUND,
  LOADING,
  THANKS,
  CACHED,
  ERROR,
}

class ContinuousScanModel with ChangeNotifier {
  ContinuousScanModel({
    required this.country,
    required this.language,
  });

  final Map<String, ScannedProductState> _states =
      <String, ScannedProductState>{};
  final List<String> _barcodes = <String>[];
  final ProductList _productList = ProductList.scanSession();

  String? _latestScannedBarcode;
  String? _latestFoundBarcode;
  String? _barcodeTrustCheck; // TODO(monsieurtanuki): could probably be removed
  late DaoProduct _daoProduct;
  late DaoProductList _daoProductList;
  final OpenFoodFactsLanguage? language;
  final OpenFoodFactsCountry? country;

  QRViewController? _qrViewController;

  bool get hasMoreThanOneProduct => getBarcodes().length > 1;
  ProductList get productList => _productList;

  List<String> getBarcodes() => _barcodes;

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
      for (final String barcode in _productList.barcodes.reversed) {
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

  void setBarcodeState(
    final String barcode,
    final ScannedProductState state,
  ) {
    _states[barcode] = state;
    notifyListeners();
  }

  ScannedProductState? getBarcodeState(final String barcode) =>
      _states[barcode];

  Product getProduct(final String barcode) => _productList.getProduct(barcode);

  void setupScanner(QRViewController controller) {
    _qrViewController = controller;
    controller.scannedDataStream.listen((Barcode barcode) => onScan(barcode));
  }

  //Used when navigating away from the QRView itself
  void stopQRView() => _qrViewController?.stopCamera();

  Future<void> onScan(final Barcode barcode) async {
    if (barcode.code == null) {
      return;
    }
    final String code = barcode.code!;
    if (_barcodeTrustCheck != code) {
      _barcodeTrustCheck = code;
      return;
    }
    if (_latestScannedBarcode == code) {
      return;
    }
    _latestScannedBarcode = code;
    _addBarcode(code);
  }

  Future<bool> _addBarcode(final String barcode) async {
    final ScannedProductState? state = getBarcodeState(barcode);
    if (state == null) {
      _barcodes.add(barcode);
      setBarcodeState(barcode, ScannedProductState.LOADING);
      _cacheOrLoadBarcode(barcode);
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
        language: language,
        country: country,
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
        setBarcodeState(barcode, ScannedProductState.NOT_FOUND);
        return;
      case FetchedProductStatus.internetError:
        setBarcodeState(barcode, ScannedProductState.ERROR);
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
        setBarcodeState(barcode, ScannedProductState.NOT_FOUND);
        return;
      case FetchedProductStatus.internetError:
        setBarcodeState(barcode, ScannedProductState.ERROR);
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
    }
    setBarcodeState(product.barcode!, state);
  }

  Future<void> clearScanSession() async {
    await _daoProductList.clear(productList);
    await refresh();
  }

  Future<void> refresh() async {
    await _refresh();
    notifyListeners();
  }
}
