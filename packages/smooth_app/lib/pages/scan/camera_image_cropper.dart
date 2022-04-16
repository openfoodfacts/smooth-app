import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_barcode_scanner/google_ml_barcode_scanner.dart';
import 'package:smooth_app/pages/scan/abstract_camera_image_getter.dart';
import 'package:typed_data/typed_buffers.dart';

/// Camera Image Cropper, in order to limit the barcode scan computations.
///
/// Note: on iOS, we can only crop the size, as the coordinates are hardcoded.
/// [width01] and [height01] are thus ignored on this platform.
///
/// Use CameraController with imageFormatGroup: ImageFormatGroup.yuv420
/// [left01], [top01], [width01] and [height01] are values between 0 and 1
/// that delimit the cropping area.
/// For instance:
/// * left01: 0, top01: 0, width01: 1, height01: .2 delimit the top 20% banner
/// * left01: .5, top01: .5, width01: .5, height01: ..5 the bottom right rect
abstract class CameraImageCropper extends AbstractCameraImageGetter {
  factory CameraImageCropper(
    final CameraImage cameraImage,
    final CameraDescription cameraDescription, {
    required double left01,
    required double top01,
    required double width01,
    required double height01,
  }) {
    if (Platform.isIOS) {
      return _CameraImageCropperImplIOS(
        cameraImage,
        cameraDescription,
        width01: width01,
        height01: height01,
      );
    } else {
      return _CameraImageCropperImplDefault(
        cameraImage,
        cameraDescription,
        left01: left01,
        top01: top01,
        width01: width01,
        height01: height01,
      );
    }
  }

  CameraImageCropper._(
    final CameraImage cameraImage,
    final CameraDescription cameraDescription, {
    required this.width01,
    required this.height01,
  })  : assert(width01 > 0 && width01 <= 1),
        assert(height01 > 0 && height01 <= 1),
        super(
          cameraImage,
          cameraDescription,
        ) {
    _computeCropParameters();
  }

  final double width01;
  final double height01;

  late int _width;
  late int _height;

  void _computeCropParameters() {
    if (orientation == 0) {
      _width = _computeWidth();
      _height = _computeHeight();
    } else if (orientation == 90) {
      _width = _computeWidth();
      _height = _computeHeight();
    } else {
      throw Exception('Orientation $orientation not dealt with for the moment');
    }
  }

  int _computeWidth() {
    if (orientation == 0) {
      return _getEven(fullWidth * width01);
    } else if (orientation == 90) {
      return _getEven(fullWidth * height01);
    }

    throw Exception('Orientation $orientation not dealt with for the moment');
  }

  int _computeHeight() {
    if (orientation == 0) {
      return _getEven(fullHeight * height01);
    } else if (orientation == 90) {
      return _getEven(fullHeight * width01);
    }

    throw Exception('Orientation $orientation not dealt with for the moment');
  }

  int _getEven(final double value) => 2 * (value ~/ 2);

  int get fullWidth => cameraImage.width;

  int get fullHeight => cameraImage.height;

  int get orientation => cameraDescription.sensorOrientation;

  @override
  Size getSize() => Size(
        _width.toDouble(),
        _height.toDouble(),
      );
}

class _CameraImageCropperImplDefault extends CameraImageCropper {
  _CameraImageCropperImplDefault(
    final CameraImage cameraImage,
    final CameraDescription cameraDescription, {
    required this.left01,
    required this.top01,
    required double width01,
    required double height01,
  }) : super._(
          cameraImage,
          cameraDescription,
          width01: width01,
          height01: height01,
        );

  final double left01;
  final double top01;
  late int _left;
  late int _top;

  @override
  void _computeCropParameters() {
    super._computeCropParameters();
    assert(left01 >= 0 && left01 < 1);
    assert(top01 >= 0 && top01 < 1);
    assert(left01 + width01 <= 1);
    assert(top01 + height01 <= 1);

    if (orientation == 0) {
      _left = _getEven(fullWidth * left01);
      _top = _getEven(fullHeight * top01);
    } else if (orientation == 90) {
      _left = _getEven(fullWidth * top01);
      _top = _getEven(fullHeight * left01);
    } else {
      throw Exception('Orientation $orientation not dealt with for the moment');
    }
  }

  // cf. https://en.wikipedia.org/wiki/YUV#Y′UV420p_(and_Y′V12_or_YV12)_to_RGB888_conversion
  static const Map<int, int> _planeDividers = <int, int>{
    0: 1, // Y
    1: 2, // U
    2: 2, // V
  };

  @override
  Size getSize() => Size(
        _width.toDouble(),
        _height.toDouble(),
      );

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

/// On iOS, coordinates are hardcoded in the native code (0, 0)
/// [https://github.com/danjodanjo/google_ml_barcode_scanner/blob/master/ios/Classes/MLKVisionImage%2BFlutterPlugin.m#L136]
///
/// The only crop we can do is to shrink the width and/or the height
class _CameraImageCropperImplIOS extends CameraImageCropper {
  _CameraImageCropperImplIOS(
    final CameraImage cameraImage,
    final CameraDescription cameraDescription, {
    required double width01,
    required double height01,
  })  : assert(width01 > 0 && width01 <= 1),
        assert(height01 > 0 && height01 <= 1),
        super._(
          cameraImage,
          cameraDescription,
          width01: width01,
          height01: height01,
        );

  // Same implementation as [CameraImageFullGetter]
  @override
  Uint8List getBytes() {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  // Same implementation as [CameraImageFullGetter]
  @override
  List<InputImagePlaneMetadata> getPlaneMetaData() {
    final List<InputImagePlaneMetadata> planeData = <InputImagePlaneMetadata>[];
    for (final Plane plane in cameraImage.planes) {
      planeData.add(
        InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        ),
      );
    }
    return planeData;
  }
}
