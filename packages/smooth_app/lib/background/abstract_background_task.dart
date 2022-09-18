import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/background/background_task_image.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:task_manager/task_manager.dart';

/// Abstract background task.
abstract class AbstractBackgroundTask {
  const AbstractBackgroundTask({
    required this.processName,
    required this.uniqueId,
    required this.barcode,
    required this.languageCode,
    required this.user,
    required this.country,
  });

  /// Typically, similar to the name of the class that extends this one.
  ///
  /// To be used when deserializing, in order to check who is who.
  final String processName;

  /// Unique task identifier, needed e.g. for task overwriting.
  final String uniqueId;

  final String barcode;
  final String languageCode;
  final String user;
  final String country;

  @protected
  Map<String, dynamic> toJson();

  /// Returns the deserialized background task if possible, or null.
  static AbstractBackgroundTask? fromTask(final Task task) =>
      BackgroundTaskDetails.fromTask(task) ??
      BackgroundTaskImage.fromTask(task);

  /// Response code sent by the server in case of a success.
  @protected
  static const int SUCCESS_CODE = 1;

  /// Executes the background task: upload, download, update locally.
  Future<TaskResult> execute(final LocalDatabase localDatabase) async {
    await upload();
    await _downloadAndRefresh(localDatabase);
    return TaskResult.success;
  }

  /// Uploads data changes.
  @protected
  Future<void> upload();

  @protected
  OpenFoodFactsLanguage getLanguage() => LanguageHelper.fromJson(languageCode);

  @protected
  OpenFoodFactsCountry? getCountry() => CountryHelper.fromJson(country);

  @protected
  User getUser() => User.fromJson(jsonDecode(user) as Map<String, dynamic>);

  /// Downloads the whole product, updates locally.
  Future<void> _downloadAndRefresh(final LocalDatabase localDatabase) async {
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    final ProductQueryConfiguration configuration = ProductQueryConfiguration(
      barcode,
      fields: ProductQuery.fields,
      language: getLanguage(),
      country: getCountry(),
    );

    final ProductResult queryResult =
        await OpenFoodAPIClient.getProduct(configuration);
    if (queryResult.status == AbstractBackgroundTask.SUCCESS_CODE) {
      final Product? product = queryResult.product;
      if (product != null) {
        await daoProduct.put(product);
        localDatabase.notifyListeners();
      }
    }
  }

  /// Generates a unique id for the background task.
  ///
  /// This ensures that the background task is unique and also
  /// ensures that in case of conflicts, the background task is replaced.
  /// Example: 8901072002478_B_en_in_username
  @protected
  static String generateUniqueId(
    String barcode,
    String processIdentifier, {
    final bool appendTimestamp = false,
  }) {
    final StringBuffer stringBuffer = StringBuffer();
    stringBuffer
      ..write(barcode)
      ..write('_')
      ..write(processIdentifier)
      ..write('_')
      ..write(ProductQuery.getLanguage().code)
      ..write('_')
      ..write(ProductQuery.getCountry()!.iso2Code)
      ..write('_')
      ..write(ProductQuery.getUser().userId);
    if (appendTimestamp) {
      stringBuffer
        ..write('_')
        ..write(DateTime.now().millisecondsSinceEpoch);
    }
    return stringBuffer.toString();
  }
}
