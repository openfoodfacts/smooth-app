import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/ProductResultV3.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/abstract_background_task.dart';
import 'package:smooth_app/data_models/operation_type.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/query/product_query.dart';

/// Background task that changes product details (data, but no image upload).
class BackgroundTaskDetails extends AbstractBackgroundTask {
  const BackgroundTaskDetails._({
    required super.processName,
    required super.uniqueId,
    required super.barcode,
    required super.languageCode,
    required super.user,
    required super.country,
    required this.inputMap,
  });

  BackgroundTaskDetails._fromJson(Map<String, dynamic> json)
      : this._(
          processName: json['processName'] as String,
          uniqueId: json['uniqueId'] as String,
          barcode: json['barcode'] as String,
          languageCode: json['languageCode'] as String,
          user: json['user'] as String,
          country: json['country'] as String,
          inputMap: json['inputMap'] as String,
        );

  /// Task ID.
  static const String _PROCESS_NAME = 'PRODUCT_EDIT';

  static const OperationType _operationType = OperationType.details;

  /// Serialized product.
  final String inputMap;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'processName': processName,
        'uniqueId': uniqueId,
        'barcode': barcode,
        'languageCode': languageCode,
        'user': user,
        'country': country,
        'inputMap': inputMap,
      };

  /// Returns the deserialized background task if possible, or null.
  static BackgroundTaskDetails? fromJson(final Map<String, dynamic> map) {
    try {
      final BackgroundTaskDetails result = BackgroundTaskDetails._fromJson(map);
      if (result.processName == _PROCESS_NAME) {
        return result;
      }
    } catch (e) {
      //
    }
    return null;
  }

  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async =>
      localDatabase.upToDate.addChange(uniqueId, _product);

  @override
  Future<void> postExecute(final LocalDatabase localDatabase) async =>
      localDatabase.upToDate.terminate(uniqueId);

  /// Adds the background task about changing a product.
  static Future<void> addTask(
    final Product minimalistProduct, {
    required final State<StatefulWidget> widget,
  }) async {
    final LocalDatabase localDatabase = widget.context.read<LocalDatabase>();
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      minimalistProduct.barcode!,
    );
    final AbstractBackgroundTask task = _getNewTask(
      minimalistProduct,
      uniqueId,
    );
    await task.addToManager(localDatabase, widget: widget);
  }

  @override
  String? getSnackBarMessage(final AppLocalizations appLocalizations) =>
      appLocalizations.product_task_background_schedule;

  /// Returns a new background task about changing a product.
  static BackgroundTaskDetails _getNewTask(
    final Product minimalistProduct,
    final String uniqueId,
  ) =>
      BackgroundTaskDetails._(
        uniqueId: uniqueId,
        processName: _PROCESS_NAME,
        barcode: minimalistProduct.barcode!,
        languageCode: ProductQuery.getLanguage().code,
        inputMap: jsonEncode(minimalistProduct.toJson()),
        user: jsonEncode(ProductQuery.getUser().toJson()),
        country: ProductQuery.getCountry()!.offTag,
      );

  Product get _product =>
      Product.fromJson(json.decode(inputMap) as Map<String, dynamic>);

  /// Uploads the product changes.
  @override
  Future<void> upload() async {
    if (_product.packagings != null) {
      // For the moment, we can only save "packagings" with V3,
      // and V3 can only save "packagings".
      final ProductResultV3 result =
          await OpenFoodAPIClient.temporarySaveProductV3(
        getUser(),
        _product.barcode!,
        packagings: _product.packagings,
        language: getLanguage(),
        country: getCountry(),
      );
      if (result.status != ProductResultV3.statusSuccess &&
          result.status != ProductResultV3.statusWarning) {
        throw Exception('Could not save product - ${result.errors}');
      }
      return;
    }
    final Status status = await OpenFoodAPIClient.saveProduct(
      getUser(),
      _product,
      language: getLanguage(),
      country: getCountry(),
    );
    if (status.status != 1) {
      throw Exception('Could not save product - ${status.error}');
    }
  }
}
