import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/database/dao_transient_operation.dart';
import 'package:smooth_app/database/local_database.dart';

/// Sequence of minimalist product changes.
class UpToDateChanges {
  UpToDateChanges(this.localDatabase)
    : _daoTransientProduct = DaoTransientOperation(localDatabase);

  final LocalDatabase localDatabase;

  /// For a barcode, map of the actions (pending and done).
  final DaoTransientOperation _daoTransientProduct;

  /// Returns all the actions related to a barcode, sorted by id.
  Iterable<TransientOperation> getSortedOperations(String barcode) {
    final List<TransientOperation> result = <TransientOperation>[];
    result.addAll(_daoTransientProduct.getAll(barcode));
    result.sort(OperationType.sort);
    return result;
  }

  Product getUpToDateProduct(Product product) {
    final String barcode = product.barcode!;
    final Iterable<TransientOperation> sortedOperations = getSortedOperations(
      barcode,
    );
    for (final TransientOperation operation in sortedOperations) {
      final Product minimalistProduct = operation.product;
      product = _overwrite(product, minimalistProduct);
    }
    return product;
  }

  Future<void> add(String key, Product product) async =>
      _daoTransientProduct.put(key, product);

  /// Returns true if some actions have not been terminated.
  bool hasNotTerminatedOperations(String barcode) {
    final Iterable<TransientOperation> actions = getSortedOperations(barcode);
    return actions.isNotEmpty;
  }

  /// Terminates a single operation.
  void terminate(String operationKey) =>
      _daoTransientProduct.delete(operationKey);

  /// Returns the [initial] nutrition with the input sets of [change] on top.
  ///
  /// A cleared nutrient keeps its empty `value_string` until the refresh.
  // TODO(monsieurtanuki): move to off-dart.
  static Map<String, dynamic> mergeNutrition(
    Map<String, dynamic>? initial,
    Map<String, dynamic> change,
  ) {
    final List<Map<String, dynamic>> inputSets = <Map<String, dynamic>>[
      for (final dynamic inputSet in initial?['input_sets'] ?? <dynamic>[])
        Map<String, dynamic>.of(inputSet as Map<String, dynamic>),
    ];
    final dynamic changedSets = change['input_sets'];
    if (changedSets != null) {
      for (final dynamic changedSet in changedSets) {
        final Map<String, dynamic> newSet = changedSet as Map<String, dynamic>;
        final NutritionSetKey? newKey = NutritionSetKey.fromJson(newSet);
        final int index = inputSets.indexWhere((
          Map<String, dynamic> inputSet,
        ) {
          final NutritionSetKey? key = NutritionSetKey.fromJson(inputSet);
          return key != null &&
              newKey != null &&
              key.source == newKey.source &&
              key.preparation == newKey.preparation &&
              key.perSize == newKey.perSize;
        });
        if (index < 0) {
          inputSets.add(Map<String, dynamic>.of(newSet));
          continue;
        }
        inputSets[index]['nutrients'] = <String, dynamic>{
          ...?inputSets[index]['nutrients'] as Map<String, dynamic>?,
          ...?newSet['nutrients'] as Map<String, dynamic>?,
        };
      }
    }
    return <String, dynamic>{...?initial, 'input_sets': inputSets};
  }

  /// Overwrite the [initial] product with the non-null fields of [change].
  ///
  /// Currently limited to the fields modified by
  /// * [BackgroundTaskDetails]
  /// * [BackgroundTaskImage]
  Product _overwrite(Product initial, Product change) {
    if (change.productType != null) {
      initial.productType = change.productType;
    }
    if (change.productName != null) {
      initial.productName = change.productName;
    }
    if (change.productNameInLanguages != null) {
      initial.productNameInLanguages = change.productNameInLanguages;
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
    if (change.packagingsComplete != null) {
      initial.packagingsComplete = change.packagingsComplete;
    }
    if (change.noNutritionData != null) {
      initial.noNutritionData = change.noNutritionData;
    }
    // cf. https://github.com/openfoodfacts/smooth-app/issues/4627
    // If we don't check if nutriments is empty, most of the time we overwrite
    // potentially existing nutriments with an empty map.
    // ignore: deprecated_member_use
    if (change.nutriments != null && !change.nutriments!.isEmpty()) {
      // ignore: deprecated_member_use
      initial.nutriments = change.nutriments;
    }
    if (change.nutrition != null) {
      initial.nutrition = mergeNutrition(initial.nutrition, change.nutrition!);
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
    if (change.traces != null) {
      initial.traces = change.traces;
    }
    if (change.tracesTagsInLanguages != null) {
      initial.tracesTagsInLanguages = change.tracesTagsInLanguages;
    }
    if (change.countries != null) {
      initial.countries = change.countries;
    }
    if (change.countriesTagsInLanguages != null) {
      initial.countriesTagsInLanguages = change.countriesTagsInLanguages;
    }

    /// In some cases we want to force null; we do that with an empty String.
    String? emptyMeansNull(String value) => value.isEmpty ? null : value;

    if (change.imageFrontUrl != null) {
      initial.imageFrontUrl = emptyMeansNull(change.imageFrontUrl!);
    }
    if (change.imageIngredientsUrl != null) {
      initial.imageIngredientsUrl = emptyMeansNull(change.imageIngredientsUrl!);
    }
    if (change.imageNutritionUrl != null) {
      initial.imageNutritionUrl = emptyMeansNull(change.imageNutritionUrl!);
    }
    if (change.imagePackagingUrl != null) {
      initial.imagePackagingUrl = emptyMeansNull(change.imagePackagingUrl!);
    }
    if (change.images != null && change.images!.isNotEmpty) {
      initial.images ??= <ProductImage>[];
      // let's remove similar entries first
      final Set<int> removeIndices = <int>{};
      for (final ProductImage changeProductImage in change.images!) {
        int i = 0;
        for (final ProductImage initialProductImage in initial.images!) {
          if (changeProductImage.field == initialProductImage.field &&
              changeProductImage.size == initialProductImage.size &&
              changeProductImage.language == initialProductImage.language) {
            removeIndices.add(i);
          }
          i++;
        }
      }
      final List<int> sorted = List<int>.from(removeIndices);
      sorted.reversed.forEach(initial.images!.removeAt);
      // then add the correct new entries
      for (final ProductImage changeProductImage in change.images!) {
        // null imgid means just deletion, no adding
        if (changeProductImage.imgid != null) {
          initial.images!.add(changeProductImage);
        }
      }
    }
    if (change.website != null) {
      initial.website = change.website;
    }
    return initial;
  }
}
