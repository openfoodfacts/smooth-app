import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:scanner_mlkit/src/utils/abstract_camera_image_getter.dart';
import 'package:scanner_shared/scanner_shared.dart';

/// Camera Image helper where we get the full image.
///
/// Use CameraController with imageFormatGroup: ImageFormatGroup.yuv420
class CameraImageFullGetter extends AbstractCameraImageGetter {
  CameraImageFullGetter(
    super.cameraImage,
    super.cameraDescription,
  );

  @override
  Size getSize() => Size(
        cameraImage.width.toDouble(),
        cameraImage.height.toDouble(),
      );

  @override
  Uint8List getBytes() {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

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
