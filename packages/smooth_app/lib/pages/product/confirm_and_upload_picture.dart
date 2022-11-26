import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_image.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Display of a full size picture with edit tools.
///
/// That's the only place where we upload images to the server.
/// Picture is captured, shown it to the user one last time and ask for
/// confirmation before uploading. Also present an option to retake the
/// picture as sometimes the picture can be blurry.
class ConfirmAndUploadPicture extends StatefulWidget {
  const ConfirmAndUploadPicture({
    required this.barcode,
    required this.imageField,
    required this.initialPhoto,
  });

  final ImageField imageField;
  final String barcode;
  final File initialPhoto;

  @override
  State<ConfirmAndUploadPicture> createState() =>
      _ConfirmAndUploadPictureState();
}

class _ConfirmAndUploadPictureState extends State<ConfirmAndUploadPicture> {
  // The local up-to-date photo, before any upload.
  late File photo;

  @override
  void initState() {
    super.initState();
    //clear cache or the cached image will be shown in File(photo)
    imageCache.clear();
    photo = widget.initialPhoto;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothScaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_getAppBarTitle(appLocalizations, widget.imageField)),
      ),
      body: Stack(
        children: <Widget>[
          Positioned(
            child: Align(
              alignment: Alignment.center,
              child: Image.file(photo),
            ),
          ),
          Positioned(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(bottom: MEDIUM_SPACE),
                child: Wrap(
                  spacing: MEDIUM_SPACE,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    _OutlinedButton(
                      iconData: Icons.camera_alt,
                      label: appLocalizations.capture,
                      onPressed: () async {
                        final File? retakenPhoto =
                            await startNewImageCropping(this);
                        if (retakenPhoto == null) {
                          return;
                        }
                        if (!mounted) {
                          return;
                        }
                        setState(() => photo = retakenPhoto);
                      },
                    ),
                    _OutlinedButton(
                      iconData: Icons.edit,
                      label: appLocalizations.edit_photo_button_label,
                      onPressed: () async {
                        final File? croppedPhoto =
                            await startExistingImageCropping(this, photo);
                        if (croppedPhoto == null) {
                          return;
                        }
                        if (!mounted) {
                          return;
                        }
                        setState(() => photo = croppedPhoto);
                      },
                    ),
                    _OutlinedButton(
                      iconData: Icons.check,
                      label: appLocalizations.confirm_button_label,
                      onPressed: () async {
                        await _uploadCapturedPicture(
                          widget: this,
                          barcode: widget.barcode,
                          imageField: widget.imageField,
                          imageUri: photo.uri,
                        );
                        if (!mounted) {
                          return;
                        }
                        Navigator.pop(context, photo);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle(
    final AppLocalizations appLocalizations,
    final ImageField imageField,
  ) {
    switch (imageField) {
      case ImageField.FRONT:
        return appLocalizations.front_packaging_photo_title;
      case ImageField.INGREDIENTS:
        return appLocalizations.ingredients_photo_title;
      case ImageField.NUTRITION:
        return appLocalizations.nutritional_facts_photo_title;
      case ImageField.PACKAGING:
        return appLocalizations.recycling_photo_title;
      case ImageField.OTHER:
        return appLocalizations.other_interesting_photo_title;
    }
  }

  Future<void> _uploadCapturedPicture({
    required String barcode,
    required ImageField imageField,
    required Uri imageUri,
    required State<StatefulWidget> widget,
  }) async {
    final LocalDatabase localDatabase = widget.context.read<LocalDatabase>();
    await BackgroundTaskImage.addTask(
      barcode,
      imageField: imageField,
      imageFile: File(imageUri.path),
      widget: widget,
    );
    localDatabase.notifyListeners();
    if (!widget.mounted) {
      return;
    }
    final ContinuousScanModel model =
        widget.context.read<ContinuousScanModel>();
    await model.onCreateProduct(barcode); // TODO(monsieurtanuki): a bit fishy
  }
}

/// Standard button for this page.
class _OutlinedButton extends StatelessWidget {
  const _OutlinedButton({
    required this.iconData,
    required this.label,
    required this.onPressed,
  });

  final IconData iconData;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return OutlinedButton.icon(
      icon: Icon(iconData),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          themeData.colorScheme.background,
        ),
        shape: MaterialStateProperty.all(
          const RoundedRectangleBorder(borderRadius: ROUNDED_BORDER_RADIUS),
        ),
      ),
      onPressed: onPressed,
      label: Text(label),
    );
  }
}