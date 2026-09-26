import 'dart:convert';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/up_to_date_changes.dart';
import 'package:smooth_app/data_models/up_to_date_interest.dart';
import 'package:smooth_app/database/dao_transient_operation.dart';
import 'package:smooth_app/database/local_database.dart';

/// Provider that reflects all the user changes on [Product]s.
class UpToDateProductProvider {
  UpToDateProductProvider(this.localDatabase)
    : _changes = UpToDateChanges(localDatabase);

  final LocalDatabase localDatabase;

  /// For a given barcode, maps the changes.
  final UpToDateChanges _changes;

  /// For a given barcode, returns the latest change timestamp.
  final Map<String, int> _timestamps = <String, int>{};

  /// Latest downloaded product for a barcode.
  final Map<String, Product> _latestDownloadedProducts = <String, Product>{};

  /// Barcodes currently displayed in the app.
  ///
  /// We need to know which barcodes are "interesting" because we need to cache
  /// products in memory for instant access. And we should cache only them,
  /// because we cannot cache all products in memory.
  final UpToDateInterest _interest = UpToDateInterest();

  /// Returns true if at least one barcode was refreshed after the [timestamp].
  bool needsRefresh(final int? latestTimestamp, final List<String> barcodes) {
    if (latestTimestamp == null) {
      // no need to "refresh", need to start instead!
      return false;
    }
    for (final String barcode in barcodes) {
      final int? timestamp = _timestamps[barcode];
      if (timestamp != null && timestamp > latestTimestamp) {
        return true;
      }
    }
    return false;
  }

  /// Shows an interest for a barcode.
  ///
  /// Typically, to be used by a widget in `initState`.
  void showInterest(final String barcode) => _interest.add(barcode);

  /// Loses interest for a barcode.
  ///
  /// Typically, to be used by a widget in `dispose`.
  void loseInterest(final String barcode) {
    final bool lostInterest = _interest.remove(barcode);
    if (!lostInterest) {
      return;
    }
    _latestDownloadedProducts.remove(barcode);
    _timestamps.remove(barcode);
  }

  /// Typical use-case: a product page is refreshed through a pull-gesture.
  void setLatestDownloadedProduct(
    final Product product, {
    final bool notify = true,
  }) {
    _latestDownloadedProducts[product.barcode!] = product;
    _timestamps[product.barcode!] = LocalDatabase.nowInMillis();
    if (notify) {
      localDatabase.notifyListeners();
    }
  }

  /// Typical use-case: a product list page is refreshed through a pull-gesture.
  void setLatestDownloadedProducts(final Iterable<Product> products) {
    if (_interest.isEmpty) {
      return;
    }
    bool atLeastOne = false;
    for (final Product product in products) {
      if (_interest.containsKey(product.barcode!)) {
        atLeastOne = true;
        setLatestDownloadedProduct(product, notify: false);
      }
    }
    if (atLeastOne) {
      localDatabase.notifyListeners();
    }
  }

  /// Returns the [product] with all the local pending changes on top.
  Product getLocalUpToDate(final Product initialProduct) {
    final String barcode = initialProduct.barcode!;
    Product result = copy(_latestDownloadedProducts[barcode] ?? initialProduct);
    result = _changes.getUpToDateProduct(result);
    return result;
  }

  /// Returns true if there are pending operations for that [barcode].
  bool hasPendingChanges(final String barcode) =>
      _changes.hasNotTerminatedOperations(barcode);

  // TODO(monsieurtanuki): move code to off-dart Product?
  Product copy(final Product source) => Product.fromJson(
    jsonDecode(jsonEncode(source.toJson())) as Map<String, dynamic>,
  );

  /// Adds a minimalist local change to pending ones.
  Future<void> addChange(
    final String key,
    final Product minimalistProduct,
  ) async {
    final String barcode = minimalistProduct.barcode!;
    await _changes.add(key, minimalistProduct);
    _timestamps[barcode] = LocalDatabase.nowInMillis();
    localDatabase.notifyListeners();
  }

  /// Returns the local pending change ids related to a [barcode].
  Iterable<TransientOperation>? getSortedChangeOperations(
    final String barcode,
  ) => _changes.getSortedOperations(barcode);

  /// Closes a single operation, successful or failed.
  void terminate(final String operationKey) {
    _changes.terminate(operationKey);
    localDatabase.notifyListeners();
  }
}
