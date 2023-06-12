import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/background/background_task_full_refresh.dart';
import 'package:smooth_app/data_models/operation_type.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/query/product_query.dart';

/// Background task about pre-downloading top n products for offline usage.
///
/// For space reasons, we don't download the full products: we remove the
/// knowledge panel fields.
class BackgroundTaskOffline extends BackgroundTask {
  BackgroundTaskOffline._({
    required super.processName,
    required super.uniqueId,
    required super.languageCode,
    required super.user,
    required super.country,
    required super.stamp,
  });

  BackgroundTaskOffline.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);

  static const OperationType _operationType = OperationType.offline;

  static Future<void> addTask({
    required final State<StatefulWidget> widget,
  }) async {
    final LocalDatabase localDatabase = widget.context.read<LocalDatabase>();
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      BackgroundTaskFullRefresh.noBarcode,
    );
    final BackgroundTask task = _getNewTask(
      uniqueId,
    );
    await task.addToManager(localDatabase, widget: widget);
  }

  @override
  String? getSnackBarMessage(final AppLocalizations appLocalizations) =>
      'Starting the download of the most popular products'; // TODO(monsieurtanuki): localize

  static BackgroundTaskOffline _getNewTask(
    final String uniqueId,
  ) =>
      BackgroundTaskOffline._(
        processName: _operationType.processName,
        uniqueId: uniqueId,
        languageCode: ProductQuery.getLanguage().offTag,
        user: jsonEncode(ProductQuery.getUser().toJson()),
        country: ProductQuery.getCountry()!.offTag,
        stamp: ';offline',
      );

  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async {}

  @override
  Future<void> execute(final LocalDatabase localDatabase) async {
    final List<ProductField> fields = List<ProductField>.from(
      ProductQuery.fields,
      growable: true,
    );
    fields.remove(ProductField.KNOWLEDGE_PANELS);
    // TODO(monsieurtanuki): first only the barcodes, then split (by 100 barcodes?) and loop
    final ProductSearchQueryConfiguration queryConfig =
        ProductSearchQueryConfiguration(
      fields: fields,
      parametersList: <Parameter>[
        const PageSize(size: 1000),
        const PageNumber(page: 1),
        const SortBy(option: SortOption.POPULARITY),
      ],
      language: ProductQuery.getLanguage(),
      country: ProductQuery.getCountry(),
      version: ProductQuery.productQueryVersion,
      // https://fr.openfoodfacts.org/api/v2/search?page_size=1000&fields=code
    );
    final SearchResult searchResult = await OpenFoodAPIClient.searchProducts(
      ProductQuery.getUser(),
      queryConfig,
    );
    final List<Product>? downloadedProducts = searchResult.products;
    if (downloadedProducts == null) {
      return;
    }
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    for (final Product product in downloadedProducts) {
      if (await _shouldBeUpdated(daoProduct, product.barcode!)) {
        await daoProduct.put(product);
      }
    }
  }

  /// Returns true if we should save the downloaded data into the local db.
  ///
  /// That happens in two cases:
  /// * we don't have a corresponding local product yet
  /// * the product we already have locally does not have populated knowledge
  /// panel fields (therefore we won't "erase" any local KP data)
  static Future<bool> _shouldBeUpdated(
    final DaoProduct daoProduct,
    final String barcode,
  ) async {
    final Product? product = await daoProduct.get(barcode);
    return product == null || product.knowledgePanels == null;
  }
}
