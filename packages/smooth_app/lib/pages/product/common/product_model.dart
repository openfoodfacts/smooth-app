import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/query/barcode_product_query.dart';

/// Loading status.
enum LoadingStatus {
  /// Loading product from local database.
  LOADING,

  /// Product loaded.
  LOADED,

  /// Error.
  ERROR,

  /// Downloading product from back-end.
  DOWNLOADING,
}

/// Model for product database get and refresh.
class ProductModel with ChangeNotifier {
  /// In the constructor we retrieve async'ly the product from the local db.
  ProductModel(this.barcode, final LocalDatabase localDatabase) {
    _daoProduct = DaoProduct(localDatabase);
    _clear();
    _asyncLoad();
  }

  final String barcode;
  late final DaoProduct _daoProduct;

  Product? _product;
  Product? get product =>
      _loadingStatus == LoadingStatus.LOADED ? _product : null;

  /// General loading status.
  late LoadingStatus _loadingStatus;
  LoadingStatus get loadingStatus => _loadingStatus;

  /// General loading error.
  String? _loadingError;
  String? get loadingError => _loadingError;

  /// Downloading status.
  FetchedProductStatus? _downloadingStatus;
  FetchedProductStatus? get downloadingStatus => _downloadingStatus;

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

  Future<void> _asyncLoad() async {
    try {
      _product = await _daoProduct.get(barcode);
      if (_product != null) {
        // from the local database, no error, perfect!
        _loadingStatus = LoadingStatus.LOADED;
        notifyListeners();
        return;
      }
      await download();
    } catch (e) {
      _loadingError = e.toString();
      _loadingStatus = LoadingStatus.ERROR;
      notifyListeners();
    }
  }

  /// Downloads the product. To be used as a refresh after a network issue.
  Future<void> download() async {
    try {
      _loadingStatus = LoadingStatus.DOWNLOADING;
      notifyListeners();
      final FetchedProduct fetchedProduct = await BarcodeProductQuery(
        barcode: barcode,
        daoProduct: _daoProduct,
        isScanned: false,
      ).getFetchedProduct();
      if (fetchedProduct.status == FetchedProductStatus.ok) {
        _product = fetchedProduct.product;
        _loadingStatus = LoadingStatus.LOADED;
        notifyListeners();
        return;
      }
      _downloadingStatus = fetchedProduct.status;
      _loadingStatus = LoadingStatus.ERROR;
    } catch (e) {
      _loadingError = e.toString();
      _loadingStatus = LoadingStatus.ERROR;
    }
    notifyListeners();
  }
}
