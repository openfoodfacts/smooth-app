import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';

String getProductName(Product product, AppLocalizations appLocalizations) =>
    product.productName ?? appLocalizations.unknownProductName;

/// Padding to be used while building the SmoothCard on any Product card.
const EdgeInsets SMOOTH_CARD_PADDING = EdgeInsets.symmetric(
  horizontal: MEDIUM_SPACE,
  vertical: VERY_SMALL_SPACE,
);

/// A SmoothCard on Product cards using default margin and padding.
Widget buildProductSmoothCard({
  Widget? header,
  required Widget body,
  EdgeInsets? padding = EdgeInsets.zero,
  EdgeInsets? margin = const EdgeInsets.symmetric(
    horizontal: SMALL_SPACE,
  ),
}) {
  return SmoothCard(
    margin: margin,
    padding: padding,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (header != null) header,
        body,
      ],
    ),
  );
}

// used to be in now defunct `AttributeListExpandable`
List<Attribute> getPopulatedAttributes(
  final Product product,
  final List<String> attributeIds,
  final List<String> excludedAttributeIds,
) {
  final List<Attribute> result = <Attribute>[];
  final Map<String, Attribute> attributes = product.getAttributes(attributeIds);
  for (final String attributeId in attributeIds) {
    if (excludedAttributeIds.contains(attributeId)) {
      continue;
    }
    Attribute? attribute = attributes[attributeId];
// Some attributes selected in the user preferences might be unavailable for some products
    if (attribute == null) {
      continue;
    } else if (attribute.id == Attribute.ATTRIBUTE_ADDITIVES) {
// TODO(stephanegigandet): remove that cheat when additives are more standard
      final List<String>? additiveNames = product.additives?.names;
      attribute = Attribute(
        id: attribute.id,
        title: attribute.title,
        iconUrl: attribute.iconUrl,
        descriptionShort: additiveNames == null ? '' : additiveNames.join(', '),
      );
    }
    result.add(attribute);
  }
  return result;
}

Widget addPanelButton(
  final String label, {
  final IconData? iconData,
  required final Function() onPressed,
}) =>
    SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(iconData ?? Icons.add),
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            const RoundedRectangleBorder(
              borderRadius: ROUNDED_BORDER_RADIUS,
            ),
          ),
        ),
        label: Text(label),
        onPressed: onPressed,
      ),
    );

List<ProductImageData> getAllProductImagesData(
    Product product, AppLocalizations appLocalizations) {
  final List<ProductImageData> allProductImagesData = <ProductImageData>[
    ProductImageData(
      imageField: ImageField.FRONT,
      imageUrl: product.imageFrontUrl,
      title: appLocalizations.product,
      buttonText: appLocalizations.front_photo,
    ),
    ProductImageData(
      imageField: ImageField.INGREDIENTS,
      imageUrl: product.imageIngredientsUrl,
      title: appLocalizations.ingredients,
      buttonText: appLocalizations.ingredients_photo,
    ),
    ProductImageData(
      imageField: ImageField.NUTRITION,
      imageUrl: product.imageNutritionUrl,
      title: appLocalizations.nutrition,
      buttonText: appLocalizations.nutrition_facts_photo,
    ),
    ProductImageData(
      imageField: ImageField.PACKAGING,
      imageUrl: product.imagePackagingUrl,
      title: appLocalizations.packaging_information,
      buttonText: appLocalizations.packaging_information_photo,
    ),
    ProductImageData(
      imageField: ImageField.OTHER,
      imageUrl: null,
      title: appLocalizations.more_photos,
      buttonText: appLocalizations.more_photos,
    ),
  ];
  return allProductImagesData;
}
