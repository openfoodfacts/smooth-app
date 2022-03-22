import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_barcode_scanner/google_ml_barcode_scanner.dart';

/// Abstract getter of Camera Image, for barcode scan.
///
/// Use CameraController with imageFormatGroup: ImageFormatGroup.yuv420
abstract class AbstractCameraImageGetter {
  AbstractCameraImageGetter(this.cameraImage, this.cameraDescription);

  final CameraImage cameraImage;
  final CameraDescription cameraDescription;

  InputImage getInputImage() {
    final InputImageRotation imageRotation =
        InputImageRotationMethods.fromRawValue(
                cameraDescription.sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final InputImageFormat inputImageFormat =
        InputImageFormatMethods.fromRawValue(
      int.parse(cameraImage.format.raw.toString()),
    )!;

    final List<InputImagePlaneMetadata> planeData = getPlaneMetaData();

    final InputImageData inputImageData = InputImageData(
      size: getSize(),
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    return InputImage.fromBytes(
      bytes: getBytes(),
      inputImageData: inputImageData,
    );
  }

  @protected
  Size getSize();

  @protected
  Uint8List getBytes();

  @protected
  List<InputImagePlaneMetadata> getPlaneMetaData();
}
