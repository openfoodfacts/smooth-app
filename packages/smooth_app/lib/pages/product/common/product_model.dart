import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_last_access.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/product/common/product_loading_status.dart';
import 'package:smooth_app/query/barcode_product_query.dart';

/// Model for product database get and refresh.
class ProductModel with ChangeNotifier {
  /// In the constructor we retrieve async'ly the product from the local db.
  ProductModel(this.barcode, this.localDatabase) {
    localDatabase.upToDate.showInterest(barcode);
    DaoProductLastAccess(localDatabase).put(barcode);
    _asyncLoad();
  }

  final String barcode;
  final LocalDatabase localDatabase;

  DaoProduct get _daoProduct => DaoProduct(localDatabase);

  /// Visible version of the product: local database + local changes on top.
  Product? _product;

  Product? get product =>
      _loadingStatus == ProductLoadingStatus.LOADED ? _product : null;

  /// Latest version of the product from the local database.
  ///
  /// Special case 1: when the product data is [download]ed, it's also stored in
  /// the database.
  /// Special case 2: when there's no data in the database but we have pending
  /// local changes, we "create" a minimalist product (we don't store it in the
  /// database though) in order to put the changes on top of it.
  Product? _databaseProduct;

  /// General loading status.
  ProductLoadingStatus _loadingStatus = ProductLoadingStatus.LOADING;

  ProductLoadingStatus get loadingStatus => _loadingStatus;

  /// General loading error: a failing [FetchedProduct].
  FetchedProduct? _loadingError;

  FetchedProduct? get loadingError => _loadingError;

  @override
  void dispose() {
    localDatabase.upToDate.loseInterest(barcode);
    super.dispose();
  }

  void setLocalUpToDate() {
    if (_databaseProduct == null) {
      _product = null;
      return;
    }
    _product = localDatabase.upToDate.getLocalUpToDate(_databaseProduct!);
  }

  /// Safely notifies listeners.
  ///
  /// The reason behind: there is one case where we display a list of products,
  /// and we display a [MaterialBanner] on top with a Future.delayed(zero).
  /// And of course that scrolls the list downwards. If we're not lucky,
  /// which happens 50% of the time, before the MaterialBanner we asked for
  /// a given product (say, the last on the list) and with the MaterialBanner's
  /// height that product was disposed as it became too far to be visible.
  /// Therefore, we notify the listener of a product that no longer exists.
  /// The [FlutterError] is in [ChangeNotifier] (_debugAssertNotDisposed),
  /// and unfortunately there was no "named" Exception to use
  /// (like "catch(DisposedException)").
  /// This is the printed error:
  /// A ProductModel was used after being disposed.
  /// Once you have called dispose() on a ProductModel, it can no longer be used.
  void _safeNotifyListeners(final ProductLoadingStatus status) {
    try {
      _loadingStatus = status;
      notifyListeners();
    } catch (e) {
      // we don't care
    }
  }

  /// Tries to get the product from the database.
  Future<void> _asyncLoad() async {
    _databaseProduct = await _daoProduct.get(barcode);
    if (_databaseProduct != null) {
      // found in the local database, perfect!
      _safeNotifyListeners(ProductLoadingStatus.LOADED);
      return;
    }
    if (localDatabase.upToDate.hasPendingChanges(barcode)) {
      // not in the local database (because not uploaded + refreshed),
      // but with local not uploaded yet changes.
      // so we use a fake empty product instead.
      _databaseProduct = Product(barcode: barcode);
      _safeNotifyListeners(ProductLoadingStatus.LOADED);
      return;
    }
    // we need to download now!
    await download();
  }

  /// Downloads the product. To be used as a refresh after a network issue.
  Future<void> download() async {
    _safeNotifyListeners(ProductLoadingStatus.DOWNLOADING);
    final FetchedProduct fetchedProduct = await BarcodeProductQuery(
      barcode: barcode,
      daoProduct: _daoProduct,
      isScanned: false,
    ).getFetchedProduct();
    if (fetchedProduct.status == FetchedProductStatus.ok) {
      _databaseProduct = fetchedProduct.product;
      _safeNotifyListeners(ProductLoadingStatus.LOADED);
      return;
    }
    _loadingError = fetchedProduct;
    _safeNotifyListeners(ProductLoadingStatus.ERROR);
  }
}
