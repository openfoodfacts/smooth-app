import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/pages/product/common/loading_status.dart';

/// Search location model.
class SearchLocationModel with ChangeNotifier {
  SearchLocationModel(this._supplier) {
    _asyncLoad(notify: true);
  }

  ProductListSupplier _supplier;

  ProductListSupplier get supplier => _supplier;

  late LoadingStatus _loadingStatus;
  String? _loadingError;
  List<String> displayBarcodes = <String>[];

  bool isEmpty() => displayBarcodes.isEmpty;

  String? get loadingError => _loadingError;
  LoadingStatus get loadingStatus => _loadingStatus;

  Future<bool> _asyncLoad({
    final bool notify = false,
    final bool fromScratch = false,
  }) async {
    _loadingStatus = LoadingStatus.LOADING;
    _loadingError = await supplier.asyncLoad();
    if (_loadingError != null) {
      _loadingStatus = LoadingStatus.ERROR;
    } else {
      await _process(supplier.partialProductList.getBarcodes(), fromScratch);
      _loadingStatus = LoadingStatus.LOADED;
    }
    if (notify) {
      notifyListeners();
    }
    return _loadingStatus == LoadingStatus.LOADED;
  }

  Future<bool> loadNextPage() async {
    final ProductListSupplier? refreshSupplier = supplier.getRefreshSupplier();
    if (refreshSupplier != null) {
      // in that case, we were on a database supplier, on an empty page
      _supplier = refreshSupplier;
    } else {
      // in that case, we were on a back-end supplier, on a loaded page
      supplier.productQuery.toNextPage();
    }
    return _asyncLoad();
  }

  Future<void> _process(
    final List<String> barcodes,
    final bool fromScratch,
  ) async {
    if (fromScratch) {
      await supplier.clearBeyondTopPage();
      displayBarcodes.clear();
    }
    displayBarcodes.addAll(barcodes);
    _loadingStatus = LoadingStatus.LOADED;
  }
}
