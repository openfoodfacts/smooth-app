import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';

Future<File?> startImageCropping(BuildContext context,
    {File? existingImage}) async {
  final AppLocalizations appLocalizations = AppLocalizations.of(context);
  late XFile? pickedXFile;
  if (existingImage == null) {
    final ImagePicker picker = ImagePicker();
    // open a dialog to ask the user if they want to take a picture or select one from the gallery
    pickedXFile = await showDialog<XFile>(
      context: context,
      builder: (BuildContext context) {
        return SmoothAlertDialog(
          title: appLocalizations.choose_image_source_title,
          body: Text(appLocalizations.choose_image_source_body),
          positiveAction: SmoothActionButton(
            text: appLocalizations.settings_app_camera,
            onPressed: () async {
              final XFile? pickedFile = await picker.pickImage(
                source: ImageSource.camera,
              );
              // ignore: use_build_context_synchronously
              Navigator.pop(context, pickedFile);
            },
          ),
          negativeAction: SmoothActionButton(
            text: appLocalizations.gallery_source_label,
            onPressed: () async {
              final XFile? pickedFile = await picker.pickImage(
                source: ImageSource.gallery,
              );
              // ignore: use_build_context_synchronously
              Navigator.pop(context, pickedFile);
            },
          ),
        );
      },
    );
    if (pickedXFile == null) {
      return null;
    }
  }

  final CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: existingImage?.path ?? pickedXFile!.path,
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
        toolbarTitle: appLocalizations.product_edit_photo_title,
        // They all need to be the same for dark/light mode as we can't change
        // the background color and the action bar color
        statusBarColor: Colors.black,
        toolbarWidgetColor: Colors.black,
        backgroundColor: Colors.black,
        activeControlsWidgetColor: const Color(0xFF85746C),
      ),
      IOSUiSettings(
        minimumAspectRatio: 1.0,
      ),
    ],
  );
  //attempting to create a file from a null path will throw an exception so return null if that happens
  if (croppedFile == null) {
    return null;
  }
  return File(croppedFile.path);
}
