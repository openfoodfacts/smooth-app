// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/LanguageHelper.dart';

import 'package:smooth_app/pages/product/product_image_page.dart';

class ImageUploadCard extends StatefulWidget {
  const ImageUploadCard({
    this.product,
    this.imageField,
    this.imageUrl,
    this.title,
    this.buttonText,
  });

  final Product product;
  final ImageField imageField;
  final String imageUrl;
  final String title;
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

        print('barcode:' + widget.product.barcode);
        print('imageField:' + widget.imageField.toString());

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
    Widget content;

    if (widget.imageUrl != null) {
      content = GestureDetector(
        child: Center(
            child: Image.network(widget.imageUrl,
                fit: BoxFit.cover, height: 1000)),
        onTap: () {
          Navigator.push<Widget>(
            context,
            MaterialPageRoute(
              builder: (context) => ProductImagePage(
                  product: widget.product,
                  imageField: widget.imageField,
                  imageUrl: widget.imageUrl,
                  title: widget.title,
                  buttonText: widget.buttonText),
            ),
          );
        },
      );
    } else {
      content = ElevatedButton.icon(
        onPressed: _getImage,
        icon: const Icon(Icons.add_a_photo),
        label: Text(widget.buttonText),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
      decoration: const BoxDecoration(color: Colors.black12),
      child: content,
    );
  }
}
