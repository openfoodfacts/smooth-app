// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:openfoodfacts/model/Product.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

// Project imports:
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
}

class ContinuousScanModel with ChangeNotifier {
  ContinuousScanModel({
    @required bool contributionMode,
    @required this.countryCode,
    @required this.languageCode,
  }) : _contributionMode = contributionMode;

  final Map<String, ScannedProductState> _states =
      <String, ScannedProductState>{};
  final List<String> _barcodes = <String>[];
  final ProductList _productList =
      ProductList(listType: ProductList.LIST_TYPE_SCAN, parameters: '');

  bool _contributionMode;
  String _barcodeLatest;
  String _barcodeTrustCheck;
  DaoProduct _daoProduct;
  DaoProductList _daoProductList;
  final String languageCode;
  final String countryCode;

  bool get isNotEmpty => getBarcodes().isNotEmpty;
  bool get contributionMode => _contributionMode;
  ProductList get productList => _productList;

  List<String> getBarcodes() => _barcodes;

  Future<ContinuousScanModel> load(final LocalDatabase localDatabase) async {
    try {
      _daoProduct = DaoProduct(localDatabase);
      _daoProductList = DaoProductList(localDatabase);
      await _daoProductList.get(_productList);
      for (final String barcode in _productList.barcodes) {
        _barcodes.add(barcode);
        _states[barcode] = ScannedProductState.CACHED;
        _barcodeLatest = barcode;
      }
      return this;
    } catch (e) {
      print('exception: $e');
    }
    return null;
  }

  void setBarcodeState(
    final String barcode,
    final ScannedProductState state,
  ) {
    _states[barcode] = state;
    notifyListeners();
  }

  ScannedProductState getBarcodeState(final String barcode) => _states[barcode];

  Product getProduct(final String barcode) => _productList.getProduct(barcode);

  void setupScanner(QRViewController controller) => controller.scannedDataStream
      .listen((Barcode barcode) => onScan(barcode.code));

  List<Product> getProducts() => _productList.getList();

  Future<void> onScan(final String code) async {
    if (_barcodeTrustCheck != code) {
      _barcodeTrustCheck = code;
      return;
    }
    if (_barcodeLatest == code) {
      return;
    }
    _barcodeLatest = code;
    _addBarcode(code);
  }

  void contributionModeSwitch(bool value) {
    if (_contributionMode != value) {
      _contributionMode = value;
      notifyListeners();
    }
  }

  Future<bool> _addBarcode(final String barcode) async {
    final ScannedProductState state = getBarcodeState(barcode);
    if (state == null) {
      _barcodes.add(barcode);
      setBarcodeState(barcode, ScannedProductState.LOADING);
      _cacheOrLoadBarcode(barcode);
      return true;
    }
    if (state == ScannedProductState.FOUND ||
        state == ScannedProductState.CACHED) {
      final Product product = getProduct(barcode);
      _barcodes.add(barcode);
      _addProduct(product, state);
      return true;
    }
    return false;
  }

  Future<void> _cacheOrLoadBarcode(final String barcode) async {
    final bool cached = await _cachedBarcode(barcode);
    if (!cached) {
      _loadBarcode(barcode, ScannedProductState.NOT_FOUND);
    }
  }

  Future<bool> _cachedBarcode(final String barcode) async {
    final int latestUpdate = await _daoProduct.getLastUpdate(barcode);
    if (latestUpdate != null) {
      _addProduct(await _daoProduct.get(barcode), ScannedProductState.CACHED);
      return true;
    }
    return false;
  }

  Future<void> _loadBarcode(
    final String barcode,
    final ScannedProductState notFound,
  ) async {
    final Product product = await BarcodeProductQuery(
      barcode: barcode,
      languageCode: languageCode,
      countryCode: countryCode,
    ).getProduct();
    if (product != null) {
      _addProduct(product, ScannedProductState.FOUND);
    } else {
      setBarcodeState(barcode, notFound);
    }
  }

  Future<void> _addProduct(
    final Product product,
    final ScannedProductState state,
  ) async {
    _productList.add(product);
    _daoProductList.put(_productList);
    setBarcodeState(product.barcode, state);
  }
}
