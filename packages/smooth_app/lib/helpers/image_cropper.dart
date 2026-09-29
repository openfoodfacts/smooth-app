import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as image;
import 'package:smooth_app/background/background_task_image.dart';
import 'package:smooth_app/pages/image_crop_page.dart';

/// Cropping an image file into another.
class ImageCropper {
  ImageCropper({
    required this.inputFile,
    required this.outputFile,
    required this.crop,
    required this.rotation,
    required this.overlayPainter,
  });

  final File inputFile;
  final File outputFile;
  final Rect crop;
  final CropRotation rotation;
  final CustomPainter? overlayPainter;

  /// Crops and saves in a BMP file.
  ///
  /// Returns the width and height of the cropped image.
  /// As BMP for much quicker results.
  ///
  /// Here we don't use isolates, as it's not compatible with `dart:ui`,
  /// cf. https://github.com/flutter/flutter/issues/115030#issuecomment-1314242954
  Future<(int, int)> saveCroppedBmp() async {
    ui.Image? cropped;
    try {
      cropped = await _getCroppedImage();

      final ByteData? rawData = await cropped.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (rawData == null) {
        throw Exception('Cannot convert file');
      }

      final int croppedWidth = cropped.width;
      final int croppedHeight = cropped.height;

      cropped.dispose();
      cropped = null;

      final image.Image rawImage = await _convertImageFromUI(
        rawData,
        croppedWidth,
        croppedHeight,
      );
      // TODO(monsieurtanuki): optim - here we generate the full data, then print it. Stream it instead?
      await outputFile.writeAsBytes(image.encodeBmp(rawImage), flush: true);
      return (croppedWidth, croppedHeight);
    } finally {
      cropped?.dispose();
    }
  }

  /// Crops and saves in a JPEG file.
  ///
  /// Returns the width and height of the cropped image.
  /// It's faster to encode as BMP and then compress to JPEG, instead of directly
  /// compressing the image to JPEG (standard flutter being slow).
  Future<(int, int)> saveCroppedJpeg() async {
    final File temporaryBmpFile = File('${outputFile.path}.tmp.bmp');

    Future<void> deleteTemporaryTmpFile() async {
      try {
        await temporaryBmpFile.delete();
      } catch (e) {
        // in case the file wasn't even created
      }
    }

    final (int, int) croppedSize;
    try {
      croppedSize = await ImageCropper(
        inputFile: inputFile,
        outputFile: temporaryBmpFile,
        crop: crop,
        rotation: rotation,
        overlayPainter: overlayPainter,
      ).saveCroppedBmp();
    } catch (e) {
      await deleteTemporaryTmpFile();
      rethrow;
    }

    try {
      // very fast: about 200ms!
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        temporaryBmpFile.path,
        outputFile.path,
        autoCorrectionAngle: false,
        quality: ImagePickerConstants.imageQuality,
        format: CompressFormat.jpeg,
        minWidth: croppedSize.$1,
        minHeight: croppedSize.$2,
      );
      if (result == null) {
        throw Exception('Unexpected null result for JPEG compression');
      }

      return croppedSize;
    } finally {
      await deleteTemporaryTmpFile();
    }
  }

  Future<ui.Image> _getCroppedImage() async {
    ui.Image? full;
    try {
      // TODO(monsieurtanuki): optim - we may even load a smaller image
      full = await BackgroundTaskImage.loadUiImage(
        await inputFile.readAsBytes(),
      );

      return await CropController.getCroppedBitmap(
        image: full,
        maxSize: ImagePickerConstants.maxSize,
        crop: crop,
        rotation: rotation,
        overlayPainter: overlayPainter,
      );
    } finally {
      full?.dispose();
    }
  }

  static Future<image.Image> _convertImageFromUI(
    final ByteData rawData,
    final int width,
    final int height,
  ) async => image.Image.fromBytes(
    width: width,
    height: height,
    bytes: rawData.buffer,
    format: image.Format.uint8,
    order: image.ChannelOrder.rgba,
    numChannels: 4,
  );
}
