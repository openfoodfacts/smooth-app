import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';

/// Provides the most up-to-date local product list data for a StatefulWidget.
@optionalTypeArgs
mixin UpToDateProductListMixin<T extends StatefulWidget> on State<T> {
  /// To be used in the `initState` method.
  void initUpToDate(
    final ProductList initialProductList,
    final LocalDatabase localDatabase,
  ) {
    _productList = initialProductList;
    _localDatabase = localDatabase;
    _localDatabase.upToDateProductList.showInterest(initialProductList);
    _localDatabase.upToDateProductList.setLocalUpToDate(
      DaoProductList.getKey(_productList),
      _productList.barcodes,
    );
  }

  late final LocalDatabase _localDatabase;

  late ProductList _productList;

  ProductList get productList => _productList;

  set productList(final ProductList productList) {
    final ProductList previous = _productList;
    _productList = productList;
    _localDatabase.upToDateProductList.showInterest(_productList);
    _localDatabase.upToDateProductList.loseInterest(previous);
    _localDatabase.upToDateProductList.setLocalUpToDate(
      DaoProductList.getKey(_productList),
      _productList.barcodes,
    );
  }

  @override
  void dispose() {
    _localDatabase.upToDateProductList.loseInterest(_productList);
    super.dispose();
  }

  /// Refreshes [upToDateProduct] with the latest available local data.
  ///
  /// To be used in the `build` method, after a call to
  /// `context.watch<LocalDatabase>()`.
  void refreshUpToDate() {
    final List<String> barcodes = _localDatabase.upToDateProductList
        .getLocalUpToDate(_productList);
    _productList.set(barcodes);
  }
}
