import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/picture_capture_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';

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
    photo = widget.initialPhoto;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    // Picture is captured, show it to the user one last time and ask for
    // confirmation before uploading. Also present an option to retake the
    // picture as sometimes the picture can be blurry.
    return Scaffold(
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
                padding: const EdgeInsets.only(bottom: MEDIUM_SPACE),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    SmoothActionButton(
                        text: appLocalizations.retake_photo_button_label,
                        onPressed: () async {
                          final File? retakenPhoto =
                              await startImageCropping(context);
                          if (retakenPhoto == null) {
                            // User chose not to upload the image.
                            Navigator.pop(context);
                            return;
                          }
                          setState(() {
                            photo = retakenPhoto;
                          });
                          retakenPhoto.delete();
                        }),
                    SmoothActionButton(
                      text: _getConfirmButtonText(
                        context,
                        widget.imageType,
                      ),
                      onPressed: () async {
                        final bool isPhotoUploaded =
                            await uploadCapturedPicture(
                          context,
                          barcode: widget.barcode,
                          imageField: widget.imageType,
                          imageUri: photo.uri,
                        );
                        Navigator.pop(
                          context,
                          isPhotoUploaded ? photo : null,
                        );
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

  String _getAppBarTitle(BuildContext context, ImageField imageType) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
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

  String _getConfirmButtonText(BuildContext context, ImageField imageType) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    switch (imageType) {
      case ImageField.FRONT:
        return appLocalizations.confirm_button_label;
      case ImageField.INGREDIENTS:
        return appLocalizations.confirm_ingredients_photo_button_label;
      case ImageField.NUTRITION:
        return appLocalizations.confirm_nutritional_facts_photo_button_label;
      case ImageField.PACKAGING:
        return appLocalizations.confirm_recycling_photo_button_label;
      case ImageField.OTHER:
        return appLocalizations.confirm_other_interesting_photo_button_label;
    }
  }
}
