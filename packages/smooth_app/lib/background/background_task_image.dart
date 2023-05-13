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
import 'package:smooth_app/background/abstract_background_task.dart';
import 'package:smooth_app/background/background_task_refresh_later.dart';
import 'package:smooth_app/background/background_task_upload.dart';
import 'package:smooth_app/data_models/operation_type.dart';
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

  BackgroundTaskImage._fromJson(Map<String, dynamic> json)
      : this._(
          processName: json['processName'] as String,
          uniqueId: json['uniqueId'] as String,
          barcode: json['barcode'] as String,
          languageCode: json['languageCode'] as String,
          user: json['user'] as String,
          country: json['country'] as String,
          imageField: json['imageField'] as String,
          fullPath: json['imagePath'] as String,
          // dealing with when 'croppedPath' did not exist
          croppedPath:
              json['croppedPath'] as String? ?? json['imagePath'] as String,
          rotationDegrees: json['rotation'] as int? ?? 0,
          cropX1: json['x1'] as int? ?? 0,
          cropY1: json['y1'] as int? ?? 0,
          cropX2: json['x2'] as int? ?? 0,
          cropY2: json['y2'] as int? ?? 0,
          // dealing with when 'stamp' did not exist
          stamp: json.containsKey('stamp')
              ? json['stamp'] as String
              : BackgroundTaskUpload.getStamp(
                  json['barcode'] as String,
                  json['imageField'] as String,
                  json['languageCode'] as String,
                ),
        );

  /// Task ID.
  static const String _PROCESS_NAME = 'IMAGE_UPLOAD';

  static const OperationType _operationType = OperationType.image;

  final String fullPath;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'processName': processName,
        'uniqueId': uniqueId,
        'barcode': barcode,
        'languageCode': languageCode,
        'user': user,
        'country': country,
        'imageField': imageField,
        'imagePath': fullPath,
        'croppedPath': croppedPath,
        'stamp': stamp,
        'rotation': rotationDegrees,
        'x1': cropX1,
        'y1': cropY1,
        'x2': cropX2,
        'y2': cropY2,
      };

  /// Returns the deserialized background task if possible, or null.
  static AbstractBackgroundTask? fromJson(final Map<String, dynamic> map) {
    try {
      final AbstractBackgroundTask result = BackgroundTaskImage._fromJson(map);
      if (result.processName == _PROCESS_NAME) {
        return result;
      }
    } catch (e) {
      //
    }
    return null;
  }

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
      barcode,
    );
    final AbstractBackgroundTask task = _getNewTask(
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
  String? getSnackBarMessage(final AppLocalizations appLocalizations) =>
      appLocalizations.image_upload_queued;

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
        processName: _PROCESS_NAME,
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
        country: ProductQuery.getCountry()!.offTag,
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
    localDatabase.upToDate.terminate(uniqueId);
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

  /// Returns true if a cropped operation is needed - after having performed it.
  Future<bool> _crop(final File file) async {
    if (cropX1 == 0 &&
        cropY1 == 0 &&
        cropX2 == cropConversionFactor &&
        cropY2 == cropConversionFactor &&
        rotationDegrees == 0) {
      // in that case, no need to crop
      return false;
    }
    final ui.Image full = await loadUiImage(
      await File(fullPath).readAsBytes(),
    );
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
    await ImageComputeContainer(file: file, source: cropped).saveJpeg();
    return true;
  }

  /// Returns the path of the locally computed cropped path (if relevant).
  String _getCroppedPath() => '$fullPath.cropped.jpg';

  /// Uploads the product image.
  @override
  Future<void> upload() async {
    final String path;
    final String croppedPath = _getCroppedPath();
    if (await _crop(File(croppedPath))) {
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
