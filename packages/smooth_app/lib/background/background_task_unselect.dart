import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/abstract_background_task.dart';
import 'package:smooth_app/background/background_task_image.dart';
import 'package:smooth_app/background/background_task_refresh_later.dart';
import 'package:smooth_app/data_models/operation_type.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/query/product_query.dart';

/// Background task about unselecting a product image.
class BackgroundTaskUnselect extends AbstractBackgroundTask {
  const BackgroundTaskUnselect._({
    required super.processName,
    required super.uniqueId,
    required super.barcode,
    required super.languageCode,
    required super.user,
    required super.country,
    required super.stamp,
    required this.imageField,
  });

  BackgroundTaskUnselect._fromJson(Map<String, dynamic> json)
      : this._(
          processName: json['processName'] as String,
          uniqueId: json['uniqueId'] as String,
          barcode: json['barcode'] as String,
          languageCode: json['languageCode'] as String,
          user: json['user'] as String,
          country: json['country'] as String,
          imageField: json['imageField'] as String,
          stamp: json['stamp'] as String,
        );

  /// Task ID.
  static const String _PROCESS_NAME = 'IMAGE_UNSELECT';

  static const OperationType _operationType = OperationType.unselect;

  final String imageField;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'processName': processName,
        'uniqueId': uniqueId,
        'barcode': barcode,
        'languageCode': languageCode,
        'user': user,
        'country': country,
        'imageField': imageField,
        'stamp': stamp,
      };

  /// Returns the deserialized background task if possible, or null.
  static AbstractBackgroundTask? fromJson(final Map<String, dynamic> map) {
    try {
      final AbstractBackgroundTask result =
          BackgroundTaskUnselect._fromJson(map);
      if (result.processName == _PROCESS_NAME) {
        return result;
      }
    } catch (e) {
      //
    }
    return null;
  }

  /// Adds the background task about unselecting a product image.
  static Future<void> addTask(
    final String barcode, {
    required final ImageField imageField,
    required final State<StatefulWidget> widget,
  }) async {
    final LocalDatabase localDatabase = widget.context.read<LocalDatabase>();
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      barcode,
    );
    final AbstractBackgroundTask task = _getNewTask(
      barcode,
      imageField,
      uniqueId,
    );
    await task.addToManager(localDatabase, widget: widget);
  }

  @override
  String? getSnackBarMessage(final AppLocalizations appLocalizations) =>
      appLocalizations.product_task_background_schedule;

  /// Returns a new background task about unselecting a product image.
  static BackgroundTaskUnselect _getNewTask(
    final String barcode,
    final ImageField imageField,
    final String uniqueId,
  ) =>
      BackgroundTaskUnselect._(
        uniqueId: uniqueId,
        barcode: barcode,
        processName: _PROCESS_NAME,
        imageField: imageField.offTag,
        languageCode: ProductQuery.getLanguage().code,
        user: jsonEncode(ProductQuery.getUser().toJson()),
        country: ProductQuery.getCountry()!.offTag,
        // same stamp as image upload
        stamp: BackgroundTaskImage.getStamp(
          barcode,
          imageField.offTag,
          ProductQuery.getLanguage().code,
        ),
      );

  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async =>
      localDatabase.upToDate.addChange(uniqueId, _getUnselectedProduct());

  @override
  Future<void> postExecute(
    final LocalDatabase localDatabase,
    final bool success,
  ) async {
    localDatabase.upToDate.terminate(uniqueId);
    localDatabase.notifyListeners();
    if (success) {
      await BackgroundTaskRefreshLater.addTask(
        barcode,
        localDatabase: localDatabase,
      );
    }
  }

  /// Unselects the product image.
  @override
  Future<void> upload() async => OpenFoodAPIClient.unselectProductImage(
        barcode: barcode,
        imageField: ImageField.fromOffTag(imageField)!,
        language: getLanguage(),
        user: getUser(),
      );

  /// Returns a product with "unselected" image.
  ///
  /// The problem is that `null` may mean both
  /// * "I don't change this value"
  /// * "I change the value to null"
  /// Here we put an empty string instead, to be understood as "force to null!".
  Product _getUnselectedProduct() {
    final Product result = Product(barcode: barcode);
    switch (ImageField.fromOffTag(imageField)!) {
      case ImageField.FRONT:
        result.imageFrontUrl = '';
        break;
      case ImageField.INGREDIENTS:
        result.imageIngredientsUrl = '';
        break;
      case ImageField.NUTRITION:
        result.imageNutritionUrl = '';
        break;
      case ImageField.PACKAGING:
        result.imagePackagingUrl = '';
        break;
      case ImageField.OTHER:
      // We do nothing. Actually we're not supposed to unselect other images.
    }
    return result;
  }
}
