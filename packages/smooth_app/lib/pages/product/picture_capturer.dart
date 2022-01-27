import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openfoodfacts/model/ProductImage.dart';
import 'package:openfoodfacts/model/SendImage.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';

class PictureCapturer extends StatefulWidget {
  const PictureCapturer({required this.barcode, required this.imageType});

  final ImageField imageType;
  final String barcode;

  @override
  State<PictureCapturer> createState() => _PictureCapturerState();
}

class _PictureCapturerState extends State<PictureCapturer> {
  late File? picture;
  late Future<void> photoPicker;

  @override
  void initState() {
    super.initState();
    photoPicker = _getImage();
  }

  Future<void> _getImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedXFile = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedXFile != null) {
      picture = await ImageCropper.cropImage(
        sourcePath: pickedXFile.path,
        androidUiSettings: const AndroidUiSettings(
          lockAspectRatio: false,
          hideBottomControls: true,
        ),
      );
    } else {
      picture = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return FutureBuilder<void>(
        future: photoPicker,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          // We are still waiting for user to capture a picture.
          if (snapshot.hasError ||
              snapshot.connectionState != ConnectionState.done) {
            return EMPTY_WIDGET;
          }
          // User decided not to capture the picture. Take them back to [AddNewProductPage].
          if (picture == null) {
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              Navigator.pop(context);
            });
            return EMPTY_WIDGET;
          }
          // Picture is captured, show it to the user one last time and ask for
          // confirmation before uploading. Also present an option to retake the
          // picture as sometimes the picture can be blurry.
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(),
            body: Stack(
              children: <Widget>[
                Positioned(
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.file(picture!),
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
                                await _getImage();
                                setState(() {});
                              }),
                          SmoothActionButton(
                              text: _getConfirmButtonText(
                                context,
                                widget.imageType,
                              ),
                              onPressed: () async {
                                _uploadPicture();
                              }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  String _getConfirmButtonText(BuildContext context, ImageField imageType) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    switch (imageType) {
      case ImageField.FRONT:
        return appLocalizations.confirm_front_packaging_photo_button_label;
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

  Future<void> _uploadPicture() async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final SendImage image = SendImage(
      lang: ProductQuery.getLanguage(),
      barcode: widget.barcode,
      imageField: widget.imageType,
      imageUri: picture!.uri,
    );
    final Status result = await OpenFoodAPIClient.addProductImage(
      ProductQuery.getUser(),
      image,
    );
    if (result.error != null) {
      // Image upload failed :( Show an error and go back to [AddNewProductPage].
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => SmoothAlertDialog(
          body: Text(appLocalizations.error_occurred),
          actions: <SmoothActionButton>[
            SmoothActionButton(
              text: AppLocalizations.of(context)!.okay,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      Navigator.pop(context);
      return;
    }
    Navigator.pop(context, picture);
  }
}
