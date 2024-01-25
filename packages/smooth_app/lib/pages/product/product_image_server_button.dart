import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image/uploaded_image_gallery.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_image_button.dart';

/// Button asking for a "server" photo (taken from what was already uploaded).
class ProductImageServerButton extends StatelessWidget {
  const ProductImageServerButton({
    required this.product,
    required this.imageField,
    required this.language,
    required this.isLoggedInMandatory,
    this.borderWidth,
  });

  final Product product;
  final ImageField imageField;
  final OpenFoodFactsLanguage language;
  final bool isLoggedInMandatory;
  final double? borderWidth;

  bool _hasServerImages() => product.images?.isNotEmpty == true;

  String get _barcode => product.barcode!;

  @override
  Widget build(BuildContext context) {
    if (!_hasServerImages()) {
      return EMPTY_WIDGET;
    }
    return EditImageButton(
      iconData: Icons.image_search,
      label:
          AppLocalizations.of(context).edit_photo_select_existing_button_label,
      onPressed: () async => _actionGallery(context),
      borderWidth: borderWidth,
    );
  }

  Future<void> _actionGallery(final BuildContext context) async {
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
      await _openGallery(context: context, rawImages: rawImages);
      return;
    }

    final bool fetched = await ProductRefresher().fetchAndRefresh(
      barcode: _barcode,
      context: context,
    );
    if (!fetched) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    final Product? latestProduct =
        await DaoProduct(context.read<LocalDatabase>()).get(_barcode);
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
    await _openGallery(context: context, rawImages: rawImages);
  }

  Future<void> _openGallery({
    required final BuildContext context,
    required final List<ProductImage> rawImages,
  }) =>
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => UploadedImageGallery(
            barcode: _barcode,
            rawImages: rawImages,
            imageField: imageField,
            language: language,
            isLoggedInMandatory: isLoggedInMandatory,
          ),
        ),
      );
}
