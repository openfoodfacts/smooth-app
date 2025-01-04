import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as image;

/// Container for Image Compute and Compress operations.
class _ImageComputeContainer {
  _ImageComputeContainer({
    required this.file,
    required this.rawData,
    required this.width,
    required this.height,
    required this.quality,
  }) : rootIsolateToken = ui.RootIsolateToken.instance;

  final File file;
  final ByteData rawData;
  final int width;
  final int height;
  final int quality;
  final ui.RootIsolateToken? rootIsolateToken;

  bool get isIsolatePossible => rootIsolateToken != null;

  void ensureIsolate() {
    if (rootIsolateToken != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken!);
    }
  }
}

/// Saves an image to a BMP file. As BMP for better performances.
Future<void> saveBmp({
  required final File file,
  required final ui.Image source,
}) async {
  final ByteData? rawData = await source.toByteData(
    format: ui.ImageByteFormat.rawRgba,
  );
  if (rawData == null) {
    throw Exception('Cannot convert file');
  }
  final _ImageComputeContainer container = _ImageComputeContainer(
    file: file,
    rawData: rawData,
    width: source.width,
    height: source.height,
    // whatever, we don't use it for bmp
    quality: 100,
  );
  if (container.isIsolatePossible) {
    try {
      // with an isolate if possible
      await compute(_saveBmp, container);
    } catch (e) {
      // fallback version: async (cf. https://github.com/openfoodfacts/smooth-app/issues/4304)
      await _saveBmp(container, withIsolate: false);
    }
    return;
  }
  await _saveBmp(container, withIsolate: false);
}

/// Saves an image to a JPEG file.
///
/// It's faster to encode as BMP and then compress to JPEG, instead of directly
/// compressing the image to JPEG (standard flutter being slow).
Future<void> saveJpeg({
  required final File file,
  required final ui.Image source,
  required final int quality,
}) async {
  final ByteData? rawData = await source.toByteData(
    format: ui.ImageByteFormat.rawRgba,
  );
  if (rawData == null) {
    throw Exception('Cannot convert file');
  }
  final _ImageComputeContainer container = _ImageComputeContainer(
    file: file,
    rawData: rawData,
    width: source.width,
    height: source.height,
    quality: quality,
  );
  if (container.isIsolatePossible) {
    try {
      // with an isolate if possible
      await compute(_saveJpeg, container);
    } catch (e) {
      // fallback version: async (cf. https://github.com/openfoodfacts/smooth-app/issues/4304)
      await _saveJpeg(container, withIsolate: false);
    }
    return;
  }
  await _saveJpeg(container, withIsolate: false);
}

Future<image.Image> _convertImageFromUI(
  final ByteData rawData,
  final int width,
  final int height,
) async =>
    image.Image.fromBytes(
      width: width,
      height: height,
      bytes: rawData.buffer,
      format: image.Format.uint8,
      order: image.ChannelOrder.rgba,
    );

/// Saves an image to a BMP file. As BMP for better performances.
Future<void> _saveBmp(
  final _ImageComputeContainer container, {
  final bool withIsolate = true,
}) async {
  if (withIsolate) {
    container.ensureIsolate();
  }
  final image.Image rawImage = await _convertImageFromUI(
    container.rawData,
    container.width,
    container.height,
  );
  await container.file.writeAsBytes(
    image.encodeBmp(rawImage),
    flush: true,
  );
}

/// Saves an image to a JPEG file.
///
/// It's faster to encode as BMP and then compress to JPEG, instead of directly
/// compressing the image to JPEG (standard flutter being slow).
Future<void> _saveJpeg(
  final _ImageComputeContainer container, {
  final bool withIsolate = true,
}) async {
  if (withIsolate) {
    container.ensureIsolate();
  }
  image.Image? rawImage = await _convertImageFromUI(
    container.rawData,
    container.width,
    container.height,
  );
  Uint8List? bmpData = Uint8List.fromList(image.encodeBmp(rawImage));
  // gc?
  rawImage = null;
  final Uint8List jpegData = await FlutterImageCompress.compressWithList(
    bmpData,
    autoCorrectionAngle: false,
    quality: container.quality,
    format: CompressFormat.jpeg,
    minWidth: container.width,
    minHeight: container.height,
  );
  // gc?
  bmpData = null;
  await container.file.writeAsBytes(jpegData, flush: true);
}
