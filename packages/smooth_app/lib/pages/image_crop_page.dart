import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/pages/crop_helper.dart';

/// Crops an image from an existing file.
Future<File?> startImageCroppingNoPick(
  final BuildContext context, {
  required final File existingImage,
}) async {
  final NavigatorState navigator = Navigator.of(context);
  final CropHelper cropHelper = CropHelper.getCurrent(context);
  await _showScreenBetween(navigator);

  // ignore: use_build_context_synchronously
  final String? croppedPath = await cropHelper.getCroppedPath(
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
        actionsAxis: Axis.vertical,
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
  final CropHelper cropHelper = CropHelper.getCurrent(context);
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
  final String? croppedPath = await cropHelper.getCroppedPath(
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
