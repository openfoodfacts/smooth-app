import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';

/// Transient Files, for an immediate local access before actual upload.
class TransientFile {
  TransientFile(
    this.imageField,
    this.barcode,
    this.language, [
    this.uploadedDate,
  ]) : url = null;

  TransientFile.fromProductImageData(
    final ProductImageData productImageData,
    this.barcode,
    this.language, [
    this.uploadedDate,
  ]) : imageField = productImageData.imageField,
       url = productImageData.imageUrl;

  factory TransientFile.fromProduct(
    final Product product,
    final ImageField imageField,
    final OpenFoodFactsLanguage language,
  ) {
    final ProductImageData productImageData = getProductImageData(
      product,
      imageField,
      language,
    );

    return TransientFile.fromProductImageData(
      productImageData,
      product.barcode!,
      language,
      product
          .getRawImages()
          ?.firstWhereOrNull(
            (final ProductImage productImage) =>
                productImage.imgid == productImageData.imageId,
          )
          ?.uploaded,
    );
  }

  final ImageField imageField;
  final String barcode;
  final OpenFoodFactsLanguage language;
  final String? url;
  final DateTime? uploadedDate;

  /// {File "key": file path} map.
  static final Map<String, String> _transientFiles = <String, String>{};

  /// Stores locally [file] as a transient image for [imageField] and [barcode].
  void putImage(final LocalDatabase localDatabase, final File file) {
    _transientFiles[_getImageKey()] = file.path;
    localDatabase.notifyListeners();
  }

  /// Removes the current transient image for [imageField] and [barcode].
  void removeImage(final LocalDatabase localDatabase) {
    _transientFiles.remove(_getImageKey());
    localDatabase.notifyListeners();
  }

  /// Returns the [File] stored locally.
  File? getImage() {
    final String? path = _transientFiles[_getImageKey()];
    if (path == null) {
      return null;
    }
    return File(path);
  }

  /// Returns the key of the transient image.
  String _getImageKey() =>
      '${_getImageKeyPrefix(imageField, barcode)}${language.code}';

  /// Returns the key prefix of the transient image (without language).
  static String _getImageKeyPrefix(
    final ImageField imageField,
    final String barcode,
  ) => '$barcode;$imageField;';

  /// Returns a way to display the image, either locally or from the server.
  ImageProvider? getImageProvider() {
    final File? file = getImage();
    if (file != null) {
      return FileImage(file);
    }
    if (url != null) {
      if (imageField == ImageField.FRONT) {
        return CachedNetworkImageProvider(url!);
      }
      return NetworkImage(url!);
    }

    return null;
  }

  /// Returns true if an image is available, locally or on the server.
  ///
  /// That's the same as [getImageProvider] `!= null`, without its possible
  /// side-effects.
  bool isImageAvailable() => getImage() != null || url != null;

  /// Returns true if the displayed image comes from the server.
  ///
  /// Typical use-case: for OCR methods.
  /// In those cases we don't provide an image parameter, we just ask the
  /// server: "Use the packaging image you have and run the OCR on it!"
  /// That means that it's important to know what we are displaying on the app:
  /// if it's a local image, when we run the OCR we run it on another image -
  /// the one stored on the server. Which makes no sense.
  bool isServerImage() => getImage() == null && url != null;

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
