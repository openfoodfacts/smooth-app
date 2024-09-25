import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
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
  IconData getIconData() => Icons.image_search;

  @override
  String getLabel(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_photo_select_existing_button_label;

  @override
  Future<void> action(final BuildContext context) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: isLoggedInMandatory,
    )) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    List<ProductImage> rawImages = getRawProductImages(
      product,
      ImageSize.DISPLAY,
    );
    if (rawImages.isNotEmpty) {
      await _openGallery(
        context: context,
        rawImages: rawImages,
        productType: product.productType,
      );
      return;
    }

    final bool fetched = await ProductRefresher().fetchAndRefresh(
      barcode: barcode,
      context: context,
    );
    if (!fetched) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    final Product? latestProduct =
        await DaoProduct(context.read<LocalDatabase>()).get(barcode);
    if (!context.mounted) {
      return;
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
      return;
    }
    await _openGallery(
      context: context,
      rawImages: rawImages,
      productType: product.productType,
    );
  }

  Future<void> _openGallery({
    required final BuildContext context,
    required final List<ProductImage> rawImages,
    required final ProductType? productType,
  }) =>
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
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
