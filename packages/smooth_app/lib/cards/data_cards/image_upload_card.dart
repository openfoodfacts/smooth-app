import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/LanguageHelper.dart';
import 'package:smooth_app/pages/product/product_image_page.dart';

class ImageUploadCard extends StatefulWidget {
  const ImageUploadCard({
    required this.product,
    required this.imageField,
    this.imageUrl,
    this.title,
    required this.buttonText,
  });

  final Product product;
  final ImageField imageField;
  final String? imageUrl;
  final String? title;
  final String buttonText;

  @override
  State<ImageUploadCard> createState() => _ImageUploadCardState();
}

class _ImageUploadCardState extends State<ImageUploadCard> {
  ImageProvider? _imageProvider; // Normal size image to display in carousel
  ImageProvider?
      _imageFullProvider; // Full resolution image to display in image page

  Future<void> _getImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final File? croppedImageFile = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        androidUiSettings: const AndroidUiSettings(
          lockAspectRatio: false,
          hideBottomControls: true,
        ),
      );

      if (croppedImageFile != null) {
        setState(() {
          // Update the image to load the new image file
          // The same full resolution image is used for both the carousel and the image page
          _imageProvider = FileImage(croppedImageFile);
          _imageFullProvider = _imageProvider;
        });

        final SendImage image = SendImage(
          lang: LanguageHelper.fromJson(
              Localizations.localeOf(context).languageCode),
          barcode: widget.product
              .barcode!, //Probably throws an error, but this is not a big problem when we got a product without a barcode
          imageField: widget.imageField,
          imageUri: croppedImageFile.uri,
        );

        // a registered user login for https://world.openfoodfacts.org/ is required
        //ToDo: Add user
        const User myUser =
            User(userId: 'smoothie-app', password: 'strawberrybanana');

        // query the OpenFoodFacts API
        final Status result =
            await OpenFoodAPIClient.addProductImage(myUser, image);

        if (result.status != 'status ok') {
          throw Exception(
              'image could not be uploaded: ${result.error} ${result.imageId.toString()}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // We can already have an _imageProvider for a file that is going to be uploaded
    // or an imageUrl for a network image
    // or no image yet

    if ((_imageProvider == null) && (widget.imageUrl != null)) {
      _imageProvider = NetworkImage(widget.imageUrl!);
    }

    if (_imageProvider != null) {
      return GestureDetector(
        child: Center(
            child:
                Image(image: _imageProvider!, fit: BoxFit.cover, height: 1000)),
        onTap: () {
          // if _imageFullProvider is null, we are displaying a small network image in the carousel
          // we need to load the full resolution image

          if (_imageFullProvider == null) {
            final String _imageFullUrl =
                widget.imageUrl!.replaceAll('.400.', '.full.');
            _imageFullProvider = NetworkImage(_imageFullUrl);
          }

          Navigator.push<Widget>(
            context,
            MaterialPageRoute<Widget>(
              builder: (BuildContext context) => ProductImagePage(
                  product: widget.product,
                  imageField: widget.imageField,
                  imageProvider: _imageFullProvider!,
                  title: widget.title ?? 'Image',
                  buttonText: widget.buttonText),
            ),
          );
        },
      );
    } else {
      return ElevatedButton.icon(
        onPressed: _getImage,
        icon: const Icon(Icons.add_a_photo),
        label: Text(widget.buttonText),
      );
    }
  }
}
