import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_barcode.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';

/// Abstract background task about generic file upload.
abstract class BackgroundTaskUpload extends BackgroundTaskBarcode {
  const BackgroundTaskUpload({
    required super.processName,
    required super.uniqueId,
    required super.barcode,
    required super.languageCode,
    required super.user,
    required super.country,
    required super.stamp,
    required this.imageField,
    required this.croppedPath,
    required this.rotationDegrees,
    required this.cropX1,
    required this.cropY1,
    required this.cropX2,
    required this.cropY2,
  });

  BackgroundTaskUpload.fromJson(Map<String, dynamic> json)
      : imageField = json['imageField'] as String,
        croppedPath = json['croppedPath'] as String,
        rotationDegrees = json['rotation'] as int? ?? 0,
        cropX1 = json['x1'] as int? ?? 0,
        cropY1 = json['y1'] as int? ?? 0,
        cropX2 = json['x2'] as int? ?? 0,
        cropY2 = json['y2'] as int? ?? 0,
        super.fromJson(json);

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

  TransientFile _getTransientFile() => TransientFile(
        ImageField.fromOffTag(imageField)!,
        barcode,
        getLanguage(),
      );

  @protected
  void putTransientImage(final LocalDatabase localDatabase) =>
      _getTransientFile().putImage(
        localDatabase,
        File(croppedPath),
      );

  @protected
  void removeTransientImage(final LocalDatabase localDatabase) =>
      _getTransientFile().removeImage(localDatabase);

  File? _getTransientImage() => _getTransientFile().getImage();

  @override
  Future<void> recover(final LocalDatabase localDatabase) async {
    final File? transientFile = _getTransientImage();
    if (transientFile == null) {
      putTransientImage(localDatabase);
    }
  }

  static String getStamp(
    final String barcode,
    final String imageField,
    final String language,
  ) =>
      '$barcode;image;$imageField;$language';
}
