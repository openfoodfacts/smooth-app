import 'dart:io';

/// Parameters of the crop operation.
class CropParameters {
  const CropParameters({
    this.fullFile,
    required this.smallCroppedFile,
    required this.rotation,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    this.eraserCoordinates,
  });

  /// File of the full image.
  final File? fullFile;

  /// File of the cropped image, resized according to the screen.
  final File smallCroppedFile;

  final int rotation;
  final int x1;
  final int y1;
  final int x2;
  final int y2;

  final List<double>? eraserCoordinates;
}
