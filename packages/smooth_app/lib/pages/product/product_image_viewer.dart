// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_unselect.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/language_selector.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_image_button.dart';
import 'package:smooth_app/pages/product/product_image_local_button.dart';
import 'package:smooth_app/pages/product/product_image_server_button.dart';
import 'package:smooth_app/tmp_crop_image/new_crop_page.dart';
import 'package:smooth_app/tmp_crop_image/rotation.dart';

/// Displays a full-screen image with an "edit" floating button.
class ProductImageViewer extends StatefulWidget {
  const ProductImageViewer({
    required this.product,
    required this.imageField,
    required this.language,
    required this.setLanguage,
  });

  final Product product;
  final ImageField imageField;
  final OpenFoodFactsLanguage language;
  final Future<void> Function(OpenFoodFactsLanguage? newLanguage) setLanguage;

  @override
  State<ProductImageViewer> createState() => _ProductImageViewerState();
}

class _ProductImageViewerState extends State<ProductImageViewer> {
  late Product _product;
  late final Product _initialProduct;
  late final LocalDatabase _localDatabase;
  late ProductImageData _imageData;
  late OpenFoodFactsLanguage _actualImageLanguage;

  String get _barcode => _initialProduct.barcode!;

  @override
  void initState() {
    super.initState();
    _initialProduct = widget.product;
    _localDatabase = context.read<LocalDatabase>();
    _localDatabase.upToDate.showInterest(_barcode);
  }

