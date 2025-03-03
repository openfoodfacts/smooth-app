import 'dart:async';
import 'dart:io';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';

class ProductListHelper {
  const ProductListHelper({required this.list, required this.localDatabase});

  final ProductList list;
  final LocalDatabase localDatabase;

  static const String EXPORT_SEPARATOR = ';';

  Future<String> exportBarcodesToString() async {
    final StringBuffer csv = StringBuffer();

    void addLine(String barcode, String name, String brand) {
      csv.writeln(
        '$barcode'
        '$EXPORT_SEPARATOR'
        '$name'
        '$EXPORT_SEPARATOR'
        '$brand',
      );
    }

    addLine('Barcode', 'Name', 'Brand');

    final List<String> validBarcodes = list.barcodes.where(
      (String barcode) {
        return isBarcodeValid(barcode);
      },
    ).toList();

    final Map<String, Product> products =
        await DaoProduct(localDatabase).getAll(validBarcodes);

    for (final MapEntry<String, Product> entry in products.entries) {
      final String barcode = entry.key;
      final Product product = entry.value;
      final String name =
          (product.productName ?? '').replaceAll(EXPORT_SEPARATOR, '');
      final String brand =
          (product.brands ?? '').replaceAll(EXPORT_SEPARATOR, '');
      addLine(barcode, name, brand);
    }

    return csv.toString();
  }

  Future<List<String>> importFileToList(File file) async {
    final List<String> barcodes = fileToBarcodes(file);
    return importBarcodes(barcodes);
  }

  Future<List<String>> importBarcodes(List<String> barcodes) async {
    // TODOhow should we handle different product types?
    final List<String> existingBarcodes =
        await ProductRefresher().silentFetchAndRefreshList(
              barcodes: barcodes,
              localDatabase: localDatabase,
              productType: ProductType.food,
            ) ??
            <String>[];

    await DaoProductList(localDatabase).bulkSet(
      list,
      existingBarcodes,
      include: true,
    );
    return existingBarcodes;
  }

  List<String> fileToBarcodes(File file) {
    final String content = file.readAsStringSync();

    final List<String> lines = content.split('\n');
    final List<String> barcodes = <String>[];

    for (final String line in lines) {
      final List<String> parts = line.split(EXPORT_SEPARATOR);
      if (parts.length < 3) {
        continue;
      }
      final String barcode = parts[0].replaceAll('"', '');
      barcodes.add(barcode);
    }

    return barcodes;
  }

  static bool isBarcodeValid(String barcode) {
    return (barcode.length == 8 || barcode.length == 13) &&
        int.tryParse(barcode) != null;
  }
}
