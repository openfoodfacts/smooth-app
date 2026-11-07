import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_crop_result.dart';
import 'package:smooth_app/background/background_task_barcode.dart';
import 'package:smooth_app/background/background_task_price.dart';
import 'package:smooth_app/background/background_task_queue.dart';
import 'package:smooth_app/background/background_task_refresh_later.dart';
import 'package:smooth_app/background/background_task_upload.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/data_models/up_to_date_changes.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/image_cropper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/crop_helper.dart';
import 'package:smooth_app/pages/prices/eraser_model.dart';
import 'package:smooth_app/pages/prices/eraser_painter.dart';

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
    required this.eraserCoordinates,
  });

  BackgroundTaskImage.fromJson(super.json)
    : fullPath = json[_jsonTagImagePath] as String,
      eraserCoordinates = BackgroundTaskPrice.fromJsonListDouble(
        json[_jsonTagEraserCoordinates],
      ),
      super.fromJson();

  static const String _jsonTagImagePath = 'imagePath';
  static const String _jsonTagEraserCoordinates = 'eraserCoordinates';

  static const OperationType _operationType = OperationType.image;

  final String fullPath;
  final List<double>? eraserCoordinates;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = super.toJson();
    result[_jsonTagImagePath] = fullPath;
    result[_jsonTagEraserCoordinates] = eraserCoordinates;
    return result;
  }

  // cf. https://github.com/openfoodfacts/smooth-app/issues/4219
  static bool isPictureBigEnough(num width, num height) =>
      width >= ImageHelper.minimumWidth || height >= ImageHelper.minimumHeight;

  /// Adds the background task about uploading a product image.
  static Future<void> addTask(
    String barcode, {
    required ProductType? productType,
    required OpenFoodFactsLanguage language,
    required ImageField imageField,
    required File croppedFile,
    required int rotation,
    required int x1,
    required int y1,
    required int x2,
    required int y2,
    required List<double> eraserCoordinates,
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
      imageField,
      croppedFile,
      uniqueId,
      rotation,
      x1,
      y1,
      x2,
      y2,
      eraserCoordinates,
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
    AppLocalizations appLocalizations,
  ) => null;

  /// Returns a new background task about changing a product.
  static BackgroundTaskImage _getNewTask(
    OpenFoodFactsLanguage language,
    String barcode,
    ProductType productType,
    ImageField imageField,
    File croppedFile,
    String uniqueId,
    int rotationDegrees,
    int cropX1,
    int cropY1,
    int cropX2,
    int cropY2,
    List<double>? eraserCoordinates,
  ) => BackgroundTaskImage._(
    uniqueId: uniqueId,
    barcode: barcode,
    productType: productType,
    processName: _operationType.processName,
    imageField: imageField.offTag,
    fullPath: croppedFile.path,
    croppedPath: croppedFile.path,
    rotationDegrees: rotationDegrees,
    cropX1: cropX1,
    cropY1: cropY1,
    cropX2: cropX2,
    cropY2: cropY2,
    eraserCoordinates: eraserCoordinates,
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
    LocalDatabase localDatabase,
    bool success,
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
      (await BackgroundTaskUpload.getFile(
        await getCroppedPath(fullPath),
      )).deleteSync();
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
  static Future<ui.Image> loadUiImage(Uint8List list) async {
    final Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromList(list, completer.complete);
    return completer.future;
  }

  /// Returns [source] with all corners multiplied by a [factor].
  static Rect getResizedRect(Rect source, num factor) => Rect.fromLTRB(
    source.left * factor,
    source.top * factor,
    source.right * factor,
    source.bottom * factor,
  );

  static Rect getUpsizedRect(Rect source) =>
      getResizedRect(source, _cropConversionFactor);

  static Rect getDownsizedRect(
    int cropX1,
    int cropY1,
    int cropX2,
    int cropY2,
  ) => getResizedRect(
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
  /// [maxSize] is the max pixel size for width or height (e.g. 2000)
  static Future<BackgroundCropResult> cropIfNeeded({
    required String fullPath,
    required int rotationDegrees,
    required int cropX1,
    required int cropY1,
    required int cropX2,
    required int cropY2,
    required bool forceCompression,
    required List<double>? eraserCoordinates,
  }) async {
    final String croppedPath = await getCroppedPath(fullPath);

    final CustomPainter? overlayPainter =
        eraserCoordinates == null || eraserCoordinates.isEmpty
        ? null
        : EraserPainter(
            eraserModel: EraserModel(
              rotation: CropRotationExtension.fromDegrees(rotationDegrees)!,
              offsets: CropHelper.getOffsets(eraserCoordinates),
            ),
            cropRect: BackgroundTaskImage.getDownsizedRect(
              cropX1,
              cropY1,
              cropX2,
              cropY2,
            ),
          );
    final File fullFile = await BackgroundTaskUpload.getFile(fullPath);
    // TODO(monsieurtanuki): send full image width and height instead of recomputing them
    final ui.Image full = await loadUiImage(await fullFile.readAsBytes());
    final int fullWidth = full.width;
    final int fullHeight = full.height;
    full.dispose();
    if (!forceCompression) {
      if (cropX1 == 0 &&
          cropY1 == 0 &&
          cropX2 == _cropConversionFactor &&
          cropY2 == _cropConversionFactor &&
          rotationDegrees == 0) {
        if (!isPictureBigEnough(fullWidth, fullHeight)) {
          return BackgroundCropResult.error(
            'Picture too small ($fullWidth x $fullHeight)',
          );
        }
        // in that case, no need to crop
        if (overlayPainter == null) {
          return BackgroundCropResult.success(
            filePath: fullPath,
            fileSize: await fullFile.length(),
            width: fullWidth,
            height: fullHeight,
            message: 'Full image "as-is"',
          );
        }
      }
    }

    Size getCroppedSize() {
      final Rect cropRect = getDownsizedRect(cropX1, cropY1, cropX2, cropY2);
      switch (CropRotationExtension.fromDegrees(rotationDegrees)!) {
        case CropRotation.up:
        case CropRotation.down:
          return Size(cropRect.width * fullHeight, cropRect.height * fullWidth);
        case CropRotation.left:
        case CropRotation.right:
          return Size(cropRect.width * fullWidth, cropRect.height * fullHeight);
      }
    }

    final Size croppedSize = getCroppedSize();
    if (!isPictureBigEnough(croppedSize.width, croppedSize.height)) {
      return BackgroundCropResult.error(
        'Cropped picture too small (${croppedSize.width} x ${croppedSize.height})',
      );
    }
    final File croppedFile = await BackgroundTaskUpload.getFile(croppedPath);
    final ImageCropper imageCropper = ImageCropper(
      inputFile: fullFile,
      outputFile: croppedFile,
      crop: getDownsizedRect(cropX1, cropY1, cropX2, cropY2),
      rotation: CropRotationExtension.fromDegrees(rotationDegrees)!,
      overlayPainter: overlayPainter,
    );
    final (int, int) size = await imageCropper.saveCroppedJpeg();
    return BackgroundCropResult.success(
      filePath: croppedPath,
      fileSize: await croppedFile.length(),
      width: size.$1,
      height: size.$2,
      message: 'Cropped',
    );
  }

  static Future<String> getCroppedPath(String fullPath) async {
    final String croppedPath = '$fullPath.cropped.jpg';

    if (_isFileWritable(File(croppedPath))) {
      return croppedPath;
    }

    // In some cases, the location of the directory from
    // [BackgroundTaskUpload.getDirectory()] (= "application support" dir)
    // may have changed
    //
    // This issue is mainly on iOS devices, when a support directory can become
    // not writable anymore, but is still readable.
    return join(
      (await BackgroundTaskUpload.getDirectory()).path,
      Uri.file(croppedPath).pathSegments.last,
    );
  }

  /// Uploads the product image.
  @override
  Future<void> upload(LocalDatabase localDatabase) async {
    final UriProductHelper uriProductHelper = await getUriProductHelper(
      localDatabase,
    );
    SendImage? image;
    BackgroundCropResult? cropResult;
    try {
      final ImageField imageField = ImageField.fromOffTag(this.imageField)!;
      final OpenFoodFactsLanguage language = getLanguage();
      final User user = getUser();

      Future<Status> addImage({required bool force}) async {
        cropResult = await cropIfNeeded(
          fullPath: fullPath,
          rotationDegrees: rotationDegrees,
          cropX1: cropX1,
          cropY1: cropY1,
          cropX2: cropX2,
          cropY2: cropY2,
          forceCompression: force,
          eraserCoordinates: eraserCoordinates,
        );
        final String? path = cropResult!.filePath;
        if (path == null) {
          // TODO(monsieurtanuki): maybe something more refined when we dismiss the picture, like alerting the user, though it's not supposed to happen anymore from upstream.
          throw Exception('Could not get image path after compression');
        }
        image = SendImage(
          lang: language,
          barcode: barcode,
          imageField: imageField,
          imageUri: Uri.parse(path),
        );
        return OpenFoodAPIClient.addProductImage(
          user,
          image!,
          uriHelper: uriProductHelper,
        );
      }

      Status status;
      try {
        status = await addImage(force: false);
      } catch (e) {
        if (e.toString().contains('413') ||
            e.toString().contains('Request Entity Too Large')) {
          status = await addImage(force: true);
        } else {
          rethrow;
        }
      }
      if (status.status == 'status ok') {
        // successfully uploaded a new picture and set it as field+language
        return;
      }
      final int? imageId = status.imageId;
      if (status.status == 'status not ok' && imageId != null) {
        // The very same image was already uploaded and therefore was rejected.
        // We just have to select this image, with no angle.
        if (imageField == ImageField.OTHER) {
          // we're done here: all we wanted was to have the image uploaded, and
          // it is. And the server rejects "set as" operation for OTHER images.
          return;
        }
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
        'Could not upload picture: ${status.status} / ${status.error}',
      );
    } catch (e) {
      throw Exception('$e $cropResult - ${image?.toJson()}');
    }
  }

  static bool _isFileWritable(File file) {
    try {
      final FileStat stat = file.statSync();

      final bool isOwnerWritable = (stat.mode & 0x0080) != 0;
      final bool isGroupWritable = (stat.mode & 0x0010) != 0;
      final bool isOtherWritable = (stat.mode & 0x0002) != 0;

      return isOwnerWritable || isGroupWritable || isOtherWritable;
    } catch (_) {
      return false;
    }
  }
}
