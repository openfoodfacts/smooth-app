import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';

String getProductName(Product product, AppLocalizations appLocalizations) =>
    product.productName ?? appLocalizations.unknownProductName;

String getProductBrands(Product product, AppLocalizations appLocalizations) {
  final String? brands = product.brands;
  if (brands == null) {
    return appLocalizations.unknownBrand;
  } else {
    return formatProductBrands(brands, appLocalizations);
  }
}

/// Correctly format word separators between words (e.g. comma in English)
String formatProductBrands(String brands, AppLocalizations appLocalizations) {
  final String separator = appLocalizations.word_separator;
  final String separatorChar =
      RegExp.escape(appLocalizations.word_separator_char);
  final RegExp regex = RegExp('\\s*$separatorChar\\s*');
  return brands.replaceAll(regex, separator);
}

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

/// Returns the mandatory attributes, ordered by attribute group order
List<Attribute> getMandatoryAttributes(
  final Product product,
  final List<String> attributeGroupOrder,
  final Set<String> attributesToExcludeIfStatusIsUnknown,
  final ProductPreferences preferences,
) {
  final List<Attribute> result = <Attribute>[];
  if (product.attributeGroups == null) {
    return result;
  }
  final Map<String, List<Attribute>> mandatoryAttributesByGroup =
      <String, List<Attribute>>{};
  // collecting all the mandatory attributes, by group
  for (final AttributeGroup attributeGroup in product.attributeGroups!) {
    mandatoryAttributesByGroup[attributeGroup.id!] = getFilteredAttributes(
      attributeGroup,
      PreferenceImportance.ID_MANDATORY,
      attributesToExcludeIfStatusIsUnknown,
      preferences,
    );
  }

  // now ordering by attribute group order
  for (final String attributeGroupId in attributeGroupOrder) {
    final List<Attribute>? attributes =
        mandatoryAttributesByGroup[attributeGroupId];
    if (attributes != null) {
      result.addAll(attributes);
    }
  }
  return result;
}

/// Returns the attributes that match the filter
///
/// [SCORE_ATTRIBUTE_IDS] attributes are not included, as they are already
/// dealt with somewhere else.
List<Attribute> getFilteredAttributes(
  final AttributeGroup attributeGroup,
  final String importance,
  final Set<String> attributesToExcludeIfStatusIsUnknown,
  final ProductPreferences preferences,
) {
  final List<Attribute> result = <Attribute>[];
  if (attributeGroup.attributes == null) {
    return result;
  }
  for (final Attribute attribute in attributeGroup.attributes!) {
    final String attributeId = attribute.id!;
    if (SCORE_ATTRIBUTE_IDS.contains(attributeId)) {
      continue;
    }
    if (attributeGroup.id == AttributeGroup.ATTRIBUTE_GROUP_LABELS) {
      attributesToExcludeIfStatusIsUnknown.add(attributeId);
    }
    final String importanceId =
        preferences.getImportanceIdForAttributeId(attributeId);
    if (importance == importanceId) {
      result.add(attribute);
    }
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

List<ProductImageData> getProductMainImagesData(
  Product product, {
  final bool includeOther = true,
}) =>
    <ProductImageData>[
      getProductImageData(product, ImageField.FRONT),
      getProductImageData(product, ImageField.INGREDIENTS),
      getProductImageData(product, ImageField.NUTRITION),
      getProductImageData(product, ImageField.PACKAGING),
      if (includeOther) getProductImageData(product, ImageField.OTHER),
    ];

ProductImageData getProductImageData(
  final Product product,
  final ImageField imageField,
) =>
    ProductImageData(
      imageField: imageField,
      imageUrl: getProductImageUrl(product, imageField),
    );

String? getProductImageUrl(
  final Product product,
  final ImageField imageField,
) {
  switch (imageField) {
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

/// Returns a compact description of the image field.
String getProductImageTitle(
  final AppLocalizations appLocalizations,
  final ImageField imageField,
) {
  switch (imageField) {
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

/// Returns a verbose description of the image field.
String getImagePageTitle(
  final AppLocalizations appLocalizations,
  final ImageField imageField,
) {
  switch (imageField) {
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

String getProductImageButtonText(
  final AppLocalizations appLocalizations,
  final ImageField imageField,
) {
  switch (imageField) {
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
