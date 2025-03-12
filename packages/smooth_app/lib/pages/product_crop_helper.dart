import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_crop.dart';
import 'package:smooth_app/background/background_task_image.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/pages/crop_helper.dart';
import 'package:smooth_app/pages/crop_parameters.dart';

/// Crop Helper for product images.
abstract class ProductCropHelper extends CropHelper {
  ProductCropHelper({
    required this.imageField,
    required this.language,
    required this.barcode,
    required this.productType,
  });

  final ImageField imageField;
  final OpenFoodFactsLanguage language;
  final String barcode;
  final ProductType? productType;

  @override
  String getPageTitle(final AppLocalizations appLocalizations) =>
      imageField.getImagePageTitle(appLocalizations);

  @override
  IconData getProcessIcon() => Icons.send;

  @override
  String getProcessLabel(final AppLocalizations appLocalizations) =>
      appLocalizations.send_image_button_label;

  @override
  bool get enableEraser => false;

  @protected
  Future<void> refresh(final BuildContext context) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    localDatabase.notifyListeners();
    final ContinuousScanModel model = context.read<ContinuousScanModel>();
    await model.onCreateProduct(barcode); // TODO(monsieurtanuki): a bit fishy
  }
}

/// Crop Helper for product images: brand new image.
class ProductCropNewHelper extends ProductCropHelper {
  ProductCropNewHelper({
    required super.imageField,
    required super.language,
    required super.barcode,
    required super.productType,
  });

  @override
  bool isNewImage() => true;

  @override
  bool get enableEraser => productType == ProductType.product;

  @override
  Future<CropParameters?> process({
    required final BuildContext context,
    required final CropController controller,
    required final ui.Image image,
    required final File inputFile,
    required final File smallCroppedFile,
    required final Directory directory,
    required final int sequenceNumber,
    required final List<Offset> offsets,
  }) async {
    // in this case, it's a brand new picture, with crop parameters.
    // for performance reasons, we do not crop the image full-size here,
    // but in the background task.
    // for privacy reasons, we won't send the full image to the server and
    // let it crop it: we'll send the cropped image directly.
    final File fullFile = await copyFullImageFile(
      directory,
      sequenceNumber,
      inputFile,
    );
    final Rect cropRect = getLocalCropRect(controller);
    if (!context.mounted) {
      return null;
    }
    await BackgroundTaskImage.addTask(
      barcode,
      productType: productType,
      language: language,
      imageField: imageField,
      fullFile: fullFile,
      croppedFile: smallCroppedFile,
      rotation: controller.rotation.degrees,
      x1: cropRect.left.ceil(),
      y1: cropRect.top.ceil(),
      x2: cropRect.right.floor(),
      y2: cropRect.bottom.floor(),
      eraserCoordinates: CropHelper.getEraserCoordinates(offsets),
      context: context,
    );

    if (context.mounted) {
      await refresh(context);
    }
    return getCropParameters(
      controller: controller,
      fullFile: fullFile,
      smallCroppedFile: smallCroppedFile,
      offsets: offsets,
    );
  }
}

/// Crop Helper for product images: from an existing image.
class ProductCropAgainHelper extends ProductCropHelper {
  ProductCropAgainHelper({
    required super.imageField,
    required super.language,
    required super.barcode,
    required super.productType,
    required this.imageId,
  });

  final int imageId;

  @override
  bool isNewImage() => false;

  @override
  Future<CropParameters?> process({
    required final BuildContext context,
    required final CropController controller,
    required final ui.Image image,
    required final File inputFile,
    required final File smallCroppedFile,
    required final Directory directory,
    required final int sequenceNumber,
    required final List<Offset> offsets,
  }) async {
    // in this case, it's an existing picture, with crop parameters.
    // we let the server do everything: better performance, and no privacy
    // issue here (we're cropping from an allegedly already privacy compliant
    // picture).
    final Rect cropRect = _getServerCropRect(controller, image);
    await BackgroundTaskCrop.addTask(
      barcode,
      productType: productType,
      language: language,
      imageField: imageField,
      imageId: imageId,
      croppedFile: smallCroppedFile,
      rotation: controller.rotation.degrees,
      x1: cropRect.left.ceil(),
      y1: cropRect.top.ceil(),
      x2: cropRect.right.floor(),
      y2: cropRect.bottom.floor(),
      context: context,
    );
    if (context.mounted) {
      await refresh(context);
    }
    return getCropParameters(
      controller: controller,
      fullFile: null,
      smallCroppedFile: smallCroppedFile,
      offsets: offsets,
    );
  }

  /// Returns the crop rect according to server cropping method.
  Rect _getServerCropRect(
    final CropController controller,
    final ui.Image image,
  ) {
    final Offset center = _getRotatedOffsetForOff(
      controller.crop.center,
      controller,
      image,
    );
    final Offset topLeft = _getRotatedOffsetForOff(
      controller.crop.topLeft,
      controller,
      image,
    );
    double width = 2 * (center.dx - topLeft.dx);
    if (width < 0) {
      width = -width;
    }
    double height = 2 * (center.dy - topLeft.dy);
    if (height < 0) {
      height = -height;
    }
    final Rect rect = Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    );
    return rect;
  }

  Offset _getRotatedOffsetForOff(
    final Offset offset,
    final CropController controller,
    final ui.Image image,
  ) =>
      _getRotatedOffsetForOffHelper(
        controller.rotation,
        offset,
        image.width.toDouble(),
        image.height.toDouble(),
      );

  /// Returns the offset as rotated, for the OFF-dart rotation/crop tool.
  Offset _getRotatedOffsetForOffHelper(
    final CropRotation rotation,
    final Offset offset01,
    final double noonWidth,
    final double noonHeight,
  ) {
    switch (rotation) {
      case CropRotation.up:
      case CropRotation.down:
        return Offset(
          noonWidth * offset01.dx,
          noonHeight * offset01.dy,
        );
      case CropRotation.right:
      case CropRotation.left:
        return Offset(
          noonHeight * offset01.dx,
          noonWidth * offset01.dy,
        );
    }
  }
}
