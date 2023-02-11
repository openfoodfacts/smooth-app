import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/helpers/database_helper.dart';
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
        inputFile: File('Screenshot(250).jpeg'),
        initiallyDifferent: true,
      ),
      fullscreenDialog: true,
    ),
  );
}

/// Downloads an image URL into a file, with a dialog.
Future<File?> downloadImageUrl(
  final BuildContext context,
  final String? imageUrl,
  final DaoInt daoInt,
) async {
  final AppLocalizations appLocalizations = AppLocalizations.of(context);
  if (imageUrl == null) {
    await LoadingDialog.error(
      context: context,
      title: appLocalizations.image_edit_url_error,
    );
    return null;
  }

  final File? imageFile = await LoadingDialog.run<File?>(
    context: context,
    future: _downloadImageFile(daoInt, imageUrl),
  );

  if (imageFile == null) {
    // ignore: use_build_context_synchronously
    await LoadingDialog.error(
      context: context,
      title: appLocalizations.image_download_error,
    );
  }
  return imageFile;
}

/// Downloads an image from the server and stores it locally in temp folder.
Future<File?> _downloadImageFile(DaoInt daoInt, String url) async {
  final Uri uri = Uri.parse(url);
  final http.Response response = await http.get(uri);
  final int code = response.statusCode;
  if (code != 200) {
    throw NetworkImageLoadException(statusCode: code, uri: uri);
  }

  final Directory tempDirectory = await getTemporaryDirectory();

  const String CROP_IMAGE_SEQUENCE_KEY = 'crop_image_sequence';

  final int sequenceNumber =
      await getNextSequenceNumber(daoInt, CROP_IMAGE_SEQUENCE_KEY);

  final File file = File('${tempDirectory.path}/editing_image_$sequenceNumber');

  return file.writeAsBytes(response.bodyBytes);
}
