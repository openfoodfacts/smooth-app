import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/edit_image_button.dart';
import 'package:smooth_app/pages/product/product_image_crop_button.dart';
import 'package:smooth_app/pages/product/product_image_local_button.dart';
import 'package:smooth_app/pages/product/product_image_server_button.dart';
import 'package:smooth_app/pages/product/product_image_unselect_button.dart';

/// Abstract Product Image Button.
abstract class ProductImageButton extends StatelessWidget {
  const ProductImageButton({
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

  @override
  Widget build(BuildContext context) {
    if (isHidden()) {
      return EMPTY_WIDGET;
    }
    return EditImageButton(
      iconData: getIconData(),
      label: getLabel(AppLocalizations.of(context)),
      onPressed: () => action(context),
      borderWidth: borderWidth,
    );
  }

  @protected
  String get barcode => product.barcode!;

  @protected
  bool isHidden() => false;

  @protected
  IconData getIconData();

  @protected
  String getLabel(final AppLocalizations appLocalizations);

  @protected
  Future<void> action(final BuildContext context);
}

enum ProductImageButtonType {
  local,
  server,
  unselect,
  edit;

  Widget getButton({
    required final Product product,
    required final ImageField imageField,
    required final OpenFoodFactsLanguage language,
    required final bool isLoggedInMandatory,
    final double? borderWidth,
    required bool imageExists,
  }) => switch (this) {
    ProductImageButtonType.local => ProductImageLocalButton(
      product: product,
      imageField: imageField,
      language: language,
      isLoggedInMandatory: isLoggedInMandatory,
      borderWidth: borderWidth,
      imageExists: imageExists,
    ),
    ProductImageButtonType.server => ProductImageServerButton(
      product: product,
      imageField: imageField,
      language: language,
      isLoggedInMandatory: isLoggedInMandatory,
      borderWidth: borderWidth,
    ),
    ProductImageButtonType.unselect => ProductImageUnselectButton(
      product: product,
      productType: product.productType,
      imageField: imageField,
      language: language,
      isLoggedInMandatory: isLoggedInMandatory,
      borderWidth: borderWidth,
    ),
    ProductImageButtonType.edit => ProductImageCropButton(
      product: product,
      imageField: imageField,
      language: language,
      isLoggedInMandatory: isLoggedInMandatory,
      borderWidth: borderWidth,
    ),
  };
}
