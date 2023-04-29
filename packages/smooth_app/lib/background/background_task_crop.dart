import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/abstract_background_task.dart';
import 'package:smooth_app/background/background_task_image.dart';
import 'package:smooth_app/background/background_task_refresh_later.dart';
import 'package:smooth_app/data_models/operation_type.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/query/product_query.dart';

/// Background task about product image crop from existing file.
class BackgroundTaskCrop extends AbstractBackgroundTask {
  const BackgroundTaskCrop._({
    required super.processName,
    required super.uniqueId,
    required super.barcode,
    required super.languageCode,
    required super.user,
    required super.country,
    required super.stamp,
    required this.imageId,
    required this.imageField,
    required this.croppedPath,
    required this.rotationDegrees,
    required this.cropX1,
    required this.cropY1,
    required this.cropX2,
    required this.cropY2,
  });

  BackgroundTaskCrop._fromJson(Map<String, dynamic> json)
      : this._(
          processName: json['processName'] as String,
          uniqueId: json['uniqueId'] as String,
          barcode: json['barcode'] as String,
          languageCode: json['languageCode'] as String,
          user: json['user'] as String,
          country: json['country'] as String,
          imageId: json['imageId'] as int,
          imageField: json['imageField'] as String,
          croppedPath: json['croppedPath'] as String,
          rotationDegrees: json['rotation'] as int,
          cropX1: json['x1'] as int? ?? 0,
          cropY1: json['y1'] as int? ?? 0,
          cropX2: json['x2'] as int? ?? 0,
          cropY2: json['y2'] as int? ?? 0,
          stamp: json['stamp'] as String,
        );

  /// Task ID.
  static const String _PROCESS_NAME = 'IMAGE_CROP';

  static const OperationType _operationType = OperationType.crop;

  final int imageId;
  final String imageField;
  final String croppedPath;
  final int rotationDegrees;
  final int cropX1;
  final int cropY1;
  final int cropX2;
  final int cropY2;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'processName': processName,
        'uniqueId': uniqueId,
        'barcode': barcode,
        'languageCode': languageCode,
        'user': user,
        'country': country,
        'imageId': imageId,
        'imageField': imageField,
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
      final AbstractBackgroundTask result = BackgroundTaskCrop._fromJson(map);
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
      barcode,
    );
    final AbstractBackgroundTask task = _getNewTask(
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
  String? getSnackBarMessage(final AppLocalizations appLocalizations) =>
      appLocalizations.product_task_background_schedule;

  /// Returns a new background task about cropping an existing image.
  static BackgroundTaskCrop _getNewTask(
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
        processName: _PROCESS_NAME,
        imageId: imageId,
        imageField: imageField.offTag,
        croppedPath: croppedFile.path,
        rotationDegrees: rotationDegrees,
        cropX1: cropX1,
        cropY1: cropY1,
        cropX2: cropX2,
        cropY2: cropY2,
        languageCode: ProductQuery.getLanguage().code,
        user: jsonEncode(ProductQuery.getUser().toJson()),
        country: ProductQuery.getCountry()!.offTag,
        stamp: BackgroundTaskImage.getStamp(
          barcode,
          imageField.offTag,
          ProductQuery.getLanguage().code,
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
    TransientFile.putImage(
      ImageField.fromOffTag(imageField)!,
      barcode,
      getLanguage(),
      localDatabase,
      File(croppedPath),
    );
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
    localDatabase.upToDate.terminate(uniqueId);
    try {
      File(croppedPath).deleteSync();
    } catch (e) {
      // not likely, but let's not spoil the task for that either.
    }
    TransientFile.removeImage(
      ImageField.fromOffTag(imageField)!,
      barcode,
      getLanguage(),
      localDatabase,
    );
    localDatabase.notifyListeners();
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
