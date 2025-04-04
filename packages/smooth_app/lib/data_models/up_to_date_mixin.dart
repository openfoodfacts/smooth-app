import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_manager.dart';
import 'package:smooth_app/database/local_database.dart';

/// Provides the most up-to-date local product data for a StatefulWidget.
///
/// Typically we have
/// * a product from the database (downloaded from the server)
/// * potentially pending changes to apply on top while they're being uploaded
///
/// With this mixin
/// * we get the most up-to-date local product data
/// * we re-launch the task manager if relevant
/// * we track the barcodes currently "opened" by the app
@optionalTypeArgs
mixin UpToDateMixin<T extends StatefulWidget> on State<T> {
  /// To be used in the `initState` method, just after `super.initState();`.
  void initUpToDate(
    final Product initialProduct,
    final LocalDatabase localDatabase,
  ) {
    _initialProduct = initialProduct;
    _localDatabase = localDatabase;
    _refreshUpToDate();
    localDatabase.upToDate.showInterest(barcode);
  }

  late final Product _initialProduct;

  late final LocalDatabase _localDatabase;

  late Product _product;

  @protected
  String get barcode => _initialProduct.barcode!;

  @protected
  Product get upToDateProduct => _product;

  @override
  void dispose() {
    _localDatabase.upToDate.loseInterest(barcode);
    super.dispose();
  }

  /// Refreshes [upToDateProduct] with the latest available local data.
  ///
  /// To be used in the `build` method, after a call to
  /// `context.watch<LocalDatabase>()`.
  void refreshUpToDate() {
    BackgroundTaskManager.runAgain(_localDatabase);
    _refreshUpToDate();
  }

  void _refreshUpToDate() =>
      _product = _localDatabase.upToDate.getLocalUpToDate(_initialProduct);
}
