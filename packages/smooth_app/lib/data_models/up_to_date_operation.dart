import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/data_models/up_to_date_helper.dart';
import 'package:smooth_app/database/local_database.dart';

/// Operations on products: one id, one product change, for all related widgets.
abstract class _UpToDateOperations {
  /// For an operation, lists the already impacted widgets.
  ///
  /// Needed because we need each operation to be performed at most once
  /// on a widget.
  final Map<UpToDateOperationId, List<UpToDateWidgetId>> _done =
      <UpToDateOperationId, List<UpToDateWidgetId>>{};

  /// For a barcode, map of the actions (pending and done).
  final Map<String, Map<UpToDateOperationId, Product>> _actions =
      <String, Map<UpToDateOperationId, Product>>{};

  /// Returns all the actions related to a barcode.
  Map<UpToDateOperationId, Product>? getActions(final String barcode) =>
      _actions[barcode];

  /// Adds an action on a product.
  void add(final Product product, final LocalDatabase localDatabase) {
    final UpToDateOperationId id =
        UpToDateOperationId(localDatabase.getLocalUniqueSequenceNumber());
    final String barcode = product.barcode!;
    _actions[barcode] ??= <UpToDateOperationId, Product>{};
    _actions[barcode]![id] = product;
  }

  /// Terminates some operations.
  void terminate(
    final String barcode,
    final Iterable<UpToDateOperationId> changeIds,
  ) {
    final Map<UpToDateOperationId, Product>? actions = getActions(barcode);
    if (actions == null) {
      // very unlikely
      return;
    }
    final Iterable<UpToDateOperationId> operationIds = actions.keys;
    _done.removeWhere(
      (final UpToDateOperationId operationId, _) =>
          operationIds.contains(operationId),
    );
    actions.removeWhere(
      (final UpToDateOperationId operationId, _) =>
          operationIds.contains(operationId),
    );
  }

  /// Returns true if some actions have not been terminated.
  bool hasNotTerminatedOperations(
    final String barcode,
    final UpToDateWidgetId widgetId,
  ) {
    final Map<UpToDateOperationId, Product>? actions = getActions(barcode);
    return actions != null && actions.isNotEmpty;
  }

  /// Returns the up-to-date product, or null if no changes.
  Product? getUpToDateProduct(
    Product product,
    final UpToDateWidgetId widgetId,
  ) {
    final Map<UpToDateOperationId, Product>? changes =
        getActions(product.barcode!);
    if (changes == null || changes.isEmpty) {
      // no change at all for that product
      return null;
    }
    final List<UpToDateOperationId> changeIds =
        List<UpToDateOperationId>.from(changes.keys);
    changeIds.sort();
    int count = 0;
    for (final UpToDateOperationId changeId in changeIds) {
      final Product minimalistProduct = changes[changeId]!;
      List<UpToDateWidgetId>? done = _done[changeId];
      if (done != null && done.contains(widgetId)) {
        // already done
        continue;
      }
      count++;
      if (done == null) {
        done = <UpToDateWidgetId>[];
        _done[changeId] = done;
      }
      done.add(widgetId);
      product = overwrite(product, minimalistProduct);
    }
    return count == 0 ? null : product;
  }

  /// Removes all actions on a barcode. Use-case: garbage collecting.
  void removeBarcode(final String barcode) {
    final Map<UpToDateOperationId, Product>? map = _actions[barcode];
    if (map == null) {
      // very unlikely
      return;
    }
    _done.removeWhere(
        (final UpToDateOperationId id, final List<UpToDateWidgetId> list) =>
            map.keys.contains(id));
    _actions.remove(barcode);
  }

  /// Applies an action on a product.
  @protected
  Product overwrite(final Product initial, final Product change);
}

/// Succession of minimalist product changes.
class UpToDateChanges extends _UpToDateOperations {
  /// Returns a minimalist [Product] with successive changes on top.
  Product prepareChangesForServer(
    final String barcode,
    final Iterable<UpToDateOperationId> changeIds,
  ) {
    final Product initial = Product(barcode: barcode);
    final List<UpToDateOperationId> changeKeys =
        List<UpToDateOperationId>.from(changeIds);
    changeKeys.sort();
    for (final UpToDateOperationId changeKey in changeKeys) {
      final Product? minimalistProduct = getActions(barcode)?[changeKey];
      if (minimalistProduct == null) {
        // very unlikely
        continue;
      }
      if (initial.barcode != minimalistProduct.barcode) {
        // very unlikely
        continue;
      }
      overwrite(initial, minimalistProduct);
    }
    return initial;
  }

  /// Overwrite the [initial] product with the non-null fields of [change].
  ///
  /// Currently limited to the fields modified by
  /// * [BackgroundTaskDetails]
  /// * [BackgroundTaskImage]
  // TODO(monsieurtanuki): refactor this "à la copyWith" or something like that
  @override
  Product overwrite(final Product initial, final Product change) {
    if (change.productName != null) {
      initial.productName = change.productName;
    }
    if (change.quantity != null) {
      initial.quantity = change.quantity;
    }
    if (change.brands != null) {
      initial.brands = change.brands;
    }
    if (change.ingredientsText != null) {
      initial.ingredientsText = change.ingredientsText;
    }
    if (change.packaging != null) {
      initial.packaging = change.packaging;
    }
    if (change.noNutritionData != null) {
      initial.noNutritionData = change.noNutritionData;
    }
    if (change.nutriments != null) {
      initial.nutriments = change.nutriments;
    }
    if (change.servingSize != null) {
      initial.servingSize = change.servingSize;
    }
    if (change.stores != null) {
      initial.stores = change.stores;
    }
    if (change.origins != null) {
      initial.origins = change.origins;
    }
    if (change.embCodes != null) {
      initial.embCodes = change.embCodes;
    }
    if (change.labels != null) {
      initial.labels = change.labels;
    }
    if (change.categories != null) {
      initial.categories = change.categories;
    }
    if (change.countries != null) {
      initial.countries = change.countries;
    }
    if (change.imageFrontUrl != null) {
      initial.imageFrontUrl = change.imageFrontUrl;
    }
    if (change.imageFrontSmallUrl != null) {
      initial.imageFrontSmallUrl = change.imageFrontSmallUrl;
    }
    if (change.imageIngredientsUrl != null) {
      initial.imageIngredientsUrl = change.imageIngredientsUrl;
    }
    if (change.imageIngredientsSmallUrl != null) {
      initial.imageIngredientsSmallUrl = change.imageIngredientsSmallUrl;
    }
    if (change.imageNutritionUrl != null) {
      initial.imageNutritionUrl = change.imageNutritionUrl;
    }
    if (change.imageNutritionSmallUrl != null) {
      initial.imageNutritionSmallUrl = change.imageNutritionSmallUrl;
    }
    if (change.imagePackagingUrl != null) {
      initial.imagePackagingUrl = change.imagePackagingUrl;
    }
    if (change.imagePackagingSmallUrl != null) {
      initial.imagePackagingSmallUrl = change.imagePackagingSmallUrl;
    }
    return initial;
  }
}

/// Succession of product downloads.
class UpToDateDownloads extends _UpToDateOperations {
  /// Replaces the [initial] product with the latest [change].
  @override
  Product overwrite(final Product initial, final Product change) => change;
}
