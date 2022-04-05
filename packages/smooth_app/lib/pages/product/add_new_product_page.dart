import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/ProductImage.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/confirm_and_upload_picture.dart';

const EdgeInsets _ROW_PADDING_TOP = EdgeInsets.only(top: VERY_LARGE_SPACE);

// Buttons to add images will appear in this order.
const List<ImageField> _SORTED_IMAGE_FIELD_LIST = <ImageField>[
  ImageField.FRONT,
  ImageField.NUTRITION,
  ImageField.INGREDIENTS,
  ImageField.PACKAGING,
  ImageField.OTHER,
];

class AddNewProductPage extends StatefulWidget {
  const AddNewProductPage(
    this.barcode,
  );

  final String barcode;

  @override
  State<AddNewProductPage> createState() => _AddNewProductPageState();
}

class _AddNewProductPageState extends State<AddNewProductPage> {
  final Map<ImageField, List<File>> _uploadedImages =
      <ImageField, List<File>>{};

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.only(
          top: VERY_LARGE_SPACE,
          left: VERY_LARGE_SPACE,
          right: VERY_LARGE_SPACE,
        ),
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    appLocalizations.new_product,
                    style: themeData.textTheme.headline1!
                        .apply(color: themeData.colorScheme.onSurface),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: VERY_LARGE_SPACE),
                  ),
                  Text(
                    appLocalizations.add_product_take_photos_descriptive,
                    style: themeData.textTheme.bodyText1!
                        .apply(color: themeData.colorScheme.onSurface),
                  ),
                  ..._buildImageCaptureRows(context),
                ],
              ),
            ),
            Positioned(
              child: Align(
                alignment: Alignment.bottomRight,
                child: SmoothActionButton(
                  text: appLocalizations.finish,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildImageCaptureRows(BuildContext context) {
    final List<Widget> rows = <Widget>[];
    // First build rows for buttons to ask user to upload images.
    for (final ImageField imageType in _SORTED_IMAGE_FIELD_LIST) {
      // Always add a button to "Add other photos" because there can be multiple
      // "other photos" uploaded by the user.
      if (imageType == ImageField.OTHER) {
        rows.add(_buildAddImageButton(context, imageType));
        continue;
      }
      // Everything else can only be uploaded once, skip building the
      // "Add Image button" if an image for this type is already uploaded.
      if (!_isImageUploadedForType(imageType)) {
        rows.add(_buildAddImageButton(context, imageType));
      }
    }
    // Now build rows for images that are already uploaded.
    for (final ImageField imageType in ImageField.values) {
      if (_isImageUploadedForType(imageType)) {
        for (final File image in _uploadedImages[imageType]!) {
          rows.add(_buildImageUploadedRow(context, imageType, image));
        }
      }
    }
    return rows;
  }

  Widget _buildAddImageButton(BuildContext context, ImageField imageType) {
    return Padding(
      padding: _ROW_PADDING_TOP,
      child: SmoothLargeButtonWithIcon(
        text: _getAddPhotoButtonText(context, imageType),
        icon: Icons.camera_alt,
        onPressed: () async {
          final File? initialPhoto = await startImageCropping(context);
          if (initialPhoto == null) {
            return;
          }
          // Photo can change in the ConfirmAndUploadPicture widget, the user
          // may choose to retake the image.
          final File? finalPhoto = await Navigator.push<File?>(
            context,
            MaterialPageRoute<File?>(
              builder: (BuildContext context) => ConfirmAndUploadPicture(
                barcode: widget.barcode,
                imageType: imageType,
                initialPhoto: initialPhoto,
              ),
            ),
          );
          if (finalPhoto != null) {
            _uploadedImages[imageType] = _uploadedImages[imageType] ?? <File>[];
            _uploadedImages[imageType]!.add(initialPhoto);
            setState(() {});
          }
          initialPhoto.delete();
        },
      ),
    );
  }

  Widget _buildImageUploadedRow(
      BuildContext context, ImageField imageType, File image) {
    return Padding(
      padding: _ROW_PADDING_TOP,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 50, child: Image.file(image, fit: BoxFit.cover)),
          Expanded(
              child: Center(
                  child: Text(_getPhotoUploadedLabelText(context, imageType),
                      style: Theme.of(context).textTheme.bodyText1))),
        ],
      ),
    );
  }

  String _getAddPhotoButtonText(BuildContext context, ImageField imageType) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    switch (imageType) {
      case ImageField.FRONT:
        return appLocalizations.front_packaging_photo_button_label;
      case ImageField.INGREDIENTS:
        return appLocalizations.ingredients_photo_button_label;
      case ImageField.NUTRITION:
        return appLocalizations.nutritional_facts_photo_button_label;
      case ImageField.PACKAGING:
        return appLocalizations.recycling_photo_button_label;
      case ImageField.OTHER:
        return appLocalizations.other_interesting_photo_button_label;
    }
  }

  String _getPhotoUploadedLabelText(
      BuildContext context, ImageField imageType) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    switch (imageType) {
      case ImageField.FRONT:
        return appLocalizations.front_photo_uploaded;
      case ImageField.INGREDIENTS:
        return appLocalizations.ingredients_photo_uploaded;
      case ImageField.NUTRITION:
        return appLocalizations.nutritional_facts_photo_uploaded;
      case ImageField.PACKAGING:
        return appLocalizations.recycling_photo_uploaded;
      case ImageField.OTHER:
        return appLocalizations.other_photo_uploaded;
    }
  }

  bool _isImageUploadedForType(ImageField imageType) {
    return (_uploadedImages[imageType] ?? <File>[]).isNotEmpty;
  }
}
