import 'dart:io';
import 'dart:ui';

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
