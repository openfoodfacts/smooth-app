import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/helpers/database_helper.dart';
import 'package:smooth_app/pages/crop_page.dart';

/// Picks an image file from gallery or camera.
Future<XFile?> pickImageFile(
  final State<StatefulWidget> widget, {
  bool ignorePlatformException = false,
}) async {
  final UserPictureSource? source = await _getUserPictureSource(widget.context);
  if (source == null) {
    return null;
  }
  final ImagePicker picker = ImagePicker();
  if (source == UserPictureSource.GALLERY) {
    try {
      return picker.pickImage(source: ImageSource.gallery);
    } on PlatformException catch (e) {
      // On debug builds this catch won't work.
      // Please run on profile/release modes to test it
      if (ignorePlatformException) {
        return null;
      } else if (e.code == 'photo_access_denied') {
        throw PhotoAccessDenied();
      } else {
        rethrow;
      }
    }
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

  return showSmoothModalSheet<UserPictureSource>(
      context: context,
      builder: (BuildContext context) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);

        return SmoothModalSheet(
          title: appLocalizations.choose_image_source_title,
          closeButton: true,
          closeButtonSemanticsOrder: 5.0,
          body: const _ImageSourcePicker(),
          bodyPadding: const EdgeInsetsDirectional.only(
            start: 10.0,
            end: MEDIUM_SPACE,
            top: LARGE_SPACE,
            bottom: MEDIUM_SPACE,
          ),
        );
      });
}

class _ImageSourcePicker extends StatefulWidget {
  const _ImageSourcePicker();

  @override
  State<_ImageSourcePicker> createState() => _ImageSourcePickerState();
}

class _ImageSourcePickerState extends State<_ImageSourcePicker> {
  bool rememberChoice = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Color primaryColor = Theme.of(context).primaryColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: _ImageSourceButton(
                    semanticsOrder: 2.0,
                    onPressed: () => _selectSource(UserPictureSource.CAMERA),
                    label: Text(
                      appLocalizations.settings_app_camera,
                      textAlign: TextAlign.center,
                    ),
                    icon: const Icon(Icons.camera_alt, size: 30.0),
                  ),
                ),
                const Spacer(),
                Expanded(
                  flex: 5,
                  child: _ImageSourceButton(
                    onPressed: () => _selectSource(UserPictureSource.GALLERY),
                    semanticsOrder: 3.0,
                    label: Text(
                      appLocalizations.gallery_source_label,
                      textAlign: TextAlign.center,
                    ),
                    icon: const Icon(Icons.image, size: 30.0),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: VERY_LARGE_SPACE),
        Semantics(
          sortKey: const OrdinalSortKey(4.0),
          value: appLocalizations.user_picture_source_remember,
          checked: rememberChoice,
          excludeSemantics: true,
          child: InkWell(
            onTap: () => setState(() => rememberChoice = !rememberChoice),
            borderRadius: ANGULAR_BORDER_RADIUS,
            splashColor: primaryColor.withOpacity(0.2),
            child: Row(
              children: <Widget>[
                IgnorePointer(
                  child: Checkbox.adaptive(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    ),
                    activeColor: Theme.of(context).primaryColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: rememberChoice,
                    onChanged: (final bool? value) => setState(
                      () => rememberChoice = value ?? false,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(appLocalizations.user_picture_source_remember),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _selectSource(UserPictureSource source) {
    if (rememberChoice == true) {
      context.read<UserPreferences>().setUserPictureSource(source);
    }
    Navigator.pop(context, source);
  }
}

class _ImageSourceButton extends StatelessWidget {
  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.semanticsOrder,
  });

  final Icon icon;
  final Widget label;
  final VoidCallback onPressed;
  final double? semanticsOrder;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Semantics(
      sortKey: semanticsOrder != null ? OrdinalSortKey(semanticsOrder!) : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          side: MaterialStatePropertyAll<BorderSide>(
            BorderSide(color: primaryColor),
          ),
          padding: const MaterialStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(vertical: LARGE_SPACE),
          ),
          shape: MaterialStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: ROUNDED_BORDER_RADIUS,
              side: BorderSide(color: primaryColor),
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            icon,
            const SizedBox(height: SMALL_SPACE),
            label,
          ],
        ),
      ),
    );
  }
}

/// Lets the user pick a picture, crop it, and save it.
Future<File?> confirmAndUploadNewPicture(
  final State<StatefulWidget> widget, {
  required final ImageField imageField,
  required final String barcode,
  required final OpenFoodFactsLanguage language,
  required final bool isLoggedInMandatory,
}) async {
  XFile? croppedPhoto;
  try {
    croppedPhoto = await pickImageFile(widget);
  } on PhotoAccessDenied catch (_) {
    final bool? res = await _onGalleryAccessDenied(widget);
    if (res == true) {
      // Let's retry
      croppedPhoto = await pickImageFile(
        widget,
        ignorePlatformException: true,
      );
    }
  }

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
        inputFile: File(croppedPhoto!.path),
        initiallyDifferent: true,
        language: language,
        isLoggedInMandatory: isLoggedInMandatory,
      ),
      fullscreenDialog: true,
    ),
  );
}

Future<bool?> _onGalleryAccessDenied(State<StatefulWidget> widget) {
  return showDialog<bool>(
      context: widget.context,
      builder: (BuildContext context) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);
        return SmoothSimpleErrorAlertDialog(
          title: appLocalizations.gallery_source_access_denied_dialog_title,
          message:
              appLocalizations.gallery_source_access_denied_dialog_message_ios,
          positiveAction: SmoothActionButton(
            text: appLocalizations.gallery_source_access_denied_dialog_button,
            onPressed: () {
              AppSettings.openAppSettings(callback: () {
                if (widget.mounted) {
                  Navigator.of(context).maybePop(true);
                }
              });
            },
          ),
          negativeAction: SmoothActionButton(
            text: appLocalizations.close,
            onPressed: () {
              Navigator.of(context).maybePop(false);
            },
          ),
          actionsAxis: Axis.vertical,
        );
      });
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

class PhotoAccessDenied implements Exception {}
