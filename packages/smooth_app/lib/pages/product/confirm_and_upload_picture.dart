import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/picture_capture_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class ConfirmAndUploadPicture extends StatefulWidget {
  const ConfirmAndUploadPicture({
    required this.barcode,
    required this.imageType,
    required this.initialPhoto,
  });

  final ImageField imageType;
  final String barcode;
  final File initialPhoto;

  @override
  State<ConfirmAndUploadPicture> createState() =>
      _ConfirmAndUploadPictureState();
}

class _ConfirmAndUploadPictureState extends State<ConfirmAndUploadPicture> {
  late File photo;

  @override
  void initState() {
    super.initState();
    //clear cache or the cached image will be shwon in File(photo)
    imageCache.clear();
    photo = widget.initialPhoto;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    File? retakenPhoto;

    // Picture is captured, show it to the user one last time and ask for
    // confirmation before uploading. Also present an option to retake the
    // picture as sometimes the picture can be blurry.
    return SmoothScaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_getAppBarTitle(context, widget.imageType)),
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
                    OutlinedButton.icon(
                      icon: const Icon(Icons.camera),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          themeData.colorScheme.background,
                        ),
                        shape: MaterialStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: ROUNDED_BORDER_RADIUS,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        retakenPhoto = await startImageCropping(context,
                            chooseFromGallery: false);
                        if (retakenPhoto == null) {
                          if (!mounted) {
                            return;
                          }
                          // User chose not to upload the image.
                          Navigator.pop(context);
                          return;
                        }
                        setState(
                          () {
                            photo = retakenPhoto!;
                          },
                        );
                      },
                      label: Text(appLocalizations.capture),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.photo_sharp),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          themeData.colorScheme.background,
                        ),
                        shape: MaterialStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: ROUNDED_BORDER_RADIUS,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        retakenPhoto = await startImageCropping(context,
                            chooseFromGallery: true);
                        if (retakenPhoto == null) {
                          if (!mounted) {
                            return;
                          }
                          // User chose not to upload the image.
                          Navigator.pop(context);
                          return;
                        }
                        setState(
                          () {
                            photo = retakenPhoto!;
                          },
                        );
                      },
                      label: Text(appLocalizations.choose_from_gallery),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.edit),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          themeData.colorScheme.background,
                        ),
                        shape: MaterialStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: ROUNDED_BORDER_RADIUS,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        retakenPhoto = await startImageCropping(context,
                            existingImage: photo);
                        if (retakenPhoto == null) {
                          if (!mounted) {
                            return;
                          }
                          // User chose not to upload the image.
                          Navigator.pop(context);
                          return;
                        }
                        setState(
                          () {
                            photo = retakenPhoto!;
                          },
                        );
                      },
                      label: Text(
                        appLocalizations.edit_photo_button_label,
                      ),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.check),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          themeData.colorScheme.background,
                        ),
                        shape: MaterialStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: ROUNDED_BORDER_RADIUS,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        final bool isPhotoUploaded =
                            await uploadCapturedPicture(
                          context,
                          barcode: widget.barcode,
                          imageField: widget.imageType,
                          imageUri: photo.uri,
                        );
                        if (!mounted) {
                          return;
                        }
                        retakenPhoto?.delete();
                        Navigator.pop(
                          context,
                          isPhotoUploaded ? photo : null,
                        );
                      },
                      label: Text(
                        appLocalizations.confirm_button_label,
                      ),
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

  String _getAppBarTitle(BuildContext context, ImageField imageType) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    switch (imageType) {
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
}
