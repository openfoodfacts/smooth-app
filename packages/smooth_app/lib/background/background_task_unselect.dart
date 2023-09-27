import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_barcode.dart';
import 'package:smooth_app/background/background_task_refresh_later.dart';
import 'package:smooth_app/background/background_task_upload.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/query/product_query.dart';

/// Background task about unselecting a product image.
class BackgroundTaskUnselect extends BackgroundTaskBarcode {
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

  BackgroundTaskUnselect.fromJson(Map<String, dynamic> json)
      : imageField = json[_jsonTagImageField] as String,
        super.fromJson(json);

  static const String _jsonTagImageField = 'imageField';

  static const OperationType _operationType = OperationType.unselect;

  final String imageField;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = super.toJson();
    result[_jsonTagImageField] = imageField;
    return result;
  }

  /// Adds the background task about unselecting a product image.
  static Future<void> addTask(
    final String barcode, {
    required final ImageField imageField,
    required final State<StatefulWidget> widget,
    required final OpenFoodFactsLanguage language,
  }) async {
    final LocalDatabase localDatabase = widget.context.read<LocalDatabase>();
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      barcode: barcode,
    );
    final BackgroundTaskBarcode task = _getNewTask(
      barcode,
      imageField,
      uniqueId,
      language,
    );
    await task.addToManager(localDatabase, widget: widget);
  }

  @override
  (String, AlignmentGeometry)? getFloatingMessage(
          final AppLocalizations appLocalizations) =>
      (
        appLocalizations.product_task_background_schedule,
        AlignmentDirectional.topCenter,
      );

  /// Returns a new background task about unselecting a product image.
  static BackgroundTaskUnselect _getNewTask(
    final String barcode,
    final ImageField imageField,
    final String uniqueId,
    final OpenFoodFactsLanguage language,
  ) =>
      BackgroundTaskUnselect._(
        uniqueId: uniqueId,
        barcode: barcode,
        processName: _operationType.processName,
        imageField: imageField.offTag,
        languageCode: language.code,
        user: jsonEncode(ProductQuery.getUser().toJson()),
        country: ProductQuery.getCountry().offTag,
        // same stamp as image upload
        stamp: BackgroundTaskUpload.getStamp(
          barcode,
          imageField.offTag,
          language.code,
        ),
      );

  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async {
    localDatabase.upToDate.addChange(uniqueId, _getUnselectedProduct());
    _getTransientFile().removeImage(localDatabase);
  }

  TransientFile _getTransientFile() => TransientFile(
        ImageField.fromOffTag(imageField)!,
        barcode,
        getLanguage(),
      );

  @override
  Future<void> postExecute(
    final LocalDatabase localDatabase,
    final bool success,
  ) async {
    await super.postExecute(localDatabase, success);
    // TODO(monsieurtanuki): we should also remove the hypothetical transient file, shouldn't we?
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
    ImageField.fromOffTag(imageField)!.setUrl(result, '');
    return result;
  }
}
