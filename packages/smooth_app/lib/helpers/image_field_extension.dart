import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/product_image_swipeable_view.dart';

extension ImageFieldSmoothieExtension on ImageField {
  static List<ImageField> getOrderedMainImageFields(
    final ProductType? productType,
  ) =>
      switch (productType) {
        ProductType.product => const <ImageField>[
            ImageField.FRONT,
            ImageField.PACKAGING,
          ],
        ProductType.beauty => const <ImageField>[
            ImageField.FRONT,
            ImageField.INGREDIENTS,
            ImageField.PACKAGING,
          ],
        null || ProductType.food || ProductType.petFood => const <ImageField>[
            ImageField.FRONT,
            ImageField.INGREDIENTS,
            ImageField.NUTRITION,
            ImageField.PACKAGING,
          ],
      };

  void setUrl(final Product product, final String url) {
    switch (this) {
      case ImageField.FRONT:
        product.imageFrontUrl = url;
        break;
      case ImageField.INGREDIENTS:
        product.imageIngredientsUrl = url;
        break;
      case ImageField.NUTRITION:
        product.imageNutritionUrl = url;
        break;
      case ImageField.PACKAGING:
        product.imagePackagingUrl = url;
        break;
      case ImageField.OTHER:
      // We do nothing.
    }
  }

  String getProductImageButtonText(final AppLocalizations appLocalizations) =>
      switch (this) {
        ImageField.FRONT => appLocalizations.front_photo,
        ImageField.INGREDIENTS => appLocalizations.ingredients_photo,
        ImageField.NUTRITION => appLocalizations.nutrition_facts_photo,
        ImageField.PACKAGING => appLocalizations.packaging_information_photo,
        ImageField.OTHER => appLocalizations.more_photos,
      };

  /// Returns a verbose description of the image field.
  String getImagePageTitle(final AppLocalizations appLocalizations) =>
      switch (this) {
        ImageField.FRONT => appLocalizations.front_packaging_photo_title,
        ImageField.INGREDIENTS => appLocalizations.ingredients_photo_title,
        ImageField.NUTRITION => appLocalizations.nutritional_facts_photo_title,
        ImageField.PACKAGING => appLocalizations.recycling_photo_title,
        ImageField.OTHER => appLocalizations.take_more_photo_title,
      };

  /// Returns a compact description of the image field.
  String getProductImageTitle(final AppLocalizations appLocalizations) =>
      switch (this) {
        ImageField.FRONT => appLocalizations.product,
        ImageField.INGREDIENTS => appLocalizations.ingredients,
        ImageField.NUTRITION => appLocalizations.nutrition,
        ImageField.PACKAGING => appLocalizations.packaging_information,
        ImageField.OTHER => appLocalizations.more_photos,
      };

  String getAddPhotoButtonText(final AppLocalizations appLocalizations) =>
      switch (this) {
        ImageField.FRONT => appLocalizations.front_packaging_photo_button_label,
        ImageField.INGREDIENTS =>
          appLocalizations.ingredients_photo_button_label,
        ImageField.NUTRITION =>
          appLocalizations.nutritional_facts_photo_button_label,
        ImageField.PACKAGING => appLocalizations.recycling_photo_button_label,
        ImageField.OTHER => appLocalizations.take_more_photo_button_label,
      };

  String getPictureAccessibilityLabel(
    final AppLocalizations appLocalizations,
  ) =>
      switch (this) {
        ImageField.FRONT =>
          appLocalizations.product_image_front_accessibility_label,
        ImageField.INGREDIENTS =>
          appLocalizations.product_image_ingredients_accessibility_label,
        ImageField.NUTRITION =>
          appLocalizations.product_image_nutrition_accessibility_label,
        ImageField.PACKAGING =>
          appLocalizations.product_image_packaging_accessibility_label,
        ImageField.OTHER =>
          appLocalizations.product_image_other_accessibility_label,
      };

  Widget getPhotoButton(
    final BuildContext context,
    final Product product,
    final bool isLoggedInMandatory,
  ) =>
      SmoothLargeButtonWithIcon(
        onPressed: () async => openDetails(
          context,
          product,
          isLoggedInMandatory,
        ),
        leadingIcon: const Icon(Icons.camera_alt),
        text: getProductImageButtonText(AppLocalizations.of(context)),
      );

  Future<void> openDetails(
    final BuildContext context,
    final Product product,
    final bool isLoggedInMandatory,
  ) =>
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ProductImageSwipeableView.imageField(
            imageField: this,
            product: product,
            isLoggedInMandatory: isLoggedInMandatory,
          ),
        ),
      );

  String? getImageUrl(Product product) => switch (this) {
        ImageField.FRONT => product.imageFrontUrl,
        ImageField.INGREDIENTS => product.imageIngredientsUrl,
        ImageField.NUTRITION => product.imageNutritionUrl,
        ImageField.PACKAGING => product.imagePackagingUrl,
        ImageField.OTHER => null,
      };
}
