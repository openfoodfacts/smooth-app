import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/abstract_background_task.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:task_manager/task_manager.dart';

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
  static AbstractBackgroundTask? fromTask(final Task task) {
    try {
      final AbstractBackgroundTask result =
          BackgroundTaskDetails._fromJson(task.data!);
      if (result.processName == _PROCESS_NAME) {
        return result;
      }
    } catch (e) {
      //
    }
    return null;
  }

  @override
  Future<TaskResult> execute(final LocalDatabase localDatabase) async {
    try {
      await super.execute(localDatabase);
    } catch (e) {
      //
    } finally {
      localDatabase.upToDate.terminate(uniqueId);
    }
    return TaskResult.success;
  }

  /// Adds the background task about changing a product.
  static Future<void> addTask(
    final Product minimalistProduct, {
    required final State<StatefulWidget> widget,
  }) async {
    final LocalDatabase localDatabase = widget.context.read<LocalDatabase>();
    final String uniqueId =
        await localDatabase.upToDate.addChange(minimalistProduct);
    final BackgroundTaskDetails backgroundTask = _getNewTask(
      minimalistProduct,
      uniqueId,
    );
    // TODO(monsieurtanuki): currently we run the task immediately and just once - if it fails we rollback the changes.
    backgroundTask.execute(localDatabase); // async
    if (!widget.mounted) {
      return;
    }
    ScaffoldMessenger.of(widget.context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(widget.context).product_task_background_schedule,
        ),
        duration: SnackBarDuration.medium,
      ),
    );
  }

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
        country: ProductQuery.getCountry()!.iso2Code,
      );

  /// Uploads the product changes.
  @override
  Future<void> upload() async {
    final Map<String, dynamic> productMap =
        json.decode(inputMap) as Map<String, dynamic>;

    await OpenFoodAPIClient.saveProduct(
      getUser(),
      Product.fromJson(productMap),
      language: getLanguage(),
      country: getCountry(),
    );
  }
}
