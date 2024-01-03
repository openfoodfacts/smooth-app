import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_barcode.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/database/local_database.dart';

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
  BackgroundTaskDetails._({
    required super.processName,
    required super.uniqueId,
    required super.barcode,
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
    required final BuildContext context,
    required final BackgroundTaskDetailsStamp stamp,
    final bool showSnackBar = true,
  }) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      barcode: minimalistProduct.barcode,
    );
    final BackgroundTaskBarcode task = _getNewTask(
      minimalistProduct,
      uniqueId,
      stamp,
    );
    if (!context.mounted) {
      return;
    }
    await task.addToManager(
      localDatabase,
      context: context,
      showSnackBar: showSnackBar,
    );
  }

  @override
  (String, AlignmentGeometry)? getFloatingMessage(
          final AppLocalizations appLocalizations) =>
      (
        appLocalizations.product_task_background_schedule,
        AlignmentDirectional.bottomCenter,
      );

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
        inputMap: jsonEncode(minimalistProduct.toJson()),
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

  static const String _invalidUserError = 'invalid_user_id_and_password';

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
        uriHelper: uriProductHelper,
      );
      if (result.status != ProductResultV3.statusSuccess &&
          result.status != ProductResultV3.statusWarning) {
        bool isInvalidUser = false;
        if (result.errors != null) {
          for (final ProductResultFieldAnswer answer in result.errors!) {
            if (answer.message?.id == _invalidUserError) {
              isInvalidUser = true;
            }
          }
        }
        throw Exception(
          'Could not save product - API V3'
          ' - '
          'status=${result.status} - errors=${result.errors} ${isInvalidUser ? _getIncompleteUserData() : ''}',
        );
      }
      return;
    }
    final Status status = await OpenFoodAPIClient.saveProduct(
      getUser(),
      product,
      language: getLanguage(),
      country: getCountry(),
      uriHelper: uriProductHelper,
    );
    if (status.status != 1) {
      bool isInvalidUser = false;
      if (status.error != null) {
        if (status.error!.contains(_invalidUserError)) {
          isInvalidUser = true;
        }
      }
      throw Exception(
        'Could not save product - API V2'
        ' - '
        'status=${status.status} - errors=${status.error} ${isInvalidUser ? _getIncompleteUserData() : ''}',
      );
    }
  }

  String _getIncompleteUserData() {
    final User user = getUser();
    final StringBuffer result = StringBuffer();
    result.write(' [user:');
    result.write(user.userId);
    final int length = user.password.length;
    result.write(' (');
    if (length >= 8) {
      result.write(user.password.substring(0, 2));
      result.write('*' * (length - 4));
      result.write(user.password.substring(length - 2));
    } else {
      result.write('passwordLength:$length');
    }
    result.write(')');
    result.write('] ');
    return result.toString();
  }
}
