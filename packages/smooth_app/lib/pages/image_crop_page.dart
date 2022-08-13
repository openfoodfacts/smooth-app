import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';

Future<File?> startImageCropping(
  BuildContext context, {
  File? existingImage,
  bool showOptionDialog = false,
  bool chooseFromGallery = false,
  LoadingCallback? beforeScreenVisibleCallback,
  LoadingCallback? afterScreenVisibleCallback,
}) async {
  final AppLocalizations appLocalizations = AppLocalizations.of(context);
  late XFile? pickedXFile;

  // Show a loading page on the Flutter side
  final NavigatorState navigator = Navigator.of(context);
  await _showScreenBetween(beforeScreenVisibleCallback, navigator);

  if (existingImage == null) {
    final ImagePicker picker = ImagePicker();
    // open a dialog to ask the user if they want to take a picture or select one from the gallery
    if (showOptionDialog) {
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
    } else {
      if (chooseFromGallery) {
        pickedXFile = await picker.pickImage(
          source: ImageSource.gallery,
        );
      } else {
        pickedXFile = await picker.pickImage(
          source: ImageSource.camera,
        );
      }
    }

    if (pickedXFile == null) {
      await _hideScreenBetween(afterScreenVisibleCallback, navigator);
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
    ],
  );

  await _hideScreenBetween(afterScreenVisibleCallback, navigator);

  //attempting to create a file from a null path will throw an exception so return null if that happens
  if (croppedFile == null) {
    return null;
  }

  return File(croppedFile.path);
}

Future<void> _showScreenBetween(
  LoadingCallback? callback,
  NavigatorState navigator,
) {
  return (callback ??
          (NavigatorState navigator) async {
            navigator.push<dynamic>(
              MaterialPageRoute<dynamic>(
                settings: _LoadingPage._settings,
                builder: (_) => const _LoadingPage(),
              ),
            );
          })
      .call(navigator);
}

Future<void> _hideScreenBetween(
  LoadingCallback? callback,
  NavigatorState navigator,
) async {
  return (callback ??
          (NavigatorState navigator) async {
            return navigator.popUntil((Route<dynamic> route) {
              // Remove the screen, only if it's the loading screen
              if (route.settings == _LoadingPage._settings) {
                return true;
              }
              return false;
            });
          })
      .call(navigator);
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

typedef LoadingCallback = Future<void> Function(NavigatorState navigator);
