import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/data_models/operation_type.dart';
import 'package:smooth_app/database/dao_transient_operation.dart';
import 'package:smooth_app/database/local_database.dart';

/// Sequence of minimalist product changes.
class UpToDateChanges {
  UpToDateChanges(this.localDatabase)
      : _daoTransientProduct = DaoTransientOperation(localDatabase);

  final LocalDatabase localDatabase;

  /// For a barcode, map of the actions (pending and done).
  final DaoTransientOperation _daoTransientProduct;

  OperationType get taskActionable => OperationType.details;

  /// Returns all the actions related to a barcode, sorted by id.
  Iterable<TransientOperation> getSortedOperations(final String barcode) {
    final List<TransientOperation> result = <TransientOperation>[];
    for (final TransientOperation transientProduct
        in _daoTransientProduct.getAll(barcode)) {
      if (taskActionable.matches(transientProduct)) {
        result.add(transientProduct);
      }
    }
    result.sort(OperationType.sort);
    return result;
  }

  Product getUpToDateProduct(Product product) {
    final String barcode = product.barcode!;
    final Iterable<TransientOperation> sortedOperations =
        getSortedOperations(barcode);
    for (final TransientOperation operation in sortedOperations) {
      final Product minimalistProduct = operation.product;
      product = _overwrite(product, minimalistProduct);
    }
    return product;
  }

  Future<void> add(final String key, final Product product) async =>
      _daoTransientProduct.put(key, product);

  /// Returns true if some actions have not been terminated.
  bool hasNotTerminatedOperations(final String barcode) {
    final Iterable<TransientOperation> actions = getSortedOperations(barcode);
    return actions.isNotEmpty;
  }

  /// Terminates a single operation.
  void terminate(final String operationKey) =>
      _daoTransientProduct.delete(operationKey);

  /// Overwrite the [initial] product with the non-null fields of [change].
  ///
  /// Currently limited to the fields modified by
  /// * [BackgroundTaskDetails]
  /// * [BackgroundTaskImage]
  // TODO(monsieurtanuki): refactor this "à la copyWith" or something like that
  Product _overwrite(final Product initial, final Product change) {
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
    // ignore: deprecated_member_use
    if (change.packaging != null) {
      // ignore: deprecated_member_use
      initial.packaging = change.packaging;
    }
    if (change.packagings != null) {
      initial.packagings = change.packagings;
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
    if (change.labelsTagsInLanguages != null) {
      initial.labelsTagsInLanguages = change.labelsTagsInLanguages;
    }
    if (change.categories != null) {
      initial.categories = change.categories;
    }
    if (change.categoriesTagsInLanguages != null) {
      initial.categoriesTagsInLanguages = change.categoriesTagsInLanguages;
    }
    if (change.countries != null) {
      initial.countries = change.countries;
    }
    if (change.countriesTagsInLanguages != null) {
      initial.countriesTagsInLanguages = change.countriesTagsInLanguages;
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
    if (change.website != null) {
      initial.website = change.website;
    }
    return initial;
  }
}
