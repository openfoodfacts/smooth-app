import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/helpers/picture_capture_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/product_image_gallery_view.dart';

class ImageUploadCard extends StatefulWidget {
  const ImageUploadCard({
    required this.product,
    required this.productImageData,
    required this.allProductImagesData,
    required this.onUpload,
  });

  final Product product;
  final ProductImageData productImageData;
  final List<ProductImageData> allProductImagesData;
  final Function(BuildContext) onUpload;

  @override
  State<ImageUploadCard> createState() => _ImageUploadCardState();
}

class _ImageUploadCardState extends State<ImageUploadCard> {
  ImageProvider? _imageProvider; // Normal size image to display in carousel
  ImageProvider?
      _imageFullProvider; // Full resolution image to display in image page

  Future<void> _getImage() async {
    final File? croppedImageFile = await startImageCropping(context);

    if (croppedImageFile != null) {
      setState(() {
        // Update the image to load the new image file
        // The same full resolution image is used for both the carousel and the image page
        _imageProvider = FileImage(croppedImageFile);
        _imageFullProvider = _imageProvider;
      });

      final bool isUploaded = await uploadCapturedPicture(
        context,
        barcode: widget.product
            .barcode!, //Probably throws an error, but this is not a big problem when we got a product without a barcode
        imageField: widget.productImageData.imageField,
        imageUri: croppedImageFile.uri,
      );
      croppedImageFile.delete();
      if (isUploaded) {
        widget.onUpload(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // We can already have an _imageProvider for a file that is going to be uploaded
    // or an imageUrl for a network image
    // or no image yet
    if ((_imageProvider == null) &&
        (widget.productImageData.imageUrl != null)) {
      _imageProvider = NetworkImage(widget.productImageData.imageUrl!);
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
                widget.productImageData.imageUrl!.replaceAll('.400.', '.full.');
            _imageFullProvider = NetworkImage(_imageFullUrl);
          }

          Navigator.push<Widget>(
            context,
            MaterialPageRoute<Widget>(
              builder: (BuildContext context) => ProductImageGalleryView(
                productImageData: widget.productImageData,
                allProductImagesData: widget.allProductImagesData,
                title: widget.productImageData.title,
              ),
            ),
          );
        },
      );
    } else {
      return ElevatedButton.icon(
        onPressed: _getImage,
        icon: const Icon(Icons.add_a_photo),
        label: Text(widget.productImageData.buttonText),
      );
    }
  }
}
