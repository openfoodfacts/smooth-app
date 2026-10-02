import 'dart:io';
import 'dart:ui';

import 'package:crop_image/crop_image.dart';
import 'package:smooth_app/pages/crop_helper.dart';

/// Parameters of the crop operation.
class CropParameters {
  CropParameters({
    required this.fullFile,
    required this.smallCroppedFile,
    required this.rotation,
    required Rect cropRect,
    this.eraserCoordinates,
  }) : x1 = cropRect.left.ceil(),
       y1 = cropRect.top.ceil(),
       x2 = cropRect.right.floor(),
       y2 = cropRect.bottom.floor();

  factory CropParameters.asIs({required File fullFile}) => CropParameters(
    fullFile: fullFile,
    smallCroppedFile: null,
    rotation: CropRotation.up.degrees,
    cropRect: CropHelper.getFullLocalCropRect(),
  );

  /// File of the full image.
  final File? fullFile;

  /// File of the cropped image, resized according to the screen.
  final File? smallCroppedFile;

  final int rotation;
  final int x1;
  final int y1;
  final int x2;
  final int y2;

  final List<double>? eraserCoordinates;
}
