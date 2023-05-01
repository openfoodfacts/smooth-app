import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as image;

// TODO(monsieurtanuki): try to use simple isolates with `compute`
/// Container for Image Compute and Compress operations.
class ImageComputeContainer {
  const ImageComputeContainer({
    required this.file,
    required this.source,
  });

  final File file;
  final ui.Image source;
  //final image.Image rawImage;

  Future<image.Image> _convertImageFromUI() async {
    final ByteData? rawData = await source.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    if (rawData == null) {
      throw Exception('Cannot convert file');
    }
    // TODO(monsieurtanuki): perhaps a bit slow, which would call for a isolate/compute
    return image.Image.fromBytes(
      width: source.width,
      height: source.height,
      bytes: rawData.buffer,
      format: image.Format.uint8,
      order: image.ChannelOrder.rgba,
    );
  }

  /// Saves an image to a BMP file. As BMP for better performances.
  Future<void> saveBmp() async {
    final image.Image rawImage = await _convertImageFromUI();
    await file.writeAsBytes(
      image.encodeBmp(rawImage),
      flush: true,
    );
  }

  /// Saves an image to a JPEG file.
  ///
  /// It's faster to encode as BMP and then compress to JPEG, instead of directly
  /// compressing the image to JPEG (standard flutter being slow).
  Future<void> saveJpeg() async {
    final image.Image rawImage = await _convertImageFromUI();
    final Uint8List bmpData = Uint8List.fromList(image.encodeBmp(rawImage));
    final Uint8List jpegData = await FlutterImageCompress.compressWithList(
      bmpData,
      autoCorrectionAngle: false,
      quality: 100,
      format: CompressFormat.jpeg,
      minWidth: rawImage.width,
      minHeight: rawImage.height,
    );
    await file.writeAsBytes(jpegData, flush: true);
  }
}

/// Returns the bitmap cropped with parameters.
///
/// [maxSize] is the maximum width or height you want.
/// The [crop] `Rect` is normalized to (0, 0) x (1, 1).
/// You can provide the [quality] used in the resizing operation.
Future<ui.Image> getCroppedBitmap({
// TODO(monsieurtanuki): make it public in crop_image
  final double? maxSize,
  final ui.FilterQuality quality = FilterQuality.high,
  required final Rect crop,
  required final CropRotation rotation,
  required final ui.Image image,
}) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);

  final bool tilted = rotation.isSideways;
  final double cropWidth;
  final double cropHeight;
  if (tilted) {
    cropWidth = crop.width * image.height;
    cropHeight = crop.height * image.width;
  } else {
    cropWidth = crop.width * image.width;
    cropHeight = crop.height * image.height;
  }
// factor between the full size and the maxSize constraint.
  double factor = 1;
  if (maxSize != null) {
    if (cropWidth > maxSize || cropHeight > maxSize) {
      if (cropWidth >= cropHeight) {
        factor = maxSize / cropWidth;
      } else {
        factor = maxSize / cropHeight;
      }
    }
  }

  final Offset cropCenter = rotation.getRotatedOffset(
    crop.center,
    image.width.toDouble(),
    image.height.toDouble(),
  );

  final double alternateWidth = tilted ? cropHeight : cropWidth;
  final double alternateHeight = tilted ? cropWidth : cropHeight;
  if (rotation != CropRotation.up) {
    canvas.save();
    final double x = alternateWidth / 2 * factor;
    final double y = alternateHeight / 2 * factor;
    canvas.translate(x, y);
    canvas.rotate(rotation.radians);
    if (rotation == CropRotation.right) {
      canvas.translate(
        -y,
        -cropWidth * factor + x,
      );
    } else if (rotation == CropRotation.left) {
      canvas.translate(
        y - cropHeight * factor,
        -x,
      );
    } else if (rotation == CropRotation.down) {
      canvas.translate(-x, -y);
    }
  }

  canvas.drawImageRect(
    image,
    Rect.fromCenter(
      center: cropCenter,
      width: alternateWidth,
      height: alternateHeight,
    ),
    Rect.fromLTWH(
      0,
      0,
      alternateWidth * factor,
      alternateHeight * factor,
    ),
    Paint()..filterQuality = quality,
  );

  if (rotation != CropRotation.up) {
    canvas.restore();
  }

//FIXME Picture.toImage() crashes on Flutter Web with the HTML renderer. Use CanvasKit or avoid this operation for now. https://github.com/flutter/engine/pull/20750
  return pictureRecorder
      .endRecording()
      .toImage((cropWidth * factor).round(), (cropHeight * factor).round());
}
