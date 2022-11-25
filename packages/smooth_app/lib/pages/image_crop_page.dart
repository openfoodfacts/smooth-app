import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/pages/crop_helper.dart';
import 'package:smooth_app/pages/product/confirm_and_upload_picture.dart';

/// Picks an image file from gallery or camera.
Future<XFile?> _pickImageFile(final State<StatefulWidget> widget) async {
  final UserPictureSource? source = await _getUserPictureSource(widget.context);
  if (source == null) {
    return null;
  }
  final ImagePicker picker = ImagePicker();
  if (source == UserPictureSource.GALLERY) {
    return picker.pickImage(source: ImageSource.gallery);
  }
  return picker.pickImage(source: ImageSource.camera);
}

/// Returns the picture source selected by the user.
Future<UserPictureSource?> _getUserPictureSource(
  final BuildContext context,
) async {
  if (!CameraHelper.hasACamera) {
    return UserPictureSource.GALLERY;
  }
  final UserPreferences userPreferences = context.read<UserPreferences>();
  final UserPictureSource source = userPreferences.userPictureSource;
  if (source != UserPictureSource.SELECT) {
    return source;
  }
  final AppLocalizations appLocalizations = AppLocalizations.of(context);
  bool? remember = false;
  return showDialog<UserPictureSource>(
    context: context,
    builder: (BuildContext context) => StatefulBuilder(
      builder: (
        final BuildContext context,
        final void Function(VoidCallback fn) setState,
      ) =>
          SmoothAlertDialog(
        title: appLocalizations.choose_image_source_title,
        actionsAxis: Axis.vertical,
        body: CheckboxListTile(
          value: remember,
          onChanged: (final bool? value) => setState(
            () => remember = value,
          ),
          title: Text(appLocalizations.user_picture_source_remember),
        ),
        positiveAction: SmoothActionButton(
          text: appLocalizations.settings_app_camera,
          onPressed: () {
            const UserPictureSource result = UserPictureSource.CAMERA;
            if (remember == true) {
              userPreferences.setUserPictureSource(result);
            }
            Navigator.pop(context, result);
          },
        ),
        negativeAction: SmoothActionButton(
          text: appLocalizations.gallery_source_label,
          onPressed: () {
            const UserPictureSource result = UserPictureSource.GALLERY;
            if (remember == true) {
              userPreferences.setUserPictureSource(result);
            }
            Navigator.pop(context, result);
          },
        ),
      ),
    ),
  );
}

Future<File?> confirmAndUploadNewPicture(
  final State<StatefulWidget> widget, {
  required final ImageField imageField,
  required final String barcode,
}) async {
  final File? croppedPhoto = await startNewImageCropping(widget);
  if (croppedPhoto == null) {
    return null;
  }
  if (!widget.mounted) {
    return null;
  }
  return Navigator.push<File>(
    widget.context,
    MaterialPageRoute<File>(
      builder: (BuildContext context) => ConfirmAndUploadPicture(
        barcode: barcode,
        imageField: imageField,
        initialPhoto: croppedPhoto,
      ),
    ),
  );
}

/// Crops an image picked from the gallery or camera.
Future<File?> startNewImageCropping(
  final State<StatefulWidget> widget,
) async =>
    _startImageCropping(widget);

/// Crops an existing image.
Future<File?> startExistingImageCropping(
  final State<StatefulWidget> widget,
  final File? existingImage,
) async =>
    _startImageCropping(widget, existingImage: existingImage);

/// Crops an image, either existing or picked from the gallery or camera.
Future<File?> _startImageCropping(
  final State<StatefulWidget> widget, {
  final File? existingImage,
}) async {
  // Show a loading page on the Flutter side
  final NavigatorState navigator = Navigator.of(widget.context);
  final CropHelper cropHelper = CropHelper.getCurrent(widget.context);
  await _showScreenBetween(navigator);

  if (!widget.mounted) {
    return null;
  }
  final String sourceImagePath;
  if (existingImage != null) {
    sourceImagePath = existingImage.path;
  } else {
    final XFile? pickedXFile = await _pickImageFile(widget);
    if (pickedXFile == null) {
      await _hideScreenBetween(navigator);
      return null;
    }
    sourceImagePath = pickedXFile.path;
  }

  if (!widget.mounted) {
    return null;
  }
  final String? croppedPath = await cropHelper.getCroppedPath(
    widget.context,
    sourceImagePath,
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
