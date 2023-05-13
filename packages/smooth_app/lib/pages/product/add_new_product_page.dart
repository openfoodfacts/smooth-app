import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/add_basic_details_page.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

const EdgeInsetsGeometry _ROW_PADDING_TOP = EdgeInsetsDirectional.only(
  top: VERY_LARGE_SPACE,
);

/// "Create a product we couldn't find on the server" page.
class AddNewProductPage extends StatefulWidget {
  const AddNewProductPage(this.barcode);

  final String barcode;

  @override
  State<AddNewProductPage> createState() => _AddNewProductPageState();
}

class _AddNewProductPageState extends State<AddNewProductPage> {
  // Just one file per main image field
  final Map<ImageField, File> _uploadedImages = <ImageField, File>{};
  // Many possible files for "other" image field
  final List<File> _otherUploadedImages = <File>[];

  late Product _product;
  late final Product _initialProduct;
  late final LocalDatabase _localDatabase;
  late DaoProductList _daoProductList;

  final ProductList _history = ProductList.history();

  /// Returns true if the [field] is valid (= not empty).
  static bool _isProductFieldValid(final String? field) =>
      field != null && field.trim().isNotEmpty;

  /// Returns true if the [product] basic details are valid (= not empty).
  static bool isProductBasicValid(final Product product) =>
      _isProductFieldValid(product.productName) ||
      _isProductFieldValid(product.brands);

  bool get _nutritionFactsAdded => _product.nutriments?.isEmpty() == false;
  bool get _basicDetailsAdded => isProductBasicValid(_product);

  bool _alreadyPushedtToHistory = false;

  @override
  void initState() {
    super.initState();
    _initialProduct = Product(barcode: widget.barcode);
    _localDatabase = context.read<LocalDatabase>();
    _localDatabase.upToDate.showInterest(widget.barcode);
    _daoProductList = DaoProductList(_localDatabase);
  }

