import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/pages/product/product_image_swipeable_view.dart';

extension ImageFieldSmoothieExtension on ImageField {
  static const List<ImageField> orderedMain = <ImageField>[
    ImageField.FRONT,
    ImageField.INGREDIENTS,
    ImageField.NUTRITION,
    ImageField.PACKAGING,
  ];

  static const List<ImageField> orderedAll = <ImageField>[
    ImageField.FRONT,
    ImageField.INGREDIENTS,
    ImageField.NUTRITION,
    ImageField.PACKAGING,
    ImageField.OTHER,
  ];

  String? getUrl(final Product product) {
    switch (this) {
      case ImageField.FRONT:
        return product.imageFrontUrl;
      case ImageField.INGREDIENTS:
        return product.imageIngredientsUrl;
      case ImageField.NUTRITION:
        return product.imageNutritionUrl;
      case ImageField.PACKAGING:
        return product.imagePackagingUrl;
      case ImageField.OTHER:
        return null;
    }
  }

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

  String getProductImageButtonText(final AppLocalizations appLocalizations) {
    switch (this) {
      case ImageField.FRONT:
        return appLocalizations.front_photo;
      case ImageField.INGREDIENTS:
        return appLocalizations.ingredients_photo;
      case ImageField.NUTRITION:
        return appLocalizations.nutrition_facts_photo;
      case ImageField.PACKAGING:
        return appLocalizations.packaging_information_photo;
      case ImageField.OTHER:
        return appLocalizations.more_photos;
    }
  }

  /// Returns a verbose description of the image field.
  String getImagePageTitle(final AppLocalizations appLocalizations) {
    switch (this) {
      case ImageField.FRONT:
        return appLocalizations.front_packaging_photo_title;
      case ImageField.INGREDIENTS:
        return appLocalizations.ingredients_photo_title;
      case ImageField.NUTRITION:
        return appLocalizations.nutritional_facts_photo_title;
      case ImageField.PACKAGING:
        return appLocalizations.recycling_photo_title;
      case ImageField.OTHER:
        return appLocalizations.other_interesting_photo_title;
    }
  }

  /// Returns a compact description of the image field.
  String getProductImageTitle(final AppLocalizations appLocalizations) {
    switch (this) {
      case ImageField.FRONT:
        return appLocalizations.product;
      case ImageField.INGREDIENTS:
        return appLocalizations.ingredients;
      case ImageField.NUTRITION:
        return appLocalizations.nutrition;
      case ImageField.PACKAGING:
        return appLocalizations.packaging_information;
      case ImageField.OTHER:
        return appLocalizations.more_photos;
    }
  }

  String getAddPhotoButtonText(final AppLocalizations appLocalizations) {
    switch (this) {
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

  Widget getPhotoButton(
    final BuildContext context,
    final Product product,
    final bool isLoggedInMandatory,
  ) =>
      SmoothLargeButtonWithIcon(
        onPressed: () async => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => ProductImageSwipeableView.imageField(
              imageField: this,
              product: product,
              isLoggedInMandatory: isLoggedInMandatory,
            ),
          ),
        ),
        icon: Icons.camera_alt,
        text: getProductImageButtonText(AppLocalizations.of(context)),
      );
}
