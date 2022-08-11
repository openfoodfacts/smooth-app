import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final File? croppedImageFile =
        await startImageCropping(context, showOptionDialog: true);

    if (croppedImageFile != null) {
      if (widget.productImageData.imageField != ImageField.OTHER) {
        setState(() {
          // Update the image to load the new image file
          // The same full resolution image is used for both the carousel and the image page
          _imageProvider = FileImage(croppedImageFile);
          _imageFullProvider = _imageProvider;
        });
      }
      if (!mounted) {
        return;
      }
      final bool isUploaded = await uploadCapturedPicture(
        context,
        barcode: widget.product
            .barcode!, //Probably throws an error, but this is not a big problem when we got a product without a barcode
        imageField: widget.productImageData.imageField,
        imageUri: croppedImageFile.uri,
      );
      croppedImageFile.delete();
      if (!mounted) {
        return;
      }
      if (isUploaded) {
        if (widget.productImageData.imageField == ImageField.OTHER) {
          final AppLocalizations appLocalizations =
              AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appLocalizations.other_photo_uploaded),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: appLocalizations.more_photos,
                onPressed: _getImage,
              ),
            ),
          );
        } else {
          await widget.onUpload(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    // We can already have an _imageProvider for a file that is going to be uploaded
    // or an imageUrl for a network image
    // or no image yet
    if (widget.productImageData.imageUrl != null) {
      _imageProvider = NetworkImage(widget.productImageData.imageUrl!);
    } else {
      if (_imageProvider != null) {
        //Refresh when image has been deselected on server side
        _imageProvider = null;
        _imageFullProvider = null;
      }
    }

    if (_imageProvider != null) {
      return GestureDetector(
        child: Center(
          child: Image(
            image: _imageProvider!,
            fit: BoxFit.cover,
            height: 1000,
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return Column(
                children: <Widget>[
                  Icon(
                    Icons.cloud_off_sharp,
                    size: screenSize.width / 4,
                  ),
                  Text(appLocalizations.no_internet_connection),
                ],
              );
            },
          ),
        ),
        onTap: () async {
          // if _imageFullProvider is null, we are displaying a small network image in the carousel
          // we need to load the full resolution image

          if (_imageFullProvider == null) {
            final String imageFullUrl =
                widget.productImageData.imageUrl!.replaceAll('.400.', '.full.');
            _imageFullProvider = NetworkImage(imageFullUrl);
          }

          final bool? refreshed = await Navigator.push<bool>(
            context,
            MaterialPageRoute<bool>(
              builder: (BuildContext context) => ProductImageGalleryView(
                productImageData: widget.productImageData,
                allProductImagesData: widget.allProductImagesData,
                title: widget.productImageData.title,
                barcode: widget.product.barcode,
              ),
            ),
          );
          if (!mounted) {
            return;
          }
          if (refreshed ?? false) {
            await widget.onUpload(context);
          }
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