  @override
  void dispose() {
    _localDatabase.upToDate.loseInterest(widget.barcode);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    context.watch<LocalDatabase>();
    final ThemeData themeData = Theme.of(context);
    _product = _localDatabase.upToDate.getLocalUpToDate(_initialProduct);
    final bool empty = _uploadedImages.isEmpty && _otherUploadedImages.isEmpty;

    _addToHistory();

    return SmoothScaffold(
      appBar: AppBar(
        title: Text(appLocalizations.new_product),
        automaticallyImplyLeading: empty,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async => Navigator.maybePop(context),
        label: Text(appLocalizations.finish),
        icon: const Icon(Icons.done),
      ),
      body: Padding(
        padding: const EdgeInsetsDirectional.only(
          top: VERY_LARGE_SPACE,
          start: VERY_LARGE_SPACE,
          end: VERY_LARGE_SPACE,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                appLocalizations.add_product_take_photos_descriptive,
                style: themeData.textTheme.bodyLarge!
                    .apply(color: themeData.colorScheme.onBackground),
              ),
              ..._buildImageCaptureRows(context),
              _buildNutritionInputButton(),
              _buildAddInputDetailsButton()
            ],
          ),
        ),
      ),
    );
  }

  /// Adds the product to history if at least one of the fields is set.
  Future<void> _addToHistory() async {
    if (_alreadyPushedtToHistory) {
      return;
    }
    // TODO(open): Add _nutritionFactsAdded , see (https://github.com/openfoodfacts/smooth-app/issues/3445)
    if (_basicDetailsAdded ||
        _uploadedImages.isNotEmpty ||
        _otherUploadedImages.isNotEmpty) {
      _product.productName = _product.productName?.trim();
      _product.brands = _product.brands?.trim();
      await _daoProductList.push(_history, _product.barcode!);
      _alreadyPushedtToHistory = true;
    }
  }

  List<Widget> _buildImageCaptureRows(BuildContext context) {
    final List<Widget> rows = <Widget>[];
    // First build rows for buttons to ask user to upload images.
    for (final ImageField imageField
        in ImageFieldSmoothieExtension.orderedAll) {
      // Always add a button to "Add other photos" because there can be multiple
      // "other photos" uploaded by the user.
      if (imageField == ImageField.OTHER) {
        rows.add(_buildAddImageButton(context, imageField));
        for (final File image in _otherUploadedImages) {
          rows.add(_buildImageUploadedRow(context, imageField, image));
        }
        continue;
      }

      // Everything else can only be uploaded once
      final File? imageFile = _uploadedImages[imageField];
      if (imageFile != null) {
        rows.add(
          _buildImageUploadedRow(
            context,
            imageField,
            imageFile,
          ),
        );
      } else {
        rows.add(_buildAddImageButton(context, imageField));
      }
    }
    return rows;
  }

  Widget _buildAddImageButton(BuildContext context, ImageField imageField) {
    return Padding(
      padding: _ROW_PADDING_TOP,
      child: SmoothLargeButtonWithIcon(
        text: imageField.getAddPhotoButtonText(AppLocalizations.of(context)),
        icon: Icons.camera_alt,
        onPressed: () async {
          final File? finalPhoto = await confirmAndUploadNewPicture(
            this,
            barcode: widget.barcode,
            imageField: imageField,
            language: ProductQuery.getLanguage(),
          );
          if (finalPhoto != null) {
            setState(() {
              if (imageField == ImageField.OTHER) {
                _otherUploadedImages.add(finalPhoto);
              } else {
                _uploadedImages[imageField] = finalPhoto;
              }
            });
          }
        },
      ),
    );
  }

  Widget _buildImageUploadedRow(
    BuildContext context,
    ImageField imageField,
    File image,
  ) =>
      _InfoAddedRow(
        text: imageField.getAddPhotoButtonText(AppLocalizations.of(context)),
        imgStart: image,
      );

  Widget _buildNutritionInputButton() {
    // if the nutrition image is null, ie no image , we return nothing
    if (_product.imageNutritionUrl == null) {
      return const SizedBox();
    }
    if (_nutritionFactsAdded) {
      return _InfoAddedRow(
          text: AppLocalizations.of(context).nutritional_facts_added);
    }

    return Padding(
      padding: _ROW_PADDING_TOP,
      child: SmoothLargeButtonWithIcon(
        text: AppLocalizations.of(context).nutritional_facts_input_button_label,
        icon: Icons.edit,
        onPressed: () async => NutritionPageLoaded.showNutritionPage(
          product: Product(barcode: widget.barcode),
          isLoggedInMandatory: false,
          widget: this,
        ),
      ),
    );
  }

  Widget _buildAddInputDetailsButton() {
    if (_basicDetailsAdded) {
      return _InfoAddedRow(
          text: AppLocalizations.of(context).basic_details_add_success);
    }

    return Padding(
      padding: _ROW_PADDING_TOP,
      child: SmoothLargeButtonWithIcon(
        text: AppLocalizations.of(context).completed_basic_details_btn_text,
        icon: Icons.edit,
        onPressed: () async => Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => AddBasicDetailsPage(
              Product(barcode: widget.barcode),
              isLoggedInMandatory: false,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoAddedRow extends StatelessWidget {
  const _InfoAddedRow({required this.text, this.imgStart});

  final String text;
  final File? imgStart;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Padding(
      padding: _ROW_PADDING_TOP,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 50,
            width: 50,
            child: ClipRRect(
              borderRadius: ROUNDED_BORDER_RADIUS,
              child: imgStart == null
                  ? null
                  : Image.file(imgStart!, fit: BoxFit.cover),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(text, style: themeData.textTheme.bodyLarge),
            ),
          ),
          Icon(
            Icons.check,
            color: themeData.bottomNavigationBarTheme.selectedItemColor,
          )
        ],
      ),
    );
  }
}
