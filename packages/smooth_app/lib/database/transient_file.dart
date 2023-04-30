import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
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
    final OpenFoodFactsLanguage language,
    final LocalDatabase localDatabase,
    final File file,
  ) {
    _transientFiles[_getImageKey(
      imageField,
      barcode,
      language,
    )] = file.path;
    localDatabase.notifyListeners();
  }

  /// Removes the current transient image for [imageField] and [barcode].
  static void removeImage(
    final ImageField imageField,
    final String barcode,
    final OpenFoodFactsLanguage language,
    final LocalDatabase localDatabase,
  ) =>
      _transientFiles.remove(_getImageKey(
        imageField,
        barcode,
        language,
      ));

  /// Returns the transient image for [imageField] and [barcode].
  static File? getImage(
    final ImageField imageField,
    final String barcode,
    final OpenFoodFactsLanguage language,
  ) {
    final String? path = _transientFiles[_getImageKey(
      imageField,
      barcode,
      language,
    )];
    if (path == null) {
      return null;
    }
    return File(path);
  }

  /// Returns the key of the transient image.
  static String _getImageKey(
    final ImageField imageField,
    final String barcode,
    final OpenFoodFactsLanguage language,
  ) =>
      '${_getImageKeyPrefix(imageField, barcode)}${language.code}';

  /// Returns the key prefix of the transient image (without language).
  static String _getImageKeyPrefix(
    final ImageField imageField,
    final String barcode,
  ) =>
      '$barcode;$imageField;';

  /// Returns a way to display the image, either locally or from the server.
  static ImageProvider? getImageProvider(
    final ProductImageData imageData,
    final String barcode,
    final OpenFoodFactsLanguage language,
  ) {
    final File? file = getImage(imageData.imageField, barcode, language);
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
    final OpenFoodFactsLanguage language,
  ) =>
      getImage(imageData.imageField, barcode, language) != null ||
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
    final OpenFoodFactsLanguage language,
  ) =>
      getImage(imageData.imageField, barcode, language) == null &&
      imageData.imageUrl != null;

  /// Returns the languages that have currently transient images.
  static Iterable<OpenFoodFactsLanguage> getImageLanguages(
    final ImageField imageField,
    final String barcode,
  ) {
    final Set<OpenFoodFactsLanguage> result = <OpenFoodFactsLanguage>{};
    final String prefix = _getImageKeyPrefix(imageField, barcode);
    final int prefixLength = prefix.length;
    for (final String key in _transientFiles.keys) {
      if (key.length <= prefixLength) {
        continue;
      }
      if (!key.startsWith(prefix)) {
        continue;
      }
      final String lc = key.substring(prefixLength);
      final OpenFoodFactsLanguage language = LanguageHelper.fromJson(lc);
      if (language != OpenFoodFactsLanguage.UNDEFINED) {
        result.add(language);
      }
    }
    return result;
  }
}
