import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/crop_helper.dart';
import 'package:smooth_app/pages/crop_page.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/pages/product_crop_helper.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Safely picks an image file from gallery or camera, regarding access denied.
Future<XFile?> pickImageFile(
  final BuildContext context, {
  final UserPictureSource? forcedSource,
}) async {
  /// Picks an image file from gallery or camera.
  Future<XFile?> innerPickImageFile(
    final BuildContext context, {
    bool ignorePlatformException = false,
  }) async {
    final UserPictureSource? source;
    if (forcedSource != null) {
      source = forcedSource;
    } else {
      source = await _getUserPictureSource(context);
      if (source == null) {
        return null;
      }
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

  try {
    return innerPickImageFile(context);
  } on PhotoAccessDenied catch (_) {
    if (!context.mounted) {
      return null;
    }
    final bool? res = await _onGalleryAccessDenied(context);
    if (res != true) {
      return null;
    }
    // Let's retry
    if (!context.mounted) {
      return null;
    }
    return innerPickImageFile(context, ignorePlatformException: true);
  }
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
          start: BALANCED_SPACE,
          end: MEDIUM_SPACE,
          top: LARGE_SPACE,
          bottom: MEDIUM_SPACE,
        ),
      );
    },
  );
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

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: BALANCED_SPACE),
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
              splashColor: primaryColor.withValues(alpha: 0.2),
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
                      onChanged: (final bool? value) =>
                          setState(() => rememberChoice = value ?? false),
                    ),
                  ),
                  Expanded(
                    child: Text(appLocalizations.user_picture_source_remember),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
          side: WidgetStatePropertyAll<BorderSide>(
            BorderSide(
              color: context.lightTheme()
                  ? primaryColor
                  : context
                        .extension<SmoothColorsThemeExtension>()
                        .primaryLight,
            ),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(vertical: LARGE_SPACE),
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
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

/// Lets the user pick a new product picture, crop it, and save it.
Future<CropParameters?> confirmAndUploadNewPicture(
  final BuildContext context, {
  required final ImageField imageField,
  required final String barcode,
  required final ProductType? productType,
  required final OpenFoodFactsLanguage language,
  required final bool isLoggedInMandatory,
  final UserPictureSource? forcedSource,
}) async => confirmAndUploadNewImage(
  context,
  cropHelper: ProductCropNewHelper(
    imageField: imageField,
    language: language,
    barcode: barcode,
    productType: productType,
  ),
  isLoggedInMandatory: isLoggedInMandatory,
  forcedSource: forcedSource,
);

/// Lets the user pick a picture, crop it, and save it.
Future<CropParameters?> confirmAndUploadNewImage(
  final BuildContext context, {
  required final CropHelper cropHelper,
  required final bool isLoggedInMandatory,
  final UserPictureSource? forcedSource,
}) async {
  final XFile? fullPhoto = await pickImageFile(
    context,
    forcedSource: forcedSource,
  );
  if (fullPhoto == null) {
    return null;
  }
  if (!context.mounted) {
    return null;
  }
  return Navigator.of(context).push<CropParameters>(
    MaterialPageRoute<CropParameters>(
      builder: (BuildContext context) => CropPage(
        inputFile: File(fullPhoto.path),
        initiallyDifferent: true,
        isLoggedInMandatory: isLoggedInMandatory,
        cropHelper: cropHelper,
        onRetakePhoto: () => pickImageFile(
          context,
          forcedSource: forcedSource,
        ).then((XFile? file) => file != null ? File(file.path) : null),
      ),
      fullscreenDialog: true,
    ),
  );
}

Future<bool?> _onGalleryAccessDenied(final BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);
      return SmoothSimpleErrorAlertDialog(
        title: appLocalizations.gallery_source_access_denied_dialog_title,
        message:
            appLocalizations.gallery_source_access_denied_dialog_message_ios,
        positiveAction: SmoothActionButton(
          text: appLocalizations.gallery_source_access_denied_dialog_button,
          onPressed: () async {
            await AppSettings.openAppSettings();
            if (context.mounted) {
              Navigator.of(context).maybePop(true);
            }
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
    },
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
    if (context.mounted) {
      await LoadingDialog.error(
        context: context,
        title: appLocalizations.image_download_error,
      );
    }
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

  final int sequenceNumber = await getNextSequenceNumber(
    daoInt,
    CROP_IMAGE_SEQUENCE_KEY,
  );

  final File file = File('${tempDirectory.path}/editing_image_$sequenceNumber');

  return file.writeAsBytes(response.bodyBytes);
}

class PhotoAccessDenied implements Exception {}
