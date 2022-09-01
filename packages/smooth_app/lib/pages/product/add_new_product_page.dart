import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/model/ProductImage.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/add_basic_details_page.dart';
import 'package:smooth_app/pages/product/confirm_and_upload_picture.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';
import 'package:smooth_app/pages/product/ordered_nutrients_cache.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

const EdgeInsetsGeometry _ROW_PADDING_TOP = EdgeInsetsDirectional.only(
  top: VERY_LARGE_SPACE,
);

// Buttons to add images will appear in this order.
const List<ImageField> _SORTED_IMAGE_FIELD_LIST = <ImageField>[
  ImageField.FRONT,
  ImageField.NUTRITION,
  ImageField.INGREDIENTS,
  ImageField.PACKAGING,
  ImageField.OTHER,
];

class AddNewProductPage extends StatefulWidget {
  const AddNewProductPage(this.barcode);

  final String barcode;

  @override
  State<AddNewProductPage> createState() => _AddNewProductPageState();
}

class _AddNewProductPageState extends State<AddNewProductPage> {
  final Map<ImageField, List<File>> _uploadedImages =
      <ImageField, List<File>>{};

  bool _nutritionFactsAdded = false;
  bool _basicDetailsAdded = false;
  bool _isProductLoaded = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    return SmoothScaffold(
      appBar: AppBar(
          title: Text(appLocalizations.new_product),
          automaticallyImplyLeading: !_isProductLoaded),
      body: Padding(
        padding: const EdgeInsetsDirectional.only(
          top: VERY_LARGE_SPACE,
          start: VERY_LARGE_SPACE,
          end: VERY_LARGE_SPACE,
        ),
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    appLocalizations.add_product_take_photos_descriptive,
                    style: themeData.textTheme.bodyText1!
                        .apply(color: themeData.colorScheme.onBackground),
                  ),
                  ..._buildImageCaptureRows(context),
                  _buildNutritionInputButton(),
                  _buildaddInputDetailsButton()
                ],
              ),
            ),
            Positioned(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SmoothActionButtonsBar.single(
                  action: SmoothActionButton(
                    text: appLocalizations.finish,
                    onPressed: () async {
                      final LocalDatabase localDatabase =
                          context.read<LocalDatabase>();
                      final DaoProduct daoProduct = DaoProduct(localDatabase);
                      final Product? product =
                          await daoProduct.get(widget.barcode);
                      if (product == null) {
                        final Product product = Product(
                          barcode: widget.barcode,
                        );
                        daoProduct.put(product);
                        localDatabase.notifyListeners();
                      }
                      if (mounted) {
                        await Navigator.maybePop(
                            context, _isProductLoaded ? widget.barcode : null);
                      }
                    },
                  ),
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
        if (_uploadedImages[imageType] != null) {
          for (final File image in _uploadedImages[imageType]!) {
            rows.add(_buildImageUploadedRow(context, imageType, image));
          }
        }
        continue;
      }

      // Everything else can only be uploaded once
      if (_isImageUploadedForType(imageType)) {
        rows.add(
          _buildImageUploadedRow(
            context,
            imageType,
            _uploadedImages[imageType]![0],
          ),
        );
      } else {
        rows.add(_buildAddImageButton(context, imageType));
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
          // TODO(monsieurtanuki): careful, waiting for pop'ed value
          //ignore: use_build_context_synchronously
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
            setState(() {
              _isProductLoaded = true;
            });
          }
        },
      ),
    );
  }

  Widget _buildImageUploadedRow(
      BuildContext context, ImageField imageType, File image) {
    final ThemeData themeData = Theme.of(context);
    return Padding(
      padding: _ROW_PADDING_TOP,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 50, child: Image.file(image, fit: BoxFit.cover)),
          Expanded(
            child: Center(
              child: Text(_getAddPhotoButtonText(context, imageType),
                  style: themeData.textTheme.bodyText1),
            ),
          ),
          Icon(
            Icons.check_box,
            color: themeData.bottomNavigationBarTheme.selectedItemColor,
          )
        ],
      ),
    );
  }

  String _getAddPhotoButtonText(BuildContext context, ImageField imageType) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
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

  bool _isImageUploadedForType(ImageField imageType) {
    return (_uploadedImages[imageType] ?? <File>[]).isNotEmpty;
  }

  Widget _buildNutritionInputButton() {
    if (_nutritionFactsAdded) {
      return Padding(
        padding: _ROW_PADDING_TOP,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 50.0,
              child: Icon(
                Icons.check,
                color: Theme.of(context)
                    .bottomNavigationBarTheme
                    .selectedItemColor,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                    AppLocalizations.of(context).nutritional_facts_added,
                    style: Theme.of(context).textTheme.bodyText1),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: _ROW_PADDING_TOP,
      child: SmoothLargeButtonWithIcon(
        text: AppLocalizations.of(context).nutritional_facts_input_button_label,
        icon: Icons.edit,
        onPressed: () async {
          final OrderedNutrientsCache? cache =
              await OrderedNutrientsCache.getCache(context);
          if (cache == null) {
            if (!mounted) {
              return;
            }
            final SnackBar snackBar = SnackBar(
              content: Text(
                  AppLocalizations.of(context).nutrition_cache_loading_error),
            );
            if (!mounted) {
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            return;
          }
          if (!mounted) {
            return;
          }
          // TODO(monsieurtanuki): careful, waiting for pop'ed value
          final Product? result = await Navigator.push<Product?>(
            context,
            MaterialPageRoute<Product>(
              builder: (BuildContext context) => NutritionPageLoaded(
                Product(barcode: widget.barcode),
                cache.orderedNutrients,
                isLoggedInMandatory: false,
              ),
              fullscreenDialog: true,
            ),
          );

          setState(() {
            _nutritionFactsAdded = result != null;
          });
        },
      ),
    );
  }

  Widget _buildaddInputDetailsButton() {
    if (_basicDetailsAdded) {
      final ThemeData themeData = Theme.of(context);
      return Padding(
          padding: _ROW_PADDING_TOP,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 50.0,
                child: Icon(
                  Icons.check,
                  color: themeData.bottomNavigationBarTheme.selectedItemColor,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                      AppLocalizations.of(context).basic_details_add_success,
                      style: Theme.of(context).textTheme.bodyText1),
                ),
              ),
            ],
          ));
    }

    return Padding(
      padding: _ROW_PADDING_TOP,
      child: SmoothLargeButtonWithIcon(
        text: AppLocalizations.of(context).completed_basic_details_btn_text,
        icon: Icons.edit,
        onPressed: () async {
          // TODO(monsieurtanuki): probably wrong as AddBasicDetailsPage pops nothing
          // TODO(monsieurtanuki): careful, waiting for pop'ed value
          final Product? result = await Navigator.push<Product?>(
            context,
            MaterialPageRoute<Product>(
              builder: (BuildContext context) => AddBasicDetailsPage(
                Product(barcode: widget.barcode),
                isLoggedInMandatory: false,
              ),
            ),
          );
          setState(() {
            _basicDetailsAdded = result != null;
          });
        },
      ),
    );
  }
}
