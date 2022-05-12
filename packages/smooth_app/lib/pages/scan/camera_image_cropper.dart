import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_barcode_scanner/google_ml_barcode_scanner.dart';
import 'package:smooth_app/pages/scan/abstract_camera_image_getter.dart';
import 'package:typed_data/typed_buffers.dart';

/// Camera Image Cropper, in order to limit the barcode scan computations.
///
/// Use CameraController with imageFormatGroup: ImageFormatGroup.yuv420
/// [left01], [top01], [width01] and [height01] are values between 0 and 1
/// that delimit the cropping area.
/// For instance:
/// * left01: 0, top01: 0, width01: 1, height01: .2 delimit the top 20% banner
/// * left01: .5, top01: .5, width01: .5, height01: ..5 the bottom right rect
class CameraImageCropper extends AbstractCameraImageGetter {
  CameraImageCropper(
    final CameraImage cameraImage,
    final CameraDescription cameraDescription, {
    required this.left01,
    required this.top01,
    required this.width01,
    required this.height01,
  }) : super(cameraImage, cameraDescription) {
    _computeCropParameters();
  }

  final double left01;
  final double top01;
  final double width01;
  final double height01;
  late int _left;
  late int _top;
  late int _width;
  late int _height;

  void _computeCropParameters() {
    assert(width01 > 0 && width01 <= 1);
    assert(height01 > 0 && height01 <= 1);
    assert(left01 >= 0 && left01 < 1);
    assert(top01 >= 0 && top01 < 1);
    assert(left01 + width01 <= 1);
    assert(top01 + height01 <= 1);

    final int fullWidth = cameraImage.width;
    final int fullHeight = cameraImage.height;
    final int orientation = cameraDescription.sensorOrientation;

    int _getEven(final double value) => 2 * (value ~/ 2);

    if (orientation == 0) {
      _width = _getEven(fullWidth * width01);
      _height = _getEven(fullHeight * height01);
      _left = _getEven(fullWidth * left01);
      _top = _getEven(fullHeight * top01);
      return;
    }
    if (orientation == 90) {
      _width = _getEven(fullWidth * height01);
      _height = _getEven(fullHeight * width01);
      _left = _getEven(fullWidth * top01);
      _top = _getEven(fullHeight * left01);
      return;
    }
    throw Exception('Orientation $orientation not dealt with for the moment');
  }

  // cf. https://en.wikipedia.org/wiki/YUV#Y′UV420p_(and_Y′V12_or_YV12)_to_RGB888_conversion
  static const Map<int, int> _planeDividers = <int, int>{
    0: 1, // Y
    1: 2, // U
    2: 2, // V
  };

  @override
  Size getSize() => Size(_width.toDouble(), _height.toDouble());

  @override
  Uint8List getBytes() {
    int size = 0;
    for (final int divider in _planeDividers.values) {
      size += (_width ~/ divider) * (_height ~/ divider);
    }
    final Uint8Buffer buffer = Uint8Buffer(size);
    final int imageWidth = cameraImage.width;
    int planeIndex = 0;
    int bufferOffset = 0;
    for (final Plane plane in cameraImage.planes) {
      final int divider = _planeDividers[planeIndex]!;
      final int fullWidth = imageWidth ~/ divider;
      final int cropLeft = _left ~/ divider;
      final int cropTop = _top ~/ divider;
      final int cropWidth = _width ~/ divider;
      final int cropHeight = _height ~/ divider;

      for (int i = 0; i < cropHeight; i++) {
        //buffer.replaceRange(bufferOffset, bufferOffset + cropWidth, plane.bytes.getRange(15, 16));
        for (int j = 0; j < cropWidth; j++) {
          buffer[bufferOffset++] =
              plane.bytes[fullWidth * (cropTop + i) + cropLeft + j];
        }
      }
      planeIndex++;
    }

    return buffer.buffer.asUint8List();
  }

  @override
  List<InputImagePlaneMetadata> getPlaneMetaData() {
    final List<InputImagePlaneMetadata> planeData = <InputImagePlaneMetadata>[];
    for (final Plane plane in cameraImage.planes) {
      planeData.add(
        InputImagePlaneMetadata(
          bytesPerRow: (plane.bytesPerRow * _width) ~/ cameraImage.width,
          height: plane.height == null
              ? null
              : (plane.height! * _height) ~/ cameraImage.height,
          width: plane.width == null
              ? null
              : (plane.width! * _width) ~/ cameraImage.width,
        ),
      );
    }
    return planeData;
  }
}
