import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/pages/image/uploaded_image_gallery.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/product_image_button.dart';

/// Button asking for a "server" photo (taken from what was already uploaded).
class ProductImageServerButton extends ProductImageButton {
  const ProductImageServerButton({
    required super.product,
    required super.imageField,
    required super.language,
    required super.isLoggedInMandatory,
    super.borderWidth,
  });

  bool get _hasServerImages => product.images?.isNotEmpty == true;

  @override
  bool isHidden() => !_hasServerImages;

  @override
  IconData getIconData() => Icons.image_search_rounded;

  @override
  String getLabel(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_photo_select_existing_button_label;

  @override
  Future<void> action(final BuildContext context) async {
    await selectImageFromGallery(
      context: context,
      product: product,
      imageField: imageField,
      language: language,
      isLoggedInMandatory: isLoggedInMandatory,
    );
  }

  static Future<CropParameters?> selectImageFromGallery({
    required final BuildContext context,
    required final Product product,
    required final ImageField imageField,
    required final OpenFoodFactsLanguage language,
    required final bool isLoggedInMandatory,
  }) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: isLoggedInMandatory,
    )) {
      return null;
    }

    if (!context.mounted) {
      return null;
    }

    List<ProductImage> rawImages = getRawProductImages(
      product,
      ImageSize.DISPLAY,
    );
    if (rawImages.isNotEmpty) {
      return _openGallery(
        context: context,
        rawImages: rawImages,
        productType: product.productType,
        barcode: product.barcode!,
        imageField: imageField,
        language: language,
        isLoggedInMandatory: isLoggedInMandatory,
      );
    }

    final bool fetched = await ProductRefresher().fetchAndRefresh(
      barcode: product.barcode!,
      context: context,
    );
    if (!fetched) {
      return null;
    }

    if (!context.mounted) {
      return null;
    }

    final Product? latestProduct = await DaoProduct(
      context.read<LocalDatabase>(),
    ).get(product.barcode!);
    if (!context.mounted) {
      return null;
    }
    if (latestProduct != null) {
      // very likely
      rawImages = getRawProductImages(
        latestProduct,
        ImageSize.DISPLAY,
      );
    }

    if (rawImages.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => SmoothAlertDialog(
          body:
              Text(appLocalizations.edit_photo_select_existing_downloaded_none),
          actionsAxis: Axis.vertical,
          positiveAction: SmoothActionButton(
            text: appLocalizations.okay,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
      return null;
    }
    return _openGallery(
      context: context,
      rawImages: rawImages,
      productType: product.productType,
      barcode: product.barcode!,
      imageField: imageField,
      language: language,
      isLoggedInMandatory: isLoggedInMandatory,
    );
  }

  static Future<CropParameters?> _openGallery({
    required final BuildContext context,
    required final List<ProductImage> rawImages,
    required final ProductType? productType,
    required final String barcode,
    required final ImageField imageField,
    required final OpenFoodFactsLanguage language,
    required final bool isLoggedInMandatory,
  }) =>
      Navigator.push<CropParameters?>(
        context,
        MaterialPageRoute<CropParameters?>(
          builder: (BuildContext context) => UploadedImageGallery(
            barcode: barcode,
            rawImages: rawImages,
            imageField: imageField,
            language: language,
            isLoggedInMandatory: isLoggedInMandatory,
            productType: productType,
          ),
        ),
      );
}
