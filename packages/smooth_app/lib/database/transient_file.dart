import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/ProductImage.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/database/local_database.dart';

/// Helper class about transient files (= not fully uploaded yet).
class TransientFile {
  TransientFile._();

  /// {File "key": file path} map.
  static final Map<String, String> _transientFiles = <String, String>{};

  /// Stores locally [file] as a transient image for [imageField] and [barcode].
  static void putImage(
    final ImageField imageField,
    final String barcode,
    final LocalDatabase localDatabase,
    final File file,
  ) {
    _transientFiles[_getImageKey(imageField, barcode)] = file.path;
    localDatabase.notifyListeners();
  }

  /// Removes the current transient image for [imageField] and [barcode].
  ///
  /// It will also delete the actual local file.
  static void removeImage(
    final ImageField imageField,
    final String barcode,
    final LocalDatabase localDatabase,
  ) {
    final String key = _getImageKey(imageField, barcode);
    final String? path = _transientFiles[key];
    if (path == null) {
      return;
    }
    _transientFiles.remove(key);
    File(path).deleteSync();
    localDatabase.notifyListeners();
  }

  /// Returns the transient image for [imageField] and [barcode].
  static File? getImage(
    final ImageField imageField,
    final String barcode,
  ) {
    final String? path = _transientFiles[_getImageKey(imageField, barcode)];
    if (path == null) {
      return null;
    }
    return File(path);
  }

  /// Returns the key of the transient image for [imageField] and [barcode].
  static String _getImageKey(
    final ImageField imageField,
    final String barcode,
  ) =>
      '$barcode;$imageField';

  /// Returns a way to display the image, either locally or from the server.
  static ImageProvider? getImageProvider(
    final ProductImageData imageData,
    final String barcode,
  ) {
    final File? file = getImage(imageData.imageField, barcode);
    if (file != null) {
      return FileImage(file);
    }
    if (imageData.imageUrl != null) {
      return NetworkImage(imageData.imageUrl!);
    }
    return null;
  }

  /// Returns true if an image is available, locally or on the server.
  ///
  /// That's the same as [getImageProvider] `!= null`, without its possible
  /// side-effects.
  static bool isImageAvailable(
    final ProductImageData imageData,
    final String barcode,
  ) =>
      getImage(imageData.imageField, barcode) != null ||
      imageData.imageUrl != null;

  /// Returns true if the displayed image comes from the server.
  ///
  /// Typical use-case: for OCR methods.
  /// In those cases we don't provide an image parameter, we just ask the
  /// server: "Use the packaging image you have and run the OCR on it!"
  /// That means that it's important to know what we are displaying on the app:
  /// if it's a local image, when we run the OCR we run it on another image -
  /// the one stored on the server. Which makes no sense.
  static bool isServerImage(
    final ProductImageData imageData,
    final String barcode,
  ) =>
      getImage(imageData.imageField, barcode) == null &&
      imageData.imageUrl != null;
}
