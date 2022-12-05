import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smooth_app/tmp_crop_image/new_crop_page.dart';

/// New version of the image cropper.
class NewCropHelper {
  /// Returns the path of the image file after the crop operation.
  Future<String?> getCroppedPath(
    final BuildContext context,
    final String inputPath, {
    final String? pageTitle,
  }) async =>
      Navigator.push<String>(
        context,
        MaterialPageRoute<String>(
          builder: (BuildContext context) => CropPage(
            File(inputPath),
            title: pageTitle,
          ),
          fullscreenDialog: true,
        ),
      );
}
