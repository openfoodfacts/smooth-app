import 'package:flutter/painting.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/background/background_task_queue.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/query/product_query.dart';

/// Background task about downloading products to translate.
class BackgroundTaskLanguageRefresh extends BackgroundTask {
  BackgroundTaskLanguageRefresh._({
    required super.processName,
    required super.uniqueId,
    required super.stamp,
    required this.excludeBarcodes,
    required this.productType,
  });

  BackgroundTaskLanguageRefresh.fromJson(super.json)
      : excludeBarcodes = _getStringList(json, _jsonTagExcludeBarcodes),
        productType =
            ProductType.fromOffTag(json[_jsonTagProductType] as String?) ??
// for legacy reason (not refreshed products = no product type)
                ProductType.food,
        super.fromJson();

  static List<String> _getStringList(
      final Map<String, dynamic> json, final String tag) {
    final List<dynamic> dynamicList =
        json[_jsonTagExcludeBarcodes] as List<dynamic>;
    final List<String> result = <String>[];
    for (final dynamic item in dynamicList) {
      result.add(item.toString());
    }
    return result;
  }

  final List<String> excludeBarcodes;
  final ProductType productType;

  static const String _jsonTagExcludeBarcodes = 'excludeBarcodes';
  static const String _jsonTagProductType = 'productType';

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = super.toJson();
    result[_jsonTagExcludeBarcodes] = excludeBarcodes;
    result[_jsonTagProductType] = productType.offTag;
    return result;
  }

  static const OperationType _operationType = OperationType.languageRefresh;

  UriProductHelper get _uriProductHelper => ProductQuery.getUriProductHelper(
        productType: productType,
      );

  static Future<void> addTask(
    final LocalDatabase localDatabase, {
    final List<String> excludeBarcodes = const <String>[],
    final ProductType? productType,
  }) async {
    if (productType == null) {
      for (final ProductType item in ProductType.values) {
        await addTask(
          localDatabase,
          excludeBarcodes: excludeBarcodes,
          productType: item,
        );
      }
      return;
    }
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      productType: productType,
    );
    final BackgroundTask task = _getNewTask(
      uniqueId,
      excludeBarcodes,
      productType,
    );
    await task.addToManager(
      localDatabase,
      queue: BackgroundTaskQueue.longHaul,
    );
  }

  @override
  (String, AlignmentGeometry)? getFloatingMessage(
          final AppLocalizations appLocalizations) =>
      null;

  static BackgroundTask _getNewTask(
    final String uniqueId,
    final List<String> excludeBarcodes,
    final ProductType productType,
  ) =>
      BackgroundTaskLanguageRefresh._(
        processName: _operationType.processName,
        uniqueId: uniqueId,
        stamp: ';languageRefresh;${productType.offTag}',
        excludeBarcodes: excludeBarcodes,
        productType: productType,
      );

  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async {}

  @override
  bool get hasImmediateNextTask => true;

  /// Number of products to download each time.
  static const int _pageSize = 20;

  @override
  Future<void> execute(final LocalDatabase localDatabase) async {
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    final OpenFoodFactsLanguage language = ProductQuery.getLanguage();
    final List<String> barcodes = await daoProduct.getTopProductsToTranslate(
      language,
      limit: _pageSize,
      excludeBarcodes: excludeBarcodes,
      productType: productType,
    );
    if (barcodes.isEmpty) {
      return;
    }
    final SearchResult searchResult = await OpenFoodAPIClient.searchProducts(
      getUser(),
      ProductSearchQueryConfiguration(
        fields: ProductQuery.fields,
        parametersList: <Parameter>[
          const PageSize(size: _pageSize),
          const PageNumber(page: 1),
          BarcodeParameter.list(barcodes),
        ],
        language: language,
        country: ProductQuery.getCountry(),
        version: ProductQuery.productQueryVersion,
      ),
      uriHelper: _uriProductHelper,
    );
    if (searchResult.products == null || searchResult.count == null) {
      throw Exception('Cannot refresh language');
    }

    // save into database and refresh all visible products.
    await daoProduct.putAll(searchResult.products!, language);
    localDatabase.upToDate.setLatestDownloadedProducts(searchResult.products!);

    // Next page
    final List<String> newExcludeBarcodes = <String>[];
    // we keep the old "excluded" barcodes,...
    newExcludeBarcodes.addAll(excludeBarcodes);
    // ...add the new barcodes...
    newExcludeBarcodes.addAll(barcodes);
    // ...and remove barcodes we actually found on the server.
    for (final Product product in searchResult.products!) {
      newExcludeBarcodes.remove(product.barcode);
    }
    await addTask(
      localDatabase,
      excludeBarcodes: newExcludeBarcodes,
    );
  }
}
