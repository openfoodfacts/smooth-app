import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/tmp_crop_image/new_crop_page.dart';

/// Picks an image file from gallery or camera.
Future<XFile?> pickImageFile(final State<StatefulWidget> widget) async {
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

/// Lets the user pick a picture, crop it, and save it.
Future<File?> confirmAndUploadNewPicture(
  final State<StatefulWidget> widget, {
  required final ImageField imageField,
  required final String barcode,
}) async {
  final XFile? croppedPhoto = await pickImageFile(widget);
  if (croppedPhoto == null) {
    return null;
  }
  if (!widget.mounted) {
    return null;
  }
  return Navigator.push<File>(
    widget.context,
    MaterialPageRoute<File>(
      builder: (BuildContext context) => CropPage(
        barcode: barcode,
        imageField: imageField,
        inputFile: File(croppedPhoto.path),
      ),
      fullscreenDialog: true,
    ),
  );
}
