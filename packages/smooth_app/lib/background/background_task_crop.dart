import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_barcode.dart';
import 'package:smooth_app/background/background_task_queue.dart';
import 'package:smooth_app/background/background_task_refresh_later.dart';
import 'package:smooth_app/background/background_task_upload.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/l10n/app_localizations.dart';

/// Background task about product image crop from existing file.
class BackgroundTaskCrop extends BackgroundTaskUpload {
  BackgroundTaskCrop._({
    required super.processName,
    required super.uniqueId,
    required super.barcode,
    required super.productType,
    required super.language,
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

  BackgroundTaskCrop.fromJson(super.json)
    : imageId = json[_jsonTagImageId] as int,
      super.fromJson();

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
    String barcode, {
    required ProductType? productType,
    required OpenFoodFactsLanguage language,
    required int imageId,
    required ImageField imageField,
    required File croppedFile,
    required int rotation,
    required int x1,
    required int y1,
    required int x2,
    required int y2,
    required BuildContext context,
  }) async {
    if (BackgroundTaskBarcode.isBarcodeToBeIgnored(barcode, context)) {
      return;
    }
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      barcode: barcode,
    );
    final BackgroundTaskBarcode task = _getNewTask(
      language,
      barcode,
      productType ?? ProductType.food,
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
    if (!context.mounted) {
      return;
    }
    await task.addToManager(
      localDatabase,
      context: context,
      queue: BackgroundTaskQueue.fast,
    );
  }

  @override
  (String, AlignmentGeometry)? getFloatingMessage(
    AppLocalizations appLocalizations,
  ) => (
    appLocalizations.product_task_background_schedule,
    AlignmentDirectional.topCenter,
  );

  /// Returns a new background task about cropping an existing image.
  static BackgroundTaskCrop _getNewTask(
    OpenFoodFactsLanguage language,
    String barcode,
    ProductType productType,
    int imageId,
    ImageField imageField,
    File croppedFile,
    String uniqueId,
    int rotationDegrees,
    int cropX1,
    int cropY1,
    int cropX2,
    int cropY2,
  ) => BackgroundTaskCrop._(
    uniqueId: uniqueId,
    barcode: barcode,
    productType: productType,
    processName: _operationType.processName,
    imageId: imageId,
    imageField: imageField.offTag,
    croppedPath: croppedFile.path,
    rotationDegrees: rotationDegrees,
    cropX1: cropX1,
    cropY1: cropY1,
    cropX2: cropX2,
    cropY2: cropY2,
    language: language,
    stamp: BackgroundTaskUpload.getStamp(
      barcode,
      imageField.offTag,
      language.code,
    ),
  );

  /// Returns the actual crop parameters.
  ///
  /// cf. [UpToDateChanges._overwrite] regarding `images` field.
  @override
  ProductImage getProductImageChange() => ProductImage(
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
    LocalDatabase localDatabase,
    bool success,
  ) async {
    await super.postExecute(localDatabase, success);
    try {
      (await BackgroundTaskUpload.getFile(croppedPath)).deleteSync();
    } catch (e) {
      // not likely, but let's not spoil the task for that either.
    }
    removeTransientImage(localDatabase);
    if (success) {
      await BackgroundTaskRefreshLater.addTask(
        barcode,
        localDatabase: localDatabase,
        productType: productType,
      );
    }
  }

  /// Uploads the product image.
  @override
  Future<void> upload(LocalDatabase localDatabase) async {
    final UriProductHelper uriProductHelper = await getUriProductHelper(
      localDatabase,
    );
    final ProductImage productImage = getProductImageChange();
    try {
      final String? imageUrl = await OpenFoodAPIClient.setProductImageCrop(
        barcode: barcode,
        imageField: productImage.field!,
        language: getLanguage(),
        imgid: productImage.imgid!,
        angle: productImage.angle!,
        x1: productImage.x1!,
        y1: productImage.y1!,
        x2: productImage.x2!,
        y2: productImage.y2!,
        user: getUser(),
        uriHelper: uriProductHelper,
      );
      if (imageUrl == null) {
        throw Exception('Could not select picture');
      }
    } catch (e) {
      throw Exception('$e $productImage');
    }
  }
}
