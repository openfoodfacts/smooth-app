import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';

/// Loading status.
enum LoadingStatus {
  LOADING,
  LOADED,
  ERROR,
}

/// Model for product database get and refresh.
class ProductModel with ChangeNotifier {
  /// In the constructor we retrieve async'ly the product from the local db.
  ProductModel(this.barcode, this.localDatabase) {
    _clear();
    _asyncLoad(localDatabase);
  }

  final String barcode;
  final LocalDatabase localDatabase;

  Product? _product;
  Product? get product =>
      _loadingStatus == LoadingStatus.LOADED ? _product : null;

  late LoadingStatus _loadingStatus;
  LoadingStatus get loadingStatus => _loadingStatus;

  String? _loadingError;
  String? get loadingError => _loadingError;

  /// To be called when the up-to-date provider says the product was refreshed.
  void setRefreshedProduct(final Product? product) {
    if (product == null) {
      return;
    }
    _product = product;
    _loadingStatus = LoadingStatus.LOADED;
  }

  void _clear() {
    _loadingStatus = LoadingStatus.LOADING;
    _loadingError = null;
  }

  Future<bool> _asyncLoad(final LocalDatabase localDatabase) async {
    try {
      final DaoProduct daoProduct = DaoProduct(localDatabase);
      _product = await daoProduct.get(barcode);
      _loadingStatus = LoadingStatus.LOADED;
    } catch (e) {
      _loadingError = e.toString();
      _loadingStatus = LoadingStatus.ERROR;
    }
    notifyListeners();
    return _loadingStatus == LoadingStatus.LOADED;
  }
}
