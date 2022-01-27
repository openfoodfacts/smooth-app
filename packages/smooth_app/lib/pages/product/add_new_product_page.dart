import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/ProductImage.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/pages/product/picture_capturer.dart';
import 'package:smooth_app/themes/theme_provider.dart';

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
            right: VERY_LARGE_SPACE),
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
                  _buildImageCaptureRow(context, ImageField.FRONT),
                  _buildImageCaptureRow(context, ImageField.NUTRITION),
                  _buildImageCaptureRow(context, ImageField.INGREDIENTS),
                  _buildImageCaptureRow(context, ImageField.PACKAGING),
                  for (File image
                      in _uploadedImages[ImageField.OTHER] ?? <File>[])
                    _buildImageUploadedRow(context, ImageField.OTHER, image),
                  _buildAddImageButton(context, ImageField.OTHER),
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

  Widget _buildImageCaptureRow(BuildContext context, ImageField imageType) {
    if ((_uploadedImages[imageType] ?? <File>[]).isNotEmpty) {
      // An image has already been uploaded.
      return _buildImageUploadedRow(
          context, imageType, _uploadedImages[imageType]![0]);
    }
    return _buildAddImageButton(context, imageType);
  }

  Widget _buildAddImageButton(BuildContext context, ImageField imageType) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    return Padding(
      padding: const EdgeInsets.only(top: VERY_LARGE_SPACE),
      child: SmoothLargeButtonWithIcon(
        text: _getAddPhotoButtonText(context, imageType),
        icon: Icons.camera_alt,
        isDarkMode: themeProvider.darkTheme,
        onPressed: () async {
          final File? photo = await Navigator.push<File?>(
            context,
            MaterialPageRoute<File?>(
              builder: (BuildContext context) => PictureCapturer(
                barcode: widget.barcode,
                imageType: imageType,
              ),
            ),
          );
          if (photo != null) {
            _uploadedImages[imageType] = _uploadedImages[imageType] ?? <File>[];
            _uploadedImages[imageType]!.add(photo);
            setState(() {});
          }
        },
      ),
    );
  }

  Widget _buildImageUploadedRow(
      BuildContext context, ImageField imageType, File image) {
    return Padding(
      padding: const EdgeInsets.only(top: VERY_LARGE_SPACE),
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
}
