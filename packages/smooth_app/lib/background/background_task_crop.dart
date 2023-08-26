import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_barcode.dart';
import 'package:smooth_app/background/background_task_refresh_later.dart';
import 'package:smooth_app/background/background_task_upload.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/query/product_query.dart';

/// Background task about product image crop from existing file.
class BackgroundTaskCrop extends BackgroundTaskUpload {
  const BackgroundTaskCrop._({
    required super.processName,
    required super.uniqueId,
    required super.barcode,
    required super.languageCode,
    required super.user,
    required super.country,
    required super.stamp,
    required super.imageField,
    required super.croppedPath,
    required super.rotationDegrees,
    required super.cropX1,
    required super.cropY1,
    required super.cropX2,
    required super.cropY2,
    required this.imageId,
  });

  BackgroundTaskCrop.fromJson(Map<String, dynamic> json)
      : imageId = json[_jsonTagImageId] as int,
        super.fromJson(json);

  static const String _jsonTagImageId = 'imageId';

  static const OperationType _operationType = OperationType.crop;

  final int imageId;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = super.toJson();
    result[_jsonTagImageId] = imageId;
    return result;
  }

  /// Adds the background task about uploading a product image.
  static Future<void> addTask(
    final String barcode, {
    required final OpenFoodFactsLanguage language,
    required final int imageId,
    required final ImageField imageField,
    required final File croppedFile,
    required final int rotation,
    required final int x1,
    required final int y1,
    required final int x2,
    required final int y2,
    required final State<StatefulWidget> widget,
  }) async {
    final LocalDatabase localDatabase = widget.context.read<LocalDatabase>();
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      barcode: barcode,
    );
    final BackgroundTaskBarcode task = _getNewTask(
      language,
      barcode,
      imageId,
      imageField,
      croppedFile,
      uniqueId,
      rotation,
      x1,
      y1,
      x2,
      y2,
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

  /// Returns a new background task about cropping an existing image.
  static BackgroundTaskCrop _getNewTask(
    final OpenFoodFactsLanguage language,
    final String barcode,
    final int imageId,
    final ImageField imageField,
    final File croppedFile,
    final String uniqueId,
    final int rotationDegrees,
    final int cropX1,
    final int cropY1,
    final int cropX2,
    final int cropY2,
  ) =>
      BackgroundTaskCrop._(
        uniqueId: uniqueId,
        barcode: barcode,
        processName: _operationType.processName,
        imageId: imageId,
        imageField: imageField.offTag,
        croppedPath: croppedFile.path,
        rotationDegrees: rotationDegrees,
        cropX1: cropX1,
        cropY1: cropY1,
        cropX2: cropX2,
        cropY2: cropY2,
        languageCode: language.code,
        user: jsonEncode(ProductQuery.getUser().toJson()),
        country: ProductQuery.getCountry().offTag,
        stamp: BackgroundTaskUpload.getStamp(
          barcode,
          imageField.offTag,
          language.code,
        ),
      );

  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async {
    await localDatabase.upToDate.addChange(
      uniqueId,
      Product(
        barcode: barcode,
        images: <ProductImage>[_getProductImage()],
      ),
    );
    putTransientImage(localDatabase);
  }

  /// Returns the actual crop parameters.
  ///
  /// cf. [UpToDateChanges._overwrite] regarding `images` field.
  ProductImage _getProductImage() => ProductImage(
        field: ImageField.fromOffTag(imageField)!,
        language: getLanguage(),
        size: ImageSize.ORIGINAL,
        angle: ImageAngleExtension.fromInt(rotationDegrees),
        imgid: '$imageId',
        x1: cropX1,
        y1: cropY1,
        x2: cropX2,
        y2: cropY2,
        coordinatesImageSize: ImageSize.ORIGINAL.number,
      );

  @override
  Future<void> postExecute(
    final LocalDatabase localDatabase,
    final bool success,
  ) async {
    await super.postExecute(localDatabase, success);
    try {
      File(croppedPath).deleteSync();
    } catch (e) {
      // not likely, but let's not spoil the task for that either.
    }
    removeTransientImage(localDatabase);
    if (success) {
      await BackgroundTaskRefreshLater.addTask(
        barcode,
        localDatabase: localDatabase,
      );
    }
  }

  /// Uploads the product image.
  @override
  Future<void> upload() async {
    final ProductImage productImage = _getProductImage();
    final String? imageUrl = await OpenFoodAPIClient.setProductImageCrop(
      barcode: barcode,
      imageField: productImage.field,
      language: getLanguage(),
      imgid: productImage.imgid!,
      angle: productImage.angle!,
      x1: productImage.x1!,
      y1: productImage.y1!,
      x2: productImage.x2!,
      y2: productImage.y2!,
      user: getUser(),
    );
    if (imageUrl == null) {
      throw Exception('Could not select picture');
    }
  }
}
