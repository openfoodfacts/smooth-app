import 'package:openfoodfacts/model/Product.dart';

/// Helper around product data migration.
abstract class DaoProductMigration {
  Future<List<String>> getAllKeys();

  /// Migrates product data from a [source] to a [destination].
  ///
  /// Will empty the source in the end if successful.
  static Future<void> migrate({
    required final DaoProductMigrationSource source,
    required final DaoProductMigrationDestination destination,
  }) async {
    final List<String> barcodesFrom = await source.getAllKeys();
    if (barcodesFrom.isEmpty) {
      // nothing to migrate, or already migrated and cleaned.
      return;
    }

    final List<String> barcodesAlreadyThere = await destination.getAllKeys();

    final List<String> barcodesToBeCopied = List<String>.from(barcodesFrom);
    barcodesToBeCopied.removeWhere(
        (final String barcode) => barcodesAlreadyThere.contains(barcode));

    if (barcodesToBeCopied.isNotEmpty) {
      final Map<String, Product> copiedProducts =
          await source.getAll(barcodesToBeCopied);
      await destination.putAll(copiedProducts.values);
      final List<String> barcodesFinallyThere = await destination.getAllKeys();
      if (barcodesFinallyThere.length !=
          barcodesAlreadyThere.length + barcodesToBeCopied.length) {
        throw Exception('Unexpected difference between counts');
      }
    }

    // cleaning the old product table
    await source.deleteAll(barcodesFrom);
    final List<String> barcodesNoMore = await source.getAllKeys();
    if (barcodesNoMore.isNotEmpty) {
      throw Exception('Unexpected not empty source');
    }
  }
}

/// Source of a dao product migration.
abstract class DaoProductMigrationSource implements DaoProductMigration {
  Future<Map<String, Product>> getAll(final List<String> barcodes);
  Future<void> deleteAll(final List<String> barcodes);
}

/// Destination of a dao product migration.
abstract class DaoProductMigrationDestination implements DaoProductMigration {
  Future<void> putAll(final Iterable<Product> products);
}
