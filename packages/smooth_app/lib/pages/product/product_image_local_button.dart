import 'package:flutter/material.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/product_image_button.dart';

/// Button asking for a "local" photo (new from camera, existing from gallery).
class ProductImageLocalButton extends ProductImageButton {
  const ProductImageLocalButton({
    required super.product,
    required super.imageField,
    required super.language,
    required super.isLoggedInMandatory,
    required this.imageExists,
    super.borderWidth,
  });

  final bool imageExists;

  @override
  IconData getIconData() => Icons.add_a_photo;

  @override
  String getLabel(final AppLocalizations appLocalizations) => imageExists
      ? appLocalizations.capture
      : appLocalizations.capture_new_picture;

  @override
  Future<void> action(final BuildContext context) async {
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: isLoggedInMandatory,
    )) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    await confirmAndUploadNewPicture(
      context,
      imageField: imageField,
      barcode: barcode,
      productType: product.productType,
      language: language,
      isLoggedInMandatory: isLoggedInMandatory,
    );
  }
}
