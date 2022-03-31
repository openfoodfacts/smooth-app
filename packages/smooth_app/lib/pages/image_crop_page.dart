import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

Future<File?> startImageCropping(BuildContext context) async {
  final ColorScheme colorScheme = Theme.of(context).colorScheme;

  final ImagePicker picker = ImagePicker();
  final XFile? pickedXFile = await picker.pickImage(
    source: ImageSource.camera,
  );
  if (pickedXFile == null) {
    return null;
  }
  final File? croppedFile = await ImageCropper().cropImage(
    sourcePath: pickedXFile.path,
    aspectRatioPresets: <CropAspectRatioPreset>[
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9
    ],
    androidUiSettings: AndroidUiSettings(
      toolbarTitle: 'Edit Photo', // TODO(ashaan): Localize
      initAspectRatio: CropAspectRatioPreset.original,
      lockAspectRatio: false,
      // style the cropper UI with the current theme
    ),
    iosUiSettings: const IOSUiSettings(
      minimumAspectRatio: 1.0,
    ),
  );
  return croppedFile;
}
