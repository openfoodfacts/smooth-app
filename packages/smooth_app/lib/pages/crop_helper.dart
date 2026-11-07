import 'dart:async';
import 'dart:io';

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/background/background_task_image.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/crop_parameters.dart';

/// Crop Helper for images in crop page: process to run when cropping an image.
abstract class CropHelper {
  /// Is that a new image, or an already cropped one?
  bool isNewImage();

  /// Page title of the crop page.
  String getPageTitle(AppLocalizations appLocalizations);

  /// Icon of the "process!" button.
  Widget getProcessIcon();

  /// Label of the "process!" button.
  String getProcessLabel(AppLocalizations appLocalizations);

  /// Processes the crop operation.
  Future<CropParameters> process({
    required BuildContext context,
    required CropController controller,
    required File inputFile,
    required int inputFullWidth,
    required int inputFullHeight,
    required File preCroppedFile,
    required Directory directory,
    required int sequenceNumber,
    required List<Offset> offsets,
  });

  /// Should we display the eraser with the crop grid?
  bool get enableEraser;

  static Rect _getLocalCropRectFromRect(Rect crop) =>
      BackgroundTaskImage.getUpsizedRect(crop);

  static Rect getFullLocalCropRect() =>
      _getLocalCropRectFromRect(CropHelper.fullImageCropRect);

  /// Returns the crop rect according to local cropping method * factor.
  @protected
  Rect getLocalCropRect(CropController controller) =>
      _getLocalCropRectFromRect(controller.crop);

  /// Full-size crop, aka no crop.
  static const Rect fullImageCropRect = Rect.fromLTRB(0, 0, 1, 1);

  static List<Offset> getOffsets(List<double>? eraserCoordinates) {
    final List<Offset> offsets = <Offset>[];
    if (eraserCoordinates != null) {
      for (int i = 0; i < eraserCoordinates.length; i += 2) {
        final Offset offset = Offset(
          eraserCoordinates[i],
          eraserCoordinates[i + 1],
        );
        offsets.add(offset);
      }
    }
    return offsets;
  }
}
