import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_barcode.dart';
import 'package:smooth_app/background/background_task_refresh_later.dart';
import 'package:smooth_app/background/background_task_upload.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/data_models/up_to_date_changes.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/image_compute_container.dart';
import 'package:smooth_app/query/product_query.dart';

/// Background task about product image upload.
class BackgroundTaskImage extends BackgroundTaskUpload {
  const BackgroundTaskImage._({
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
    required this.fullPath,
  });

  BackgroundTaskImage.fromJson(Map<String, dynamic> json)
      : fullPath = json[_jsonTagImagePath] as String,
        super.fromJson(json);

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
  // TODO(monsieurtanuki): move to off-dart
  static const int minimumWidth = 640;
  static const int minimumHeight = 160;

  static bool isPictureBigEnough(final num width, final num height) =>
      width >= minimumWidth || height >= minimumHeight;

  /// Adds the background task about uploading a product image.
  static Future<void> addTask(
    final String barcode, {
    required final OpenFoodFactsLanguage language,
    required final ImageField imageField,
    required final File fullFile,
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
    await task.addToManager(localDatabase, widget: widget);
  }

  @override
  (String, AlignmentGeometry)? getFloatingMessage(
          final AppLocalizations appLocalizations) =>
      (
        appLocalizations.image_upload_queued,
        AlignmentDirectional.topCenter,
      );

  /// Returns a new background task about changing a product.
  static BackgroundTaskImage _getNewTask(
    final OpenFoodFactsLanguage language,
    final String barcode,
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
        processName: _operationType.processName,
        imageField: imageField.offTag,
        fullPath: fullFile.path,
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

  /// Returns true if the stamp is an "image/OTHER" stamp.
  ///
  /// That's important because "image/OTHER" task are never duplicates.
  static bool isOtherStamp(final String stamp) =>
      stamp.contains(';image;${ImageField.OTHER.offTag};');

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

  /// Returns a fake value that means: "remove the previous value when merging".
  ///
  /// If we use this task, it means that we took a brand new picture. Therefore,
  /// all previous crop parameters are attached to a different imageid, and
  /// to avoid confusion we need to clear them.
  /// cf. [UpToDateChanges._overwrite] regarding `images` field.
  ProductImage _getProductImage() => ProductImage(
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
      File(fullPath).deleteSync();
    } catch (e) {
      // not likely, but let's not spoil the task for that either.
    }
    try {
      File(croppedPath).deleteSync();
    } catch (e) {
      // not likely, but let's not spoil the task for that either.
    }
    try {
      File(_getCroppedPath()).deleteSync();
    } catch (e) {
      // possible, but let's not spoil the task for that either.
    }
    removeTransientImage(localDatabase);
    if (success) {
      await BackgroundTaskRefreshLater.addTask(
        barcode,
        localDatabase: localDatabase,
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

  /// Conversion factor to `int` from / to UI / background task.
  static const int cropConversionFactor = 1000000;

  /// Returns true if a crop operation is needed - after having performed it.
  ///
  /// Returns false if no crop operation is needed.
  /// Returns null if the image (cropped or not) is too small.
  Future<bool?> _crop(final File file) async {
    final ui.Image full = await loadUiImage(await File(fullPath).readAsBytes());
    if (cropX1 == 0 &&
        cropY1 == 0 &&
        cropX2 == cropConversionFactor &&
        cropY2 == cropConversionFactor &&
        rotationDegrees == 0) {
      if (!isPictureBigEnough(full.width, full.height)) {
        return null;
      }
      // in that case, no need to crop
      return false;
    }

    Size getCroppedSize() {
      final Rect cropRect = getResizedRect(
        Rect.fromLTRB(
          cropX1.toDouble(),
          cropY1.toDouble(),
          cropX2.toDouble(),
          cropY2.toDouble(),
        ),
        1 / cropConversionFactor,
      );
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
      crop: getResizedRect(
        Rect.fromLTRB(
          cropX1.toDouble(),
          cropY1.toDouble(),
          cropX2.toDouble(),
          cropY2.toDouble(),
        ),
        1 / cropConversionFactor,
      ),
      rotation: CropRotationExtension.fromDegrees(rotationDegrees)!,
      image: full,
      maxSize: null,
      quality: FilterQuality.high,
    );
    await saveJpeg(file: file, source: cropped);
    return true;
  }

  /// Returns the path of the locally computed cropped path (if relevant).
  String _getCroppedPath() => '$fullPath.cropped.jpg';

  /// Uploads the product image.
  @override
  Future<void> upload() async {
    final String path;
    final String croppedPath = _getCroppedPath();
    final bool? neededCrop = await _crop(File(croppedPath));
    if (neededCrop == null) {
      // TODO(monsieurtanuki): maybe something more refined when we dismiss the picture, like alerting the user, though it's not supposed to happen anymore from upstream.
      return;
    }
    if (neededCrop) {
      path = croppedPath;
    } else {
      path = fullPath;
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

    final Status status = await OpenFoodAPIClient.addProductImage(user, image);
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
