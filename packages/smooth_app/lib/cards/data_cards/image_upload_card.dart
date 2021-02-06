import 'dart:io';
import 'package:flutter/material.dart';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/LanguageHelper.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageUploadCard extends StatefulWidget {
  const ImageUploadCard({
    this.product,
    this.imageField,
    this.buttonText,
  });

  final Product product;
  final ImageField imageField;
  final String buttonText;

  @override
  _ImageUploadCardState createState() => _ImageUploadCardState();
}

class _ImageUploadCardState extends State<ImageUploadCard> {
  File _image;
  final ImagePicker picker = ImagePicker();

  Future<void> _getImage() async {
    final PickedFile pickedFile =
        await picker.getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final File croppedImage = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        androidUiSettings: const AndroidUiSettings(
          lockAspectRatio: false,
          hideBottomControls: true,
        ),
      );

      if (croppedImage != null) {
        setState(() {
          _image = croppedImage;
        });

        final SendImage image = SendImage(
          lang: LanguageHelper.fromJson(
              Localizations.localeOf(context).languageCode),
          barcode: widget.product.barcode,
          imageField: widget.imageField,
          imageUrl: _image.uri,
        );

        // a registered user login for https://world.openfoodfacts.org/ is required
        const User myUser =
            User(userId: 'smoothie-app', password: 'strawberrybanana');

        // query the OpenFoodFacts API
        final Status result =
            await OpenFoodAPIClient.addProductImage(myUser, image);

        if (result.status != 'status ok') {
          throw Exception('image could not be uploaded: ' +
              result.error +
              ' ' +
              result.imageId.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _getImage,
      icon: const Icon(Icons.add_a_photo),
      label: Text(widget.buttonText),
    );
  }
}
