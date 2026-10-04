import 'dart:io';
import 'dart:ui';

import 'package:crop_image/crop_image.dart';
import 'package:smooth_app/pages/crop_helper.dart';

/// Parameters of the crop operation.
class CropParameters {
  CropParameters._({
    required this.fullFile,
    required this.preCroppedFile,
    required this.rotation,
    required Rect cropRect,
  }) : x1 = cropRect.left.ceil(),
       y1 = cropRect.top.ceil(),
       x2 = cropRect.right.floor(),
       y2 = cropRect.bottom.floor();

  factory CropParameters.withoutFullFile({
    required final File preCroppedFile,
    required final int rotation,
    required final Rect cropRect,
  }) => CropParameters._(
    fullFile: null,
    preCroppedFile: preCroppedFile,
    rotation: rotation,
    cropRect: cropRect,
  );

  factory CropParameters.asIs(final File file) => CropParameters._(
    fullFile: file,
    preCroppedFile: file,
    rotation: CropRotation.up.degrees,
    cropRect: CropHelper.getFullLocalCropRect(),
  );

  /// File of the full image.
  ///
  /// May not be populated: when we crop from an image that already exists on
  /// the server.
  final File? fullFile;

  /// File of the cropped image, resized according to max size.
  ///
  /// Possibly an untouched full-size image.
  final File preCroppedFile;

  final int rotation;
  final int x1;
  final int y1;
  final int x2;
  final int y2;
}
