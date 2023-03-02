import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart';

// TODO(monsieurtanuki): try to use simple isolates with `compute`
/// Container for Image Compute and Compress operations.
class ImageComputeContainer {
  ImageComputeContainer({
    required this.file,
    required this.rawImage,
  });

  final File file;
  final Image rawImage;
}

/// Saves an image to a BMP file. As BMP for better performances.
Future<void> saveBmp(final ImageComputeContainer container) async =>
    container.file.writeAsBytes(encodeBmp(container.rawImage), flush: true);

/// Saves an image to a JPEG file.
///
/// It's faster to encode as BMP and then compress to JPEG, instead of directly
/// compressing the image to JPEG (standard flutter being slow).
Future<void> saveJpeg(final ImageComputeContainer container) async {
  final Uint8List bmpData = Uint8List.fromList(
    encodeBmp(container.rawImage),
  );
  final Uint8List jpegData = await FlutterImageCompress.compressWithList(
    bmpData,
    autoCorrectionAngle: false,
    quality: 100,
    format: CompressFormat.jpeg,
    minWidth: container.rawImage.width,
    minHeight: container.rawImage.height,
  );
  await container.file.writeAsBytes(jpegData, flush: true);
}
