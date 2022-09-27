import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/data_models/up_to_date_helper.dart';
import 'package:smooth_app/data_models/up_to_date_operation.dart';
import 'package:smooth_app/database/local_database.dart';

/// Provider that reflects all the user changes on [Product]s.
class UpToDateProductProvider {
  UpToDateProductProvider(this.localDatabase);

  final LocalDatabase localDatabase;

  // TODO(monsieurtanuki): should be more persistent, like in hive.
  /// For a given barcode, maps the changes.
  final UpToDateChanges _changes = UpToDateChanges();

  /// For a given barcode, maps the quick changes.
  ///
  /// Typical quick change: after an image upload, we download the product
  /// whose related fields are populated. No need to download again the product:
  /// we just quickly set the fields in the up-to-date product.
  final UpToDateChanges _quickChanges = UpToDateChanges();

  /// For a given barcode, maps the downloads.
  final UpToDateDownloads _downloads = UpToDateDownloads();

  /// For a given barcode, list the impacted widgets.
  final UpToDateBarcodeWidgets _barcodeWidgets = UpToDateBarcodeWidgets();

  /// For a given barcode, returns the latest change timestamp.
  final Map<String, int> _timestamps = <String, int>{};

  /// Returns a new unique widget id - to be called in the widget's initState.
  UpToDateWidgetId getWidgetId() =>
      UpToDateWidgetId(localDatabase.getLocalUniqueSequenceNumber());

  /// Dispose a widget - to be called in the widget's dispose method.
  void disposeWidget(final UpToDateWidgetId widgetId) {
    final String? barcode = _barcodeWidgets.getBarcode(widgetId);
    if (barcode == null) {
      // very unlikely
      return;
    }
    if (_barcodeWidgets.remove(barcode, widgetId)) {
      // if the barcode has no widgets anymore
      _changes.removeBarcode(barcode);
      _quickChanges.removeBarcode(barcode);
      _downloads.removeBarcode(barcode);
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
  /// late LocalDatabase _localDatabase;
  /// late final UpToDateWidgetId _upToDateId;
  ///
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   _product = Product(barcode: widget.barcode);
  ///   _localDatabase = context.read<LocalDatabase>();
  ///   _upToDateId = _localDatabase.upToDate.getWidgetId();
  /// }
  ///
  /// @override
  /// void dispose() {
  ///   _localDatabase.upToDate.disposeWidget(_upToDateId);
  ///   super.dispose();
  /// }
  ///
  /// @override
  /// Widget build(BuildContext context) {
  ///   final LocalDatabase localDatabase = context.watch<LocalDatabase>();
  ///   _localDatabase = context.watch<LocalDatabase>();
  ///   _product = _localDatabase.upToDate.getLocalUpToDate(_product, _upToDateId);
  /// ```
  Product getLocalUpToDate(
    final Product product,
    final UpToDateWidgetId widgetId,
  ) {
    Product? result;
    final String barcode = product.barcode!;
    _barcodeWidgets.put(barcode, widgetId);
    result = _quickChanges.getUpToDateProduct(product, widgetId);
    if (result != null) {
      return result;
    }
    result = _changes.getUpToDateProduct(product, widgetId);
    if (result != null) {
      return result;
    }
    result = _downloads.getUpToDateProduct(product, widgetId);
    if (result != null) {
      return result;
    }
    return product;
  }

  /// Adds a minimalist local change to the local pending changes.
  void addChange(final Product minimalistProduct) {
    final String? barcode = minimalistProduct.barcode;
    if (barcode == null) {
      // very unlikely
      return;
    }
    _changes.add(minimalistProduct, localDatabase);
    _timestamps[barcode] = LocalDatabase.nowInMillis();
    localDatabase.notifyListeners();
  }

  /// Adds a minimalist quick local change to the local pending changes.
  void addQuickChange(final Product minimalistProduct) {
    final String? barcode = minimalistProduct.barcode;
    if (barcode == null) {
      // very unlikely
      return;
    }
    _quickChanges.add(minimalistProduct, localDatabase);
    _timestamps[barcode] = LocalDatabase.nowInMillis();
    localDatabase.notifyListeners();
  }

  /// Returns the local pending change ids related to a [barcode].
  Iterable<UpToDateOperationId>? getChangeIds(final String barcode) =>
      _changes.getActions(barcode)?.keys;

  /// Returns true if there are pending changes for this [barcode].
  bool hasNotTerminatedOperations(final UpToDateWidgetId widgetId) {
    /// Not really pending changes, but changes that ere not properly removed
    /// at the barcode level - not the widget level
    final String? barcode = _barcodeWidgets.getBarcode(widgetId);
    if (barcode == null) {
      // very unlikely
      return false;
    }
    if (_changes.hasNotTerminatedOperations(barcode, widgetId)) {
      return true;
    }
    return false;
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
    final Iterable<UpToDateOperationId> changeIds,
  ) =>
      _changes.prepareChangesForServer(barcode, changeIds);

  void setLatestDownloadedProduct(final Product product) =>
      _downloads.add(product, localDatabase);

  /// Closes some operations, that are completed.
  void terminate(
    final String barcode,
    final Iterable<UpToDateOperationId> changeIds,
  ) =>
      _changes.terminate(barcode, changeIds);
}
