import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/background/background_task_image.dart';
import 'package:smooth_app/pages/crop_parameters.dart';

/// Crop Helper for images in crop page: process to run when cropping an image.
abstract class CropHelper {
  /// Is that a new image, or an already cropped one?
  bool isNewImage();

  /// Page title of the crop page.
  String getPageTitle(final AppLocalizations appLocalizations);

  /// Icon of the "process!" button.
  IconData getProcessIcon();

  /// Label of the "process!" button.
  String getProcessLabel(final AppLocalizations appLocalizations);

  /// Processes the crop operation.
  Future<CropParameters?> process({
    required final BuildContext context,
    required final CropController controller,
    required final ui.Image image,
    required final File inputFile,
    required final File smallCroppedFile,
    required final Directory directory,
    required final int sequenceNumber,
    final List<Offset>? offsets,
  });

  /// Should we display the eraser with the crop grid?
  bool get enableEraser;

  /// Returns the crop rect according to local cropping method * factor.
  @protected
  Rect getLocalCropRect(final CropController controller) =>
      BackgroundTaskImage.getUpsizedRect(controller.crop);

  @protected
  CropParameters getCropParameters({
    required final CropController controller,
    required final File? fullFile,
    required final File smallCroppedFile,
    final List<Offset>? offsets,
  }) {
    final Rect cropRect = getLocalCropRect(controller);
    final List<double> eraserCoordinates = <double>[];
    if (offsets != null) {
      for (final Offset offset in offsets) {
        eraserCoordinates.add(offset.dx);
        eraserCoordinates.add(offset.dy);
      }
    }
    return CropParameters(
      fullFile: fullFile,
      smallCroppedFile: smallCroppedFile,
      rotation: controller.rotation.degrees,
      x1: cropRect.left.ceil(),
      y1: cropRect.top.ceil(),
      x2: cropRect.right.floor(),
      y2: cropRect.bottom.floor(),
      eraserCoordinates: eraserCoordinates,
    );
  }

  /// Returns a copy of a file with the full image (no cropping here).
  ///
  /// To be sent to the server, as well as the crop parameters and the rotation.
  /// It's faster for us to let the server do the actual cropping full size.
  @protected
  Future<File> copyFullImageFile(
    final Directory directory,
    final int sequenceNumber,
    final File inputFile,
  ) async {
    final File result;
    final String fullPath = '${directory.path}/full_image_$sequenceNumber.jpeg';
    result = inputFile.copySync(fullPath);
    return result;
  }
}
