import 'dart:io';

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/crop_page.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/product_image_button.dart';

/// Product Image Button editing the current image.
class ProductImageCropButton extends ProductImageButton {
  const ProductImageCropButton({
    required super.product,
    required super.imageField,
    required super.language,
    required super.isLoggedInMandatory,
    super.borderWidth,
  });

  @override
  IconData getIconData() => Icons.edit;

  @override
  String getLabel(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_photo_button_label;

  @override
  Future<void> action(final BuildContext context) async {
    final NavigatorState navigatorState = Navigator.of(context);
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: isLoggedInMandatory,
    )) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    // best possibility: with the crop parameters
    // TODO(monsieurtanuki): maybe we should keep the big image locally, in order to avoid the server call?
    final ProductImage? productImage = _getBestProductImage();
    if (productImage != null) {
      final int? imageId = int.tryParse(productImage.imgid!);
      if (imageId != null) {
        await _openEditCroppedImage(context, imageId, productImage);
        return;
      }
    }

    // alternate option: use the transient file.
    File? imageFile = _transientFile.getImage();
    if (imageFile != null) {
      await _openCropPage(navigatorState, imageFile);
      return;
    }

    // but if not possible, get the best picture from the server.
    final String? imageUrl = _imageData.getImageUrl(ImageSize.ORIGINAL);
    if (context.mounted) {
      imageFile = await downloadImageUrl(
        context,
        imageUrl,
        DaoInt(context.read<LocalDatabase>()),
      );
    }
    if (imageFile != null) {
      await _openCropPage(navigatorState, imageFile);
      return;
    }
  }

  Future<File?> _openCropPage(
    final NavigatorState navigatorState,
    final File imageFile, {
    final int? imageId,
    final Rect? initialCropRect,
    final CropRotation? initialRotation,
  }) async =>
      navigatorState.push<File>(
        MaterialPageRoute<File>(
          builder: (BuildContext context) => CropPage(
            language: language,
            barcode: barcode,
            imageField: _imageData.imageField,
            inputFile: imageFile,
            imageId: imageId,
            initiallyDifferent: false,
            initialCropRect: initialCropRect,
            initialRotation: initialRotation,
            isLoggedInMandatory: isLoggedInMandatory,
          ),
          fullscreenDialog: true,
        ),
      );

  Future<File?> _openEditCroppedImage(
    final BuildContext context,
    final int imageId,
    final ProductImage productImage,
  ) async {
    final NavigatorState navigatorState = Navigator.of(context);
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final File? imageFile = await downloadImageUrl(
      context,
      ProductImage.raw(
        imgid: imageId.toString(),
        size: ImageSize.ORIGINAL,
      ).getUrl(barcode),
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
      initialRotation: CropRotationExtension.fromDegrees(
        productImage.angle?.degree ?? 0,
      ),
    );
  }

  ProductImage? _getBestProductImage() {
    if (product.images == null) {
      return null;
    }
    for (final ProductImage productImage in product.images!) {
      if (productImage.field != _imageData.imageField) {
        continue;
      }
      if (productImage.language != language) {
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
  ///
  /// Sometimes you get all null coordinates, or all 0, or all -1.
  Rect? _getCropRect(final ProductImage productImage) =>
      productImage.x1 == productImage.x2 &&
              productImage.y1 == productImage.y2 &&
              productImage.x1 == productImage.y1
          ? null
          : Rect.fromLTRB(
              productImage.x1!.toDouble(),
              productImage.y1!.toDouble(),
              productImage.x2!.toDouble(),
              productImage.y2!.toDouble(),
            );

  ProductImageData get _imageData => getProductImageData(
        product,
        imageField,
        language,
      );

  TransientFile get _transientFile => TransientFile.fromProduct(
        product,
        imageField,
        language,
      );
}
