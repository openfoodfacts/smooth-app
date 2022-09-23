import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/database/local_database.dart';

/// Provider that reflects all the user changes on [Product]s.
class UpToDateProductProvider {
  UpToDateProductProvider(this.localDatabase);

  final LocalDatabase localDatabase;

  // TODO(monsieurtanuki): should be more persistent, like in hive.
  final Map<String, List<Product>> _map = <String, List<Product>>{};
  final Map<String, int> _timestamps = <String, int>{};

  /// Returns the [product] with all the local pending changes on top.
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
  ///
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   _product = widget.product;
  /// }
  ///
  /// @override
  /// Widget build(BuildContext context) {
  ///   final LocalDatabase localDatabase = context.watch<LocalDatabase>();
  ///   _product = localDatabase.upToDate.getLocalUpToDate(_product);
  /// ```
  Product getLocalUpToDate(final Product product) {
    final List<Product>? changes = _map[product.barcode!];
    if (changes == null) {
      return product;
    }
    return add(product, changes);
  }

  /// Adds a minimalist local change to the local pending changes.
  void addChange(final Product change) {
    final String? barcode = change.barcode;
    if (barcode == null) {
      // very unlikely
      return;
    }
    _map[barcode] ??= <Product>[];
    _map[barcode]!.add(change);
    _timestamps[barcode] = LocalDatabase.nowInMillis();
    localDatabase.notifyListeners();
  }

  /// Removes the first [length] changes related to this [barcode].
  // TODO(monsieurtanuki): will be cleaner with a proper key list.
  void removeChanges(final String barcode, final int length) {
    if (_map[barcode] == null) {
      // not supposed to happen
      return;
    }
    for (int i = 0; i < length; i++) {
      try {
        _map[barcode]!.removeAt(0);
      } catch (e) {
        // not supposed to happen
      }
    }
    localDatabase.notifyListeners();
  }

  /// Returns the local pending changes related to a [barcode].
  List<Product>? getChanges(final String barcode) => _map[barcode];

  /// Returns true if there are pending changes for this [barcode].
  bool hasPendingChanges(final String barcode) {
    final List<Product>? changes = getChanges(barcode);
    return changes != null && changes.isNotEmpty;
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

  /// Returns the [initial] [Product] with successive [changes] on top.
  static Product add(final Product initial, final List<Product> changes) {
    for (final Product change in changes) {
      if (initial.barcode != change.barcode) {
        throw Exception(
          'Invalid barcodes for changes: '
          '${initial.barcode} and ${change.barcode})',
        );
      }
      _overwrite(initial, change);
    }
    return initial;
  }

  /// Overwrite the [initial] product with the non-null fields of [change].
  ///
  /// Currently limited to the fields modified by [BackgroundTaskDetails].
  // TODO(monsieurtanuki): refactor this "à la copyWith" or something like that
  static void _overwrite(final Product initial, final Product change) {
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
  }
}
