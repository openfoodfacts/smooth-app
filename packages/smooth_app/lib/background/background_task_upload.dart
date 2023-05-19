import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/abstract_background_task.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';

/// Background task about generic file upload.
abstract class BackgroundTaskUpload extends AbstractBackgroundTask {
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

  final String imageField;
  final String croppedPath;
  final int rotationDegrees;
  final int cropX1;
  final int cropY1;
  final int cropX2;
  final int cropY2;

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
