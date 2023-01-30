import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/abstract_background_task.dart';
import 'package:smooth_app/background/background_task_refresh_later.dart';
import 'package:smooth_app/data_models/operation_type.dart';
import 'package:smooth_app/data_models/up_to_date_changes.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/query/product_query.dart';

/// Background task about product image upload.
class BackgroundTaskImage extends AbstractBackgroundTask {
  const BackgroundTaskImage._({
    required super.processName,
    required super.uniqueId,
    required super.barcode,
    required super.languageCode,
    required super.user,
    required super.country,
    required super.stamp,
    required this.imageField,
    required this.fullPath,
    required this.croppedPath,
    required this.rotationDegrees,
    required this.cropX1,
    required this.cropY1,
    required this.cropX2,
    required this.cropY2,
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
              : getStamp(
                  json['barcode'] as String,
                  json['imageField'] as String,
                  json['languageCode'] as String,
                ),
        );

  /// Task ID.
  static const String _PROCESS_NAME = 'IMAGE_UPLOAD';

  static const OperationType _operationType = OperationType.image;

  final String imageField;
  final String fullPath;
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
        languageCode: ProductQuery.getLanguage().code,
        user: jsonEncode(ProductQuery.getUser().toJson()),
        country: ProductQuery.getCountry()!.offTag,
        stamp: getStamp(
          barcode,
          imageField.offTag,
          ProductQuery.getLanguage().code,
        ),
      );

  static String getStamp(
    final String barcode,
    final String imageField,
    final String language,
  ) =>
      '$barcode;image;$imageField;$language';

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
    TransientFile.putImage(
      ImageField.fromOffTag(imageField)!,
      barcode,
      localDatabase,
      File(croppedPath),
    );
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
    TransientFile.removeImage(
      ImageField.fromOffTag(imageField)!,
      barcode,
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
    final ImageField imageField = ImageField.fromOffTag(this.imageField)!;
    final OpenFoodFactsLanguage language = getLanguage();
    final User user = getUser();
    final SendImage image = SendImage(
      lang: language,
      barcode: barcode,
      imageField: imageField,
      imageUri: Uri.parse(fullPath),
    );

    final Status status = await OpenFoodAPIClient.addProductImage(user, image);
    final int? imageId = status.imageId;
    if (imageId == null) {
      throw Exception(
          'Could not upload picture: ${status.status} / ${status.error}');
    }
    final String? imageUrl = await OpenFoodAPIClient.setProductImageCrop(
      barcode: barcode,
      imageField: imageField,
      language: language,
      imgid: '$imageId',
      angle: ImageAngleExtension.fromInt(rotationDegrees)!,
      x1: cropX1,
      y1: cropY1,
      x2: cropX2,
      y2: cropY2,
      user: user,
    );
    if (imageUrl == null) {
      throw Exception('Could not select picture');
    }
  }
}
