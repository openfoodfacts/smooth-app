import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_paged.dart';
import 'package:smooth_app/query/product_query.dart';

/// Abstract background task with work in progress actions.
abstract class BackgroundTaskProgressing extends BackgroundTaskPaged {
  BackgroundTaskProgressing({
    required super.processName,
    required super.uniqueId,
    required super.stamp,
    required super.pageSize,
    required this.work,
    required this.totalSize,
    required this.productType,
  });

  BackgroundTaskProgressing.fromJson(super.json)
    : work = json[_jsonTagWork] as String,
      totalSize = json[_jsonTagTotalSize] as int,
      productType =
          ProductType.fromOffTag(json[_jsonTagProductType] as String?) ??
          // for legacy reason (not refreshed products = no product type)
          ProductType.food,
      super.fromJson();

  final String work;
  final int totalSize;
  final ProductType productType;

  static const String _jsonTagWork = 'work';
  static const String _jsonTagTotalSize = 'totalSize';
  static const String _jsonTagProductType = 'productType';

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = super.toJson();
    result[_jsonTagWork] = work;
    result[_jsonTagTotalSize] = totalSize;
    result[_jsonTagProductType] = productType.offTag;
    return result;
  }

  @protected
  UriProductHelper get uriProductHelper =>
      ProductQuery.getUriProductHelper(productType: productType);

  static const String noBarcode = 'NO_BARCODE';
}
