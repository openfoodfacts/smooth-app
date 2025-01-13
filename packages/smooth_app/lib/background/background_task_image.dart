import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_barcode.dart';
import 'package:smooth_app/background/background_task_queue.dart';
import 'package:smooth_app/background/background_task_refresh_later.dart';
import 'package:smooth_app/background/background_task_upload.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/data_models/up_to_date_changes.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/image_compute_container.dart';

/// Background task about product image upload.
class BackgroundTaskImage extends BackgroundTaskUpload {
  BackgroundTaskImage._({
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
    required this.fullPath,
  });

  BackgroundTaskImage.fromJson(super.json)
      : fullPath = json[_jsonTagImagePath] as String,
        super.fromJson();

  static const String _jsonTagImagePath = 'imagePath';

  static const OperationType _operationType = OperationType.image;

  final String fullPath;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = super.toJson();
    result[_jsonTagImagePath] = fullPath;
    return result;
  }

  // cf. https://github.com/openfoodfacts/smooth-app/issues/4219
  static bool isPictureBigEnough(final num width, final num height) =>
      width >= ImageHelper.minimumWidth || height >= ImageHelper.minimumHeight;

  /// Adds the background task about uploading a product image.
  static Future<void> addTask(
    final String barcode, {
    required final ProductType? productType,
    required final OpenFoodFactsLanguage language,
    required final ImageField imageField,
    required final File fullFile,
    required final File croppedFile,
    required final int rotation,
    required final int x1,
    required final int y1,
    required final int x2,
    required final int y2,
    required final BuildContext context,
  }) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      barcode: barcode,
    );
    final BackgroundTaskBarcode task = _getNewTask(
      language,
      barcode,
      productType ?? ProductType.food,
      imageField,
      fullFile,
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
      queue: BackgroundTaskQueue.slow,
    );
  }

  @override
  (String, AlignmentGeometry)? getFloatingMessage(
          final AppLocalizations appLocalizations) =>
      null;

  /// Returns a new background task about changing a product.
  static BackgroundTaskImage _getNewTask(
    final OpenFoodFactsLanguage language,
    final String barcode,
    final ProductType productType,
    final ImageField imageField,
    final File fullFile,
    final File croppedFile,
    final String uniqueId,
    final int rotationDegrees,
    final int cropX1,
    final int cropY1,
    final int cropX2,
    final int cropY2,
  ) =>
      BackgroundTaskImage._(
        uniqueId: uniqueId,
        barcode: barcode,
        productType: productType,
        processName: _operationType.processName,
        imageField: imageField.offTag,
        fullPath: fullFile.path,
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

  /// Returns a fake value that means: "remove the previous value when merging".
  ///
  /// If we use this task, it means that we took a brand new picture. Therefore,
  /// all previous crop parameters are attached to a different imageid, and
  /// to avoid confusion we need to clear them.
  /// cf. [UpToDateChanges._overwrite] regarding `images` field.
  @override
  ProductImage getProductImageChange() => ProductImage(
        field: ImageField.fromOffTag(imageField)!,
        language: getLanguage(),
        size: ImageSize.ORIGINAL,
      );

  // TODO(monsieurtanuki): we may also need to remove old files that were not removed from some reason
  @override
  Future<void> postExecute(
    final LocalDatabase localDatabase,
    final bool success,
  ) async {
    await super.postExecute(localDatabase, success);
    try {
      (await BackgroundTaskUpload.getFile(fullPath)).deleteSync();
    } catch (e) {
      // not likely, but let's not spoil the task for that either.
    }
    try {
      (await BackgroundTaskUpload.getFile(croppedPath)).deleteSync();
    } catch (e) {
      // not likely, but let's not spoil the task for that either.
    }
    try {
      (await BackgroundTaskUpload.getFile(getCroppedPath(fullPath)))
          .deleteSync();
    } catch (e) {
      // possible, but let's not spoil the task for that either.
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

  /// Returns an image loaded from data.
  static Future<ui.Image> loadUiImage(final Uint8List list) async {
    final Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromList(list, completer.complete);
    return completer.future;
  }

  /// Returns [source] with all corners multiplied by a [factor].
  static Rect getResizedRect(
    final Rect source,
    final num factor,
  ) =>
      Rect.fromLTRB(
        source.left * factor,
        source.top * factor,
        source.right * factor,
        source.bottom * factor,
      );

  static Rect getUpsizedRect(final Rect source) =>
      getResizedRect(source, _cropConversionFactor);

  static Rect getDownsizedRect(
    final int cropX1,
    final int cropY1,
    final int cropX2,
    final int cropY2,
  ) =>
      getResizedRect(
        Rect.fromLTRB(
          cropX1.toDouble(),
          cropY1.toDouble(),
          cropX2.toDouble(),
          cropY2.toDouble(),
        ),
        1 / _cropConversionFactor,
      );

  /// Conversion factor to `int` from / to UI / background task.
  static const int _cropConversionFactor = 1000000;

  /// Returns the file path of a crop operation.
  ///
  /// Returns directly the original [fullPath] if no crop operation was needed.
  /// Returns the path of the cropped file if relevant.
  /// Returns null if the image (cropped or not) is too small.
  static Future<String?> cropIfNeeded({
    required final String fullPath,
    required final String croppedPath,
    required final int rotationDegrees,
    required final int cropX1,
    required final int cropY1,
    required final int cropX2,
    required final int cropY2,
    final CustomPainter? overlayPainter,
    required final int compressQuality,
    required final bool forceCompression,
  }) async {
    final ui.Image full = await loadUiImage(
        await (await BackgroundTaskUpload.getFile(fullPath)).readAsBytes());
    if (!forceCompression) {
      if (cropX1 == 0 &&
          cropY1 == 0 &&
          cropX2 == _cropConversionFactor &&
          cropY2 == _cropConversionFactor &&
          rotationDegrees == 0) {
        if (!isPictureBigEnough(full.width, full.height)) {
          return null;
        }
        // in that case, no need to crop
        if (overlayPainter == null) {
          return fullPath;
        }
      }
    }

    Size getCroppedSize() {
      final Rect cropRect = getDownsizedRect(cropX1, cropY1, cropX2, cropY2);
      switch (CropRotationExtension.fromDegrees(rotationDegrees)!) {
        case CropRotation.up:
        case CropRotation.down:
          return Size(
            cropRect.width * full.height,
            cropRect.height * full.width,
          );
        case CropRotation.left:
        case CropRotation.right:
          return Size(
            cropRect.width * full.width,
            cropRect.height * full.height,
          );
      }
    }

    final Size croppedSize = getCroppedSize();
    if (!isPictureBigEnough(croppedSize.width, croppedSize.height)) {
      return null;
    }
    final ui.Image cropped = await CropController.getCroppedBitmap(
      crop: getDownsizedRect(cropX1, cropY1, cropX2, cropY2),
      rotation: CropRotationExtension.fromDegrees(rotationDegrees)!,
      image: full,
      maxSize: null,
      quality: FilterQuality.high,
      overlayPainter: overlayPainter,
    );
    await saveJpeg(
      file: await BackgroundTaskUpload.getFile(croppedPath),
      source: cropped,
      quality: compressQuality,
    );
    return croppedPath;
  }

  static String getCroppedPath(final String fullPath) =>
      '$fullPath.cropped.jpg';

  /// Uploads the product image.
  @override
  Future<void> upload() async {
    final String? path = await cropIfNeeded(
      fullPath: fullPath,
      croppedPath: getCroppedPath(fullPath),
      rotationDegrees: rotationDegrees,
      cropX1: cropX1,
      cropY1: cropY1,
      cropX2: cropX2,
      cropY2: cropY2,
      compressQuality: 100,
      forceCompression: false,
    );
    if (path == null) {
      // TODO(monsieurtanuki): maybe something more refined when we dismiss the picture, like alerting the user, though it's not supposed to happen anymore from upstream.
      return;
    }
    final ImageField imageField = ImageField.fromOffTag(this.imageField)!;
    final OpenFoodFactsLanguage language = getLanguage();
    final User user = getUser();
    final SendImage image = SendImage(
      lang: language,
      barcode: barcode,
      imageField: imageField,
      imageUri: Uri.parse(path),
    );

    final Status status = await OpenFoodAPIClient.addProductImage(
      user,
      image,
      uriHelper: uriProductHelper,
    );
    if (status.status == 'status ok') {
      // successfully uploaded a new picture and set it as field+language
      return;
    }
    final int? imageId = status.imageId;
    if (status.status == 'status not ok' && imageId != null) {
      // The very same image was already uploaded and therefore was rejected.
      // We just have to select this image, with no angle.
      final String? imageUrl = await OpenFoodAPIClient.setProductImageAngle(
        barcode: barcode,
        imageField: imageField,
        language: language,
        imgid: '$imageId',
        angle: ImageAngle.NOON,
        user: user,
        uriHelper: uriProductHelper,
      );
      if (imageUrl == null) {
        throw Exception('Could not select picture');
      }
      return;
    }
    throw Exception(
        'Could not upload picture: ${status.status} / ${status.error}');
  }
}
