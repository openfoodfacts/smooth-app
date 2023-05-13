import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
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
