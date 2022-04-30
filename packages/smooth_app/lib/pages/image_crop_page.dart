import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_cropper_platform_interface/image_cropper_platform_interface.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';

Future<File?> startImageCropping(BuildContext context) async {
  final bool isDarktheme =
      Provider.of<ThemeProvider>(context, listen: false).isDarkMode(context);
  final Color? themeColor = isDarktheme
      ? Colors.black
      : Theme.of(context).appBarTheme.backgroundColor;
  final ImagePicker picker = ImagePicker();
  final XFile? pickedXFile = await picker.pickImage(
    source: ImageSource.camera,
  );
  if (pickedXFile == null) {
    return null;
  }

  final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

  final CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: pickedXFile.path,
    aspectRatioPresets: <CropAspectRatioPreset>[
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9
    ],
    uiSettings: <PlatformUiSettings>[
      AndroidUiSettings(
        toolbarTitle: appLocalizations.product_edit_photo_title,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
        statusBarColor: themeColor,
        toolbarColor: themeColor,
        toolbarWidgetColor: Colors.white,
        activeControlsWidgetColor: Theme.of(context).colorScheme.primary,
        backgroundColor: themeColor,
      ),
      IOSUiSettings(
        minimumAspectRatio: 1.0,
      ),
    ],
  );
  return File(croppedFile!.path);
}
