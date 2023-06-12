import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_barcode.dart';
import 'package:smooth_app/data_models/operation_type.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/query/product_query.dart';

/// Stamps we can put on [BackgroundTaskDetails].
///
/// With that stamp, we can de-duplicate similar tasks.
enum BackgroundTaskDetailsStamp {
  basicDetails('basic_details'),
  otherDetails('other_details'),
  ocrIngredients('ocr_ingredients'),
  ocrPackaging('ocr_packaging'),
  structuredPackaging('structured_packaging'),
  nutrition('nutrition_facts'),
  stores('stores'),
  origins('origins'),
  embCodes('emb_codes'),
  labels('labels'),
  categories('categories'),
  countries('countries');

  const BackgroundTaskDetailsStamp(this.tag);

  final String tag;
}

/// Background task that changes product details (data, but no image upload).
class BackgroundTaskDetails extends BackgroundTaskBarcode {
  const BackgroundTaskDetails._({
    required super.processName,
    required super.uniqueId,
    required super.barcode,
    required super.languageCode,
    required super.user,
    required super.country,
    required super.stamp,
    required this.inputMap,
  });

  BackgroundTaskDetails.fromJson(Map<String, dynamic> json)
      : inputMap = json[_jsonTagInputMap] as String,
        super.fromJson(json);

  static const String _jsonTagInputMap = 'inputMap';

  static const OperationType _operationType = OperationType.details;

  /// Serialized product.
  final String inputMap;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = super.toJson();
    result[_jsonTagInputMap] = inputMap;
    return result;
  }

  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async =>
      localDatabase.upToDate.addChange(uniqueId, _getProduct());

  /// Adds the background task about changing a product.
  static Future<void> addTask(
    final Product minimalistProduct, {
    required final State<StatefulWidget> widget,
    required final BackgroundTaskDetailsStamp stamp,
    final bool showSnackBar = true,
  }) async {
    final LocalDatabase localDatabase = widget.context.read<LocalDatabase>();
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      minimalistProduct.barcode!,
    );
    final BackgroundTaskBarcode task = _getNewTask(
      minimalistProduct,
      uniqueId,
      stamp,
    );
    await task.addToManager(
      localDatabase,
      widget: widget,
      showSnackBar: showSnackBar,
    );
  }

  @override
  String? getSnackBarMessage(final AppLocalizations appLocalizations) =>
      appLocalizations.product_task_background_schedule;

  /// Returns a new background task about changing a product.
  static BackgroundTaskDetails _getNewTask(
    final Product minimalistProduct,
    final String uniqueId,
    final BackgroundTaskDetailsStamp stamp,
  ) =>
      BackgroundTaskDetails._(
        uniqueId: uniqueId,
        processName: _operationType.processName,
        barcode: minimalistProduct.barcode!,
        languageCode: ProductQuery.getLanguage().code,
        inputMap: jsonEncode(minimalistProduct.toJson()),
        user: jsonEncode(ProductQuery.getUser().toJson()),
        country: ProductQuery.getCountry()!.offTag,
        stamp: getStamp(minimalistProduct.barcode!, stamp.tag),
      );

  static String getStamp(final String barcode, final String stamp) =>
      '$barcode;detail;$stamp';

  Product _getProduct() {
    final Product result =
        Product.fromJson(json.decode(inputMap) as Map<String, dynamic>);
    // for good multilingual management
    result.lang = getLanguage();
    return result;
  }

  /// Uploads the product changes.
  @override
  Future<void> upload() async {
    final Product product = _getProduct();
    if (product.packagings != null || product.packagingsComplete != null) {
      // For the moment, some fields can only be saved in V3,
      // and V3 can only save those fields.
      final ProductResultV3 result =
          await OpenFoodAPIClient.temporarySaveProductV3(
        getUser(),
        product.barcode!,
        packagings: product.packagings,
        packagingsComplete: product.packagingsComplete,
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
      product,
      language: getLanguage(),
      country: getCountry(),
    );
    if (status.status != 1) {
      throw Exception('Could not save product - ${status.error}');
    }
  }
}