  @override
  void dispose() {
    _localDatabase.upToDate.loseInterest(_barcode);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    _product = _localDatabase.upToDate.getLocalUpToDate(_initialProduct);
    _imageData = getProductImageData(
      _product,
      widget.imageField,
      // we want the image for this language, if possible
      widget.language,
    );
    // fallback language
    _actualImageLanguage = widget.language;
    if (_imageData.language == null && _imageData.imageUrl != null) {
      // let's find the language the imageUrl is related to.
      final OpenFoodFactsLanguage? language = getProductImageUrlLanguage(
        _product,
        _imageData.imageField,
        _imageData.imageUrl!,
      );
      if (language != null) {
        _actualImageLanguage = language;
      }
    }
    final ImageProvider? imageProvider = TransientFile.getImageProvider(
      _imageData,
      _barcode,
      widget.language,
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(MINIMUM_TOUCH_SIZE / 2),
            child: imageProvider == null
                ? const SizedBox.expand(child: PictureNotFound())
                : PhotoView(
                    minScale: 0.2,
                    imageProvider: imageProvider,
                    heroAttributes: PhotoViewHeroAttributes(
                      tag: imageProvider,
                    ),
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                  ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
                child: LanguageSelector(
                  setLanguage: widget.setLanguage,
                  displayedLanguage: _actualImageLanguage,
                  selectedLanguages: getProductImageLanguages(
                    _product,
                    <ImageField>[widget.imageField],
                  ),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
                child: ProductImageServerButton(
                  barcode: _barcode,
                  imageField: widget.imageField,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
                child: ProductImageLocalButton(
                  firstPhoto: imageProvider == null,
                  barcode: _barcode,
                  imageField: widget.imageField,
                ),
              ),
            ),
          ],
        ),
        if (imageProvider != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
                  child: _getUnselectImageButton(appLocalizations),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
                  child: _getEditImageButton(appLocalizations),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // TODO(monsieurtanuki): refactor as ProductImageCropButton
  Widget _getEditImageButton(final AppLocalizations appLocalizations) =>
      EditImageButton(
        iconData: Icons.edit,
        label: appLocalizations.edit_photo_button_label,
        onPressed: _actionEditImage,
      );

  // TODO(monsieurtanuki): refactor as ProductImageUnselectButton
  Widget _getUnselectImageButton(final AppLocalizations appLocalizations) =>
      EditImageButton(
        iconData: Icons.do_disturb_on,
        label: appLocalizations.edit_photo_unselect_button_label,
        onPressed: () => _actionUnselect(appLocalizations),
      );

  Future<File?> _actionEditImage() async {
    final NavigatorState navigatorState = Navigator.of(context);
    if (!await ProductRefresher().checkIfLoggedIn(context)) {
      return null;
    }
    // best possibility: with the crop parameters
    // TODO(monsieurtanuki): maybe we should keep the big image locally, in order to avoid the server call?
    final ProductImage? productImage = _getBestProductImage();
    if (productImage != null) {
      final int? imageId = int.tryParse(productImage.imgid!);
      if (imageId != null) {
        return _openEditCroppedImage(imageId, productImage);
      }
    }

    // alternate option: use the transient file.
    File? imageFile = TransientFile.getImage(
      _imageData.imageField,
      _barcode,
      widget.language,
    );
    if (imageFile != null) {
      return _openCropPage(navigatorState, imageFile);
    }

    // but if not possible, get the best picture from the server.
    final String? imageUrl = _imageData.getImageUrl(ImageSize.ORIGINAL);
    imageFile = await downloadImageUrl(
      context,
      imageUrl,
      DaoInt(_localDatabase),
    );
    if (imageFile != null) {
      return _openCropPage(navigatorState, imageFile);
    }

    return null;
  }

  Future<void> _actionUnselect(final AppLocalizations appLocalizations) async {
    final NavigatorState navigatorState = Navigator.of(context);

    if (!await ProductRefresher().checkIfLoggedIn(context)) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return SmoothAlertDialog(
          title: appLocalizations.confirm_button_label,
          body: Text(
            appLocalizations.are_you_sure,
          ),
          close: true,
          positiveAction: SmoothActionButton(
            text: appLocalizations.yes,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          negativeAction: SmoothActionButton(
            text: appLocalizations.no,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        );
      },
    );
    if (confirmed == true) {
      await BackgroundTaskUnselect.addTask(
        _barcode,
        imageField: widget.imageField,
        widget: this,
      );
      _localDatabase.notifyListeners();
      navigatorState.pop();
    }
  }

  Future<File?> _openCropPage(
    final NavigatorState navigatorState,
    final File imageFile, {
    final int? imageId,
    final Rect? initialCropRect,
    final Rotation? initialRotation,
  }) async =>
      navigatorState.push<File>(
        MaterialPageRoute<File>(
          builder: (BuildContext context) => CropPage(
            barcode: _product.barcode!,
            imageField: _imageData.imageField,
            inputFile: imageFile,
            imageId: imageId,
            initiallyDifferent: false,
            initialCropRect: initialCropRect,
            initialRotation: initialRotation,
          ),
          fullscreenDialog: true,
        ),
      );

  Future<File?> _openEditCroppedImage(
    final int imageId,
    final ProductImage productImage,
  ) async {
    final NavigatorState navigatorState = Navigator.of(context);
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final File? imageFile = await downloadImageUrl(
      context,
      ImageHelper.getUploadedImageUrl(
        _product.barcode!,
        imageId,
        ImageSize.ORIGINAL,
      ),
      DaoInt(localDatabase),
    );
    if (imageFile == null) {
      return null;
    }
    return _openCropPage(
      navigatorState,
      imageFile,
      imageId: imageId,
      initialCropRect: _getCropRect(productImage),
      initialRotation: RotationExtension.fromDegrees(
        productImage.angle?.degree ?? 0,
      ),
    );
  }

  ProductImage? _getBestProductImage() {
    if (_product.images == null) {
      return null;
    }
    for (final ProductImage productImage in _product.images!) {
      if (productImage.field != _imageData.imageField) {
        continue;
      }
      if (productImage.language != widget.language) {
        continue;
      }
      if (productImage.size == ImageSize.ORIGINAL) {
        if (productImage.imgid != null) {
          return productImage;
        }
      }
    }
    return null;
  }

  /// Returns a crop rect, to be compared with the full image dimensions.
  Rect? _getCropRect(final ProductImage productImage) =>
      productImage.x1 == null ||
              productImage.y1 == null ||
              productImage.x2 == null ||
              productImage.y2 == null
          ? null
          : Rect.fromLTRB(
              productImage.x1!.toDouble(),
              productImage.y1!.toDouble(),
              productImage.x2!.toDouble(),
              productImage.y2!.toDouble(),
            );
}
