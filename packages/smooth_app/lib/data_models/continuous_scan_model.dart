import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:smooth_app/database/barcode_product_query.dart';
import 'package:smooth_app/database/local_database.dart';

enum ScannedProductState {
  FOUND,
  NOT_FOUND,
  LOADING,
  THANKS,
}

class ContinuousScanModel {
  ContinuousScanModel({@required bool contributionMode})
      : _contributionMode = contributionMode;

  final Map<String, ScannedProductState> _states =
      <String, ScannedProductState>{};
  final Map<String, Product> _products = <String, Product>{};
  final List<String> _barcodes = <String>[];
  bool _contributionMode;
  QRViewController _scannerController;
  String _barcodeTrustCheck;
  LocalDatabase _localDatabase;

  bool get isNotEmpty => getBarcodes().isNotEmpty;
  bool get contributionMode => _contributionMode;

  List<String> getBarcodes() => _barcodes;

  void setBarcodeState(
    final String barcode,
    final ScannedProductState state,
  ) {
    _states[barcode] = state;
    _localDatabase.dummyNotifyListeners();
  }

  ScannedProductState getBarcodeState(final String barcode) => _states[barcode];

  Product getProduct(final String barcode) => _products[barcode];

  void setLocalDatabase(final LocalDatabase localDatabase) =>
      _localDatabase = localDatabase;

  void setupScanner(QRViewController controller) {
    _scannerController = controller;
    _scannerController.scannedDataStream.listen(
      (String barcode) => onScan(barcode),
    );
  }

  List<Product> getFoundProducts() {
    final List<Product> result = <Product>[];
    for (final String barcode in _barcodes) {
      if (getBarcodeState(barcode) == ScannedProductState.FOUND) {
        result.add(_products[barcode]);
      }
    }
    return result;
  }

  Future<void> onScan(String code) async {
    print('Barcode detected : $code');
    if (_barcodeTrustCheck != code) {
      _barcodeTrustCheck = code;
      return;
    }
    _addBarcode(code);
  }

  Future<void> onScanAlt(String code, List<Offset> offsets) async {
    print('Barcode detected : $code');
    _addBarcode(code);
  }

  void contributionModeSwitch(bool value) {
    if (_contributionMode != value) {
      _contributionMode = value;
      _localDatabase.dummyNotifyListeners();
    }
  }

  bool _addBarcode(final String barcode) {
    if (getBarcodeState(barcode) == null) {
      _barcodes.add(barcode);
      setBarcodeState(barcode, ScannedProductState.LOADING);
      _loadBarcode(barcode);
      return true;
    }
    return false;
  }

  Future<void> _loadBarcode(final String barcode) async {
    final Product product = await BarcodeProductQuery(barcode).getProduct();
    if (product != null) {
      _localDatabase.putProduct(product);
      _products[barcode] = product;
      setBarcodeState(barcode, ScannedProductState.FOUND);
    } else {
      setBarcodeState(barcode, ScannedProductState.NOT_FOUND);
    }
  }
}
