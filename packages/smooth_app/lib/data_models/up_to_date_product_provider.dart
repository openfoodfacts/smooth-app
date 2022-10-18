import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/data_models/up_to_date_changes.dart';
import 'package:smooth_app/database/dao_transient_operation.dart';
import 'package:smooth_app/database/local_database.dart';

/// Provider that reflects changes on [Product]s.
class UpToDateProductProvider {
  UpToDateProductProvider(this.localDatabase)
      : _changes = UpToDateChanges(localDatabase);

  final LocalDatabase localDatabase;

  /// For a given barcode, maps the changes.
  final UpToDateChanges _changes;

  /// For a given barcode, returns the latest change timestamp.
  final Map<String, int> _timestamps = <String, int>{};

  /// Latest product version for a barcode.
  final Map<String, Product> _latestProductVersions = <String, Product>{};

  final Map<String, int> _interestingBarcodes = <String, int>{};

  void showInterest(final String barcode) {
    final int result = (_interestingBarcodes[barcode] ?? 0) + 1;
    _interestingBarcodes[barcode] = result;
  }

  void loseInterest(final String barcode) {
    final int result = (_interestingBarcodes[barcode] ?? 0) - 1;
    if (result <= 0) {
      _interestingBarcodes.remove(barcode);
      _latestProductVersions.remove(barcode);
      _timestamps.remove(barcode);
    } else {
      _interestingBarcodes[barcode] = result;
    }
  }

  /// Returns the [product] with all the local pending changes on top.
  ///
  /// Limited to what has not been already done on that [widgetId].
  ///
  /// Typical use-case:
  /// * I want to display data about a [Product]
  /// * for that I use a [StatefulWidget] that has a [Product] parameter
  /// in its constructor
  /// * I want to have my product automatically impacted by every local change
  ///
  /// Here is the code for that:
  /// ```dart
  /// late Product _product;
  /// late final Product _initialProduct;
  ///
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   _initialProduct = widget.product;
  /// }
  ///
  /// @override
  /// Widget build(BuildContext context) {
  ///   final LocalDatabase localDatabase = context.watch<LocalDatabase>();
  ///   _product = _localDatabase.upToDate.getLocalUpToDate(_initialProduct);
  /// ```
  Product getLocalUpToDate(final Product initialProduct) {
    final String barcode = initialProduct.barcode!;
    Product result = copy(_latestProductVersions[barcode] ?? initialProduct);
    result = _changes.getUpToDateProduct(result);
    return result;
  }

  // TODO(monsieurtanuki): move code to off-dart Product
  Product copy(final Product source) => Product.fromJson(
        jsonDecode(jsonEncode(source.toJson())) as Map<String, dynamic>,
      );

  /// Adds a minimalist local change to the local pending changes.
  void addChange(final Product minimalistProduct) {
    final String? barcode = minimalistProduct.barcode;
    if (barcode == null) {
      // very unlikely
      return;
    }
    _changes.add(minimalistProduct);
    _timestamps[barcode] = LocalDatabase.nowInMillis();
    localDatabase.notifyListeners();
  }

  /// Adds an empty change that will trigger a refresh.
  void addRefreshChange(final String barcode) =>
      addChange(Product(barcode: barcode));

  /// Returns the local pending change ids related to a [barcode].
  Iterable<TransientOperation>? getSortedChangeOperations(
          final String barcode) =>
      _changes.getSortedOperations(barcode);

  /// Returns true if there are pending changes for this [barcode].
  bool hasNotTerminatedOperations(final String barcode) {
    /// Not really pending changes, but changes that ere not properly removed
    /// at the barcode level - not the widget level
    // TODO what about uploads?
    return _changes.hasNotTerminatedOperations(barcode);
  }

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

  Product prepareChangesForServer(
    final String barcode,
    final Iterable<TransientOperation> sortedOperations,
  ) =>
      _changes.prepareChangesForServer(barcode, sortedOperations);

  /// Typical use-case: a product page is refreshed through a pull-gesture.
  void setLatestDownloadedProduct(
    final Product product, {
    final bool notify = true,
  }) {
    _latestProductVersions[product.barcode!] = product;
    if (notify) {
      localDatabase.notifyListeners();
    }
  }

  /// Typical use-case: a product list page is refreshed through a pull-gesture.
  void setLatestDownloadedProducts(
    final Iterable<Product> products, {
    final bool notify = true,
  }) {
    if (_interestingBarcodes.isEmpty) {
      return;
    }
    for (final Product product in products) {
      if (_interestingBarcodes.containsKey(product.barcode)) {
        setLatestDownloadedProduct(product, notify: false);
      }
    }
    if (notify) {
      localDatabase.notifyListeners();
    }
  }

  /// Closes some operations, that are completed.
  void terminate(
    final String barcode,
    final Iterable<TransientOperation> operations,
  ) =>
      _changes.terminate(barcode, operations);
}
