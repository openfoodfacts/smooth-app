import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smooth_app/background/background_task_barcode.dart';
import 'package:smooth_app/background/background_task_product_change.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';

/// Abstract background task about generic file upload.
abstract class BackgroundTaskUpload extends BackgroundTaskBarcode
    implements BackgroundTaskProductChange {
  BackgroundTaskUpload({
    required super.processName,
    required super.uniqueId,
    required super.barcode,
    required super.productType,
    required super.language,
    required super.stamp,
    required this.imageField,
    required this.croppedPath,
    required this.rotationDegrees,
    required this.cropX1,
    required this.cropY1,
    required this.cropX2,
    required this.cropY2,
  });

  BackgroundTaskUpload.fromJson(super.json)
    : imageField = json[_jsonTagImageField] as String,
      croppedPath = json[_jsonTagCroppedPath] as String,
      rotationDegrees = json[_jsonTagRotation] as int? ?? 0,
      cropX1 = json[_jsonTagX1] as int? ?? 0,
      cropY1 = json[_jsonTagY1] as int? ?? 0,
      cropX2 = json[_jsonTagX2] as int? ?? 0,
      cropY2 = json[_jsonTagY2] as int? ?? 0,
      super.fromJson();

  final String imageField;
  final String croppedPath;
  final int rotationDegrees;
  final int cropX1;
  final int cropY1;
  final int cropX2;
  final int cropY2;

  static const String _jsonTagImageField = 'imageField';
  static const String _jsonTagCroppedPath = 'croppedPath';
  static const String _jsonTagRotation = 'rotation';
  static const String _jsonTagX1 = 'x1';
  static const String _jsonTagY1 = 'y1';
  static const String _jsonTagX2 = 'x2';
  static const String _jsonTagY2 = 'y2';

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = super.toJson();
    result[_jsonTagImageField] = imageField;
    result[_jsonTagCroppedPath] = croppedPath;
    result[_jsonTagRotation] = rotationDegrees;
    result[_jsonTagX1] = cropX1;
    result[_jsonTagY1] = cropY1;
    result[_jsonTagX2] = cropX2;
    result[_jsonTagY2] = cropY2;
    return result;
  }

  TransientFile _getTransientFile() =>
      TransientFile(ImageField.fromOffTag(imageField)!, barcode, getLanguage());

  @protected
  Future<void> putTransientImage(final LocalDatabase localDatabase) async =>
      _getTransientFile().putImage(localDatabase, await getFile(croppedPath));

  @protected
  void removeTransientImage(final LocalDatabase localDatabase) =>
      _getTransientFile().removeImage(localDatabase);

  File? _getTransientImage() => _getTransientFile().getImage();

  @override
  Future<void> recover(final LocalDatabase localDatabase) async {
    final File? transientFile = _getTransientImage();
    if (transientFile == null) {
      await putTransientImage(localDatabase);
    }
  }

  static String getStamp(
    final String barcode,
    final String imageField,
    final String language,
  ) => '$barcode;image;$imageField;$language';

  static Future<Directory> getDirectory() async =>
      getApplicationSupportDirectory();

  /// Returns a "safe" [File] from a given [path].
  ///
  /// iOS sometimes changes the path of its standard app folders, like the one
  /// we use in [getDirectory].
  /// With this method we refresh the path for iOS.
  /// cf. https://github.com/openfoodfacts/smooth-app/issues/4725
  static Future<File> getFile(String path) async {
    if (Platform.isIOS) {
      final int lastSeparator = path.lastIndexOf('/');
      final String filename = lastSeparator == -1
          ? path
          : path.substring(lastSeparator + 1);
      final Directory directory = await getDirectory();
      path = '${directory.path}/$filename';
    }
    return File(path);
  }

  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async {
    await localDatabase.upToDate.addChange(uniqueId, getProductChange());
    await putTransientImage(localDatabase);
  }

  @override
  Product getProductChange() => Product(
    barcode: barcode,
    images: <ProductImage>[getProductImageChange()],
  );

  /// Changed [ProductImage] for this product change.
  ///
  /// cf. [UpToDateChanges._overwrite] regarding `images` field.
  ProductImage getProductImageChange();

  /// Returns true only if it's not a "image/OTHER" task.
  ///
  /// That's important because "image/OTHER" task are never duplicates.
  @override
  bool isDeduplicable() =>
      !stamp.contains(';image;${ImageField.OTHER.offTag};');
}
