import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/data_models/operation_type.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/query/product_query.dart';

/// Background task about refreshing all the already downloaded products.
class BackgroundTaskFullRefresh extends BackgroundTask {
  BackgroundTaskFullRefresh._({
    required super.processName,
    required super.uniqueId,
    required super.languageCode,
    required super.user,
    required super.country,
    required super.stamp,
  });

  BackgroundTaskFullRefresh.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);

  static const OperationType _operationType = OperationType.fullRefresh;

  static const String noBarcode = 'NO_BARCODE';

  static Future<void> addTask({
    required final State<StatefulWidget> widget,
  }) async {
    final LocalDatabase localDatabase = widget.context.read<LocalDatabase>();
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      noBarcode,
    );
    final BackgroundTask task = _getNewTask(
      uniqueId,
    );
    await task.addToManager(localDatabase, widget: widget);
  }

  @override
  String? getSnackBarMessage(final AppLocalizations appLocalizations) =>
      'Starting the refresh of all the products locally stored'; // TODO(monsieurtanuki): localize

  static BackgroundTaskFullRefresh _getNewTask(
    final String uniqueId,
  ) =>
      BackgroundTaskFullRefresh._(
        processName: _operationType.processName,
        uniqueId: uniqueId,
        languageCode: ProductQuery.getLanguage().offTag,
        user: jsonEncode(ProductQuery.getUser().toJson()),
        country: ProductQuery.getCountry()!.offTag,
        stamp: ';fullRefresh',
      );

  @override
  Future<void> execute(final LocalDatabase localDatabase) async {
    final DaoProduct daoProduct = DaoProduct(localDatabase);

    // We separate the products into two lists, products with or without
    // knowledge panels
    final List<String> barcodes = await daoProduct.getAllKeys();
    final List<String> productsWithoutKP = <String>[];
    final List<String> productsWithKP = <String>[];
    for (final String barcode in barcodes) {
      if (await _shouldBeDownloadedWithoutKP(daoProduct, barcode)) {
        productsWithoutKP.add(barcode);
      } else {
        productsWithKP.add(barcode);
      }
    }
    if (productsWithoutKP.isNotEmpty) {
      final List<ProductField> fieldsWithoutKP = List<ProductField>.from(
        ProductQuery.fields,
        growable: true,
      );
      fieldsWithoutKP.remove(ProductField.KNOWLEDGE_PANELS);

      await _loadProducts(
        barcodes: productsWithoutKP,
        fields: fieldsWithoutKP,
        daoProduct: daoProduct,
      );
    }

    if (productsWithKP.isNotEmpty) {
      await _loadProducts(
        barcodes: productsWithKP,
        fields: ProductQuery.fields,
        daoProduct: daoProduct,
      );
    }
  }

  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async {}

  /// Returns true if we should download data without KP.
  ///
  /// That happens in one case:
  /// * we already have a corresponding local product that does not have
  /// populated knowledge panel fields.
  static Future<bool> _shouldBeDownloadedWithoutKP(
    final DaoProduct daoProduct,
    final String barcode,
  ) async {
    final Product? product = await daoProduct.get(barcode);
    return product != null && product.knowledgePanels == null;
  }

  // TODO(monsieurtanuki): split (by 100 barcodes?) and loop
  Future<void> _loadProducts({
    required final List<String> barcodes,
    required final List<ProductField> fields,
    required final DaoProduct daoProduct,
  }) async {
    final SearchResult result = await OpenFoodAPIClient.searchProducts(
      ProductQuery.getUser(),
      ProductRefresher().getBarcodeListQueryConfiguration(
        barcodes,
        fields: fields,
      ),
    );
    final List<Product>? downloadedProducts = result.products;
    if (downloadedProducts?.isNotEmpty == true) {
      await daoProduct.putAll(downloadedProducts!);
    }
  }
}
