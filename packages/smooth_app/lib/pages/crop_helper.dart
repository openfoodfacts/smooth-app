import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/tmp_crop_image/new_crop_page.dart';

/// Crop Helper - which crop tool do we use, and the method to use it.
abstract class CropHelper {
  /// Returns the crop tool selected in the dev mode preferences.
  static CropHelper getCurrent(final BuildContext context) => context
              .read<UserPreferences>()
              .getFlag(UserPreferencesDevMode.userPreferencesFlagNewCropTool) ??
          false
      ? _NewCropHelper()
      : _OldCropHelper();

  /// Returns the path of the image file after the crop operation.
  Future<String?> getCroppedPath(
    final BuildContext context,
    final String inputPath,
  );
}

/// New version of the image cropper.
class _NewCropHelper extends CropHelper {
  @override
  Future<String?> getCroppedPath(
    final BuildContext context,
    final String inputPath,
  ) async =>
      Navigator.push<String>(
        context,
        MaterialPageRoute<String>(
          builder: (BuildContext context) => CropPage(File(inputPath)),
          fullscreenDialog: true,
        ),
      );
}

/// Image cropper based on image_cropper. To be forgotten.
class _OldCropHelper extends CropHelper {
  @override
  Future<String?> getCroppedPath(
    final BuildContext context,
    final String inputPath,
  ) async =>
      (await ImageCropper().cropImage(
        sourcePath: inputPath,
        aspectRatioPresets: <CropAspectRatioPreset>[
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: <PlatformUiSettings>[
          AndroidUiSettings(
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            toolbarTitle: AppLocalizations.of(context).product_edit_photo_title,
            // They all need to be the same for dark/light mode as we can't change
            // the background color and the action bar color
            statusBarColor: Colors.black,
            toolbarWidgetColor: Colors.black,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: const Color(0xFF85746C),
          ),
        ],
      ))
          ?.path;
}
