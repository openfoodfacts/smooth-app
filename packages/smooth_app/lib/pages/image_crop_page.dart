import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';

/// Returns the file path of an image after it's been cropped.
///
/// This is the "old" problematic version; to be rapidly changed.
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

/// Crops an image from an existing file.
Future<File?> startImageCroppingNoPick(
  final BuildContext context, {
  required final File existingImage,
}) async {
  final NavigatorState navigator = Navigator.of(context);
  await _showScreenBetween(navigator);

  // ignore: use_build_context_synchronously
  final String? croppedPath = await getCroppedPath(
    context,
    existingImage.path,
  );

  await _hideScreenBetween(navigator);

  if (croppedPath == null) {
    return null;
  }

  return File(croppedPath);
}

/// Picks an image file from gallery or camera.
Future<XFile?> pickImageFile(
  final BuildContext context, {
  final bool showOptionDialog = false,
  bool chooseFromGallery = false,
}) async {
  if (showOptionDialog) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool? dialogFromGallery = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        title: appLocalizations.choose_image_source_title,
        body: Text(appLocalizations.choose_image_source_body),
        positiveAction: SmoothActionButton(
          text: appLocalizations.settings_app_camera,
          onPressed: () async => Navigator.pop(context, false),
        ),
        negativeAction: SmoothActionButton(
          text: appLocalizations.gallery_source_label,
          onPressed: () async => Navigator.pop(context, true),
        ),
      ),
    );
    if (dialogFromGallery == null) {
      return null;
    }
    chooseFromGallery = dialogFromGallery;
  }
  final ImagePicker picker = ImagePicker();
  if (chooseFromGallery) {
    return picker.pickImage(source: ImageSource.gallery);
  }
  return picker.pickImage(source: ImageSource.camera);
}

/// Crops an image picked from the gallery or camera.
Future<File?> startImageCropping(
  BuildContext context, {
  bool showOptionDialog = false,
  bool chooseFromGallery = false,
}) async {
  // Show a loading page on the Flutter side
  final NavigatorState navigator = Navigator.of(context);
  await _showScreenBetween(navigator);

  // ignore: use_build_context_synchronously
  final XFile? pickedXFile = await pickImageFile(
    context,
    chooseFromGallery: chooseFromGallery,
    showOptionDialog: showOptionDialog,
  );
  if (pickedXFile == null) {
    await _hideScreenBetween(navigator);
    return null;
  }

  // ignore: use_build_context_synchronously
  final String? croppedPath = await getCroppedPath(
    context,
    pickedXFile.path,
  );

  await _hideScreenBetween(navigator);

  if (croppedPath == null) {
    return null;
  }

  return File(croppedPath);
}

Future<void> _showScreenBetween(NavigatorState navigator) {
  return ((NavigatorState navigator) async {
    navigator.push<dynamic>(
      MaterialPageRoute<dynamic>(
        settings: _LoadingPage._settings,
        builder: (_) => const _LoadingPage(),
      ),
    );
  }).call(navigator);
}

Future<void> _hideScreenBetween(NavigatorState navigator) async {
  return ((NavigatorState navigator) async {
    return navigator.pop((Route<dynamic> route) {
      // Remove the screen, only if it's the loading screen
      if (route.settings == _LoadingPage._settings) {
        return true;
      }
      return false;
    });
  }).call(navigator);
}

/// A screen being displayed once an image is taken, but the cropper is not yet
/// visible
class _LoadingPage extends StatelessWidget {
  const _LoadingPage({
    Key? key,
  }) : super(key: key);

  static const RouteSettings _settings = RouteSettings(name: 'loading_page');

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: ColoredBox(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      ),
    );
  }
}
