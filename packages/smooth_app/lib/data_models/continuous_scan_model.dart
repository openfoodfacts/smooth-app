import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/barcode_product_query.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_extra.dart';
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
    required bool contributionMode,
    required this.countryCode,
    required this.languageCode,
  }) : _contributionMode = contributionMode;

  final Map<String, ScannedProductState> _states =
      <String, ScannedProductState>{};
  final List<String> _barcodes = <String>[];
  final ProductList _productList =
      ProductList(listType: ProductList.LIST_TYPE_SCAN, parameters: '');

  late bool _contributionMode;
  String? _latestScannedBarcode;
  String? _latestFoundBarcode;
  String? _barcodeTrustCheck; // TODO(monsieurtanuki): could probably be removed
  late DaoProduct _daoProduct;
  late DaoProductList _daoProductList;
  late DaoProductExtra _daoProductExtra;
  final String languageCode;
  final String countryCode;

  bool get isNotEmpty => getBarcodes().isNotEmpty;
  bool get contributionMode => _contributionMode;
  ProductList get productList => _productList;

  List<String> getBarcodes() => _barcodes;

  Future<ContinuousScanModel?> load(final LocalDatabase localDatabase) async {
    try {
      _daoProduct = DaoProduct(localDatabase);
      _daoProductList = DaoProductList(localDatabase);
      _daoProductExtra = DaoProductExtra(localDatabase);
      await _daoProductList.get(_productList);
      for (final String barcode in _productList.barcodes) {
        _barcodes.add(barcode);
        _states[barcode] = ScannedProductState.CACHED;
        _latestScannedBarcode = barcode;
      }
      return this;
    } catch (e) {
      debugPrint('exception: $e');
    }
    return null;
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

  void setupScanner(QRViewController controller) => controller.scannedDataStream
      .listen((Barcode barcode) => onScan(barcode.code));

  Future<void> onScan(final String code) async {
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

  void contributionModeSwitch(bool value) {
    if (_contributionMode != value) {
      _contributionMode = value;
      notifyListeners();
    }
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
    final int? latestUpdate = await _daoProduct.getLastUpdate(barcode);
    if (latestUpdate != null) {
      _addProduct(
          (await _daoProduct.get(barcode))!, ScannedProductState.CACHED);
      return true;
    }
    return false;
  }

  Future<Product?> _queryBarcode(
    final String barcode,
  ) async =>
      BarcodeProductQuery(
        barcode: barcode,
        languageCode: languageCode,
        countryCode: countryCode,
        daoProduct: _daoProduct,
      ).getProduct();

  Future<void> _loadBarcode(
    final String barcode,
  ) async {
    final Product? product = await _queryBarcode(barcode);
    if (product != null) {
      _addProduct(product, ScannedProductState.FOUND);
    } else {
      setBarcodeState(barcode, ScannedProductState.NOT_FOUND);
    }
  }

  Future<void> _updateBarcode(
    final String barcode,
  ) async {
    final Product? product = await _queryBarcode(barcode);
    if (product != null) {
      _addProduct(product, ScannedProductState.FOUND);
    }
  }

  Future<void> _addProduct(
    final Product product,
    final ScannedProductState state,
  ) async {
    _productList.refresh(product);
    if (_latestFoundBarcode != product.barcode!) {
      _latestFoundBarcode = product.barcode;
      await _daoProductExtra.putLastScan(product);
    }
    setBarcodeState(product.barcode!, state);
  }
}
