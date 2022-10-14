import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/data_models/operation_type.dart';
import 'package:smooth_app/data_models/up_to_date_helper.dart';
import 'package:smooth_app/database/dao_transient_operation.dart';
import 'package:smooth_app/database/local_database.dart';

/// Transient operations on products, for all related widgets.
abstract class _UpToDateOperations {
  _UpToDateOperations(this.localDatabase)
      : _daoTransientProduct = DaoTransientOperation(localDatabase);

  final LocalDatabase localDatabase;

  /// For a barcode, map of the actions (pending and done).
  final DaoTransientOperation _daoTransientProduct;

  /// Returns all the actions related to a barcode, sorted by id.
  Iterable<TransientOperation> getSortedActions(final String barcode) {
    final List<TransientOperation> result = <TransientOperation>[];
    for (final TransientOperation transientProduct
        in _daoTransientProduct.getAll(barcode)) {
      if (taskActionable.matches(transientProduct)) {
        result.add(transientProduct);
      }
    }
    result.sort(
      (final TransientOperation a, final TransientOperation b) =>
          OperationType.sort(a.key, b.key),
    );
    return result;
  }

  OperationType get taskActionable;

  /// Adds an action on a product.
  void add(final Product product, final LocalDatabase localDatabase) =>
      _daoTransientProduct.insert(
        taskActionable.getNewKey(localDatabase, product.barcode!),
        product,
      );

  /// Terminates some operations.
  void terminate(
    final String barcode,
    final Iterable<TransientOperation> changeIds,
  ) {
    print('terminate0');
    for (final TransientOperation transientProduct in changeIds) {
      print('terminate1/delete/${transientProduct.key}');
      _daoTransientProduct.delete(transientProduct.key);
    }
    print('terminate9');
    //final Iterable<TransientProduct> actions = getActions(barcode);
    // TODO
    /*
    final Iterable<UpToDateOperationId> operationIds = actions.keys;
    print('operationIds: $operationIds');
    _impactedWidgets.removeWhere(
      (final UpToDateOperationId operationId, _) =>
          operationIds.contains(operationId),
    );
    print('actionsA: $actions');
    actions.removeWhere(
      (final UpToDateOperationId operationId, _) =>
          operationIds.contains(operationId),
    );
    print('actionsW: $actions');
    print('actionsY: ${getActions(barcode)}');

     */
  }

  /// Returns true if some actions have not been terminated.
  bool hasNotTerminatedOperations(
    final String barcode,
    final UpToDateWidgetId widgetId,
  ) {
    final Iterable<TransientOperation> actions = getSortedActions(barcode);
    print('has terminated? $actions');
    return actions.isNotEmpty;
  }

  /// Returns the up-to-date [product].
  Product getUpToDateProduct(Product product) {
    final String barcode = product.barcode!;
    final Iterable<TransientOperation> changes = getSortedActions(barcode);
    for (final TransientOperation changeId in changes) {
      final Product minimalistProduct = changeId.product;
      product = overwrite(product, minimalistProduct);
    }
    return product;
  }

  /// Removes all actions on a barcode. Use-case: garbage collecting.
  void removeBarcode(final String barcode) {
    /* TODO
    final Map<UpToDateOperationId, Product>? map = _actions[barcode];
    if (map == null) {
      // very unlikely
      return;
    }
    _impactedWidgets.removeWhere(
        (final UpToDateOperationId id, final List<UpToDateWidgetId> list) =>
            map.keys.contains(id));
    _actions.remove(barcode);

     */
  }

  /// Applies an action on a product.
  @protected
  Product overwrite(final Product initial, final Product change);
}

/// Succession of minimalist product changes.
class UpToDateChanges extends _UpToDateOperations {
  UpToDateChanges(super.localDatabase);

  @override
  OperationType get taskActionable => OperationType.details;

  /// Returns a minimalist [Product] with successive changes on top.
  Product prepareChangesForServer(
    final String barcode,
    final Iterable<TransientOperation> operations,
  ) {
    final Product initial = Product(barcode: barcode);
    // TODO 0000 sort
    for (final TransientOperation transientProduct in operations) {
      if (initial.barcode != transientProduct.product.barcode) {
        // very unlikely
        continue;
      }
      overwrite(initial, transientProduct.product);
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
  UpToDateDownloads(super.localDatabase);

  @override
  OperationType get taskActionable => OperationType.download;

  /// Replaces the [initial] product with the latest [change].
  @override
  Product overwrite(final Product initial, final Product change) => change;
}
