import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/query/product_query.dart';

Widget buildProductTitle(
  final Product product,
  final AppLocalizations appLocalizations,
) =>
    Text(
      getProductNameAndBrands(product, appLocalizations),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );

String getProductNameAndBrands(
  final Product product,
  final AppLocalizations appLocalizations,
) {
  final String name = getProductName(product, appLocalizations);
  final String brands = getProductBrands(product, appLocalizations);
  return '$name, $brands';
}

/// Returns a trimmed version of the string, or null if null or empty.
String? _clearString(final String? string) {
  if (string == null) {
    return null;
  }
  if (string.trim().isEmpty) {
    return null;
  }
  return string.trim();
}

String getProductName(
  final Product product,
  final AppLocalizations appLocalizations,
) =>
    _clearString(product.productNameInLanguages?[ProductQuery.getLanguage()]) ??
    _clearString(product.productName) ??
    appLocalizations.unknownProductName;

String getProductBrands(
  final Product product,
  final AppLocalizations appLocalizations,
) {
  final String? brands = _clearString(product.brands);
  if (brands == null) {
    return appLocalizations.unknownBrand;
  }
  return formatProductBrands(brands);
}

/// Correctly format word separators between words.
String formatProductBrands(String brands) {
  const String separator = ', ';
  final String separatorChar = RegExp.escape(',');
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
}) =>
    SmoothCard(
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
) =>
    getSortedAttributes(
      product,
      attributeGroupOrder,
      attributesToExcludeIfStatusIsUnknown,
      preferences,
      PreferenceImportance.ID_MANDATORY,
    );

/// Returns the attributes, ordered by importance desc and attribute group order
List<Attribute> getSortedAttributes(
  final Product product,
  final List<String> attributeGroupOrder,
  final Set<String> attributesToExcludeIfStatusIsUnknown,
  final ProductPreferences preferences,
  final String importance, {
  final bool excludeMainScoreAttributes = true,
}) {
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
      importance,
      attributesToExcludeIfStatusIsUnknown,
      preferences,
      excludeMainScoreAttributes: excludeMainScoreAttributes,
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
  final ProductPreferences preferences, {
  final bool excludeMainScoreAttributes = true,
}) {
  final List<Attribute> result = <Attribute>[];
  if (attributeGroup.attributes == null) {
    return result;
  }
  for (final Attribute attribute in attributeGroup.attributes!) {
    final String attributeId = attribute.id!;
    if (excludeMainScoreAttributes &&
        SCORE_ATTRIBUTE_IDS.contains(attributeId)) {
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
  final String? textAlign,
  required final Function() onPressed,
}) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
      child: SmoothLargeButtonWithIcon(
        text: label,
        icon: iconData ?? Icons.add,
        onPressed: onPressed,
        textAlign: iconData == null ? TextAlign.center : null,
      ),
    );

List<ProductImageData> getProductMainImagesData(
  final Product product,
  final OpenFoodFactsLanguage language,
) {
  final List<ProductImageData> result = <ProductImageData>[];
  for (final ImageField imageField in ImageFieldSmoothieExtension.orderedMain) {
    result.add(getProductImageData(product, imageField, language));
  }
  return result;
}

/// Returns data about the [imageField], for the [language].
ProductImageData getProductImageData(
  final Product product,
  final ImageField imageField,
  final OpenFoodFactsLanguage language,
) {
  final ProductImage? productImage = getLocalizedProductImage(
    product,
    imageField,
    language,
  );
  if (productImage != null) {
    // we found a localized version for this image
    return ProductImageData(
      imageField: imageField,
      imageUrl: ImageHelper.getLocalizedProductImageUrl(
        product.barcode!,
        productImage,
        imageSize: ImageSize.DISPLAY,
      ),
      language: language,
    );
  }
  return getEmptyProductImageData(imageField);
}

ProductImageData getEmptyProductImageData(final ImageField imageField) =>
    ProductImageData(
      imageField: imageField,
      imageUrl: null,
      language: null,
    );

ProductImage? getLocalizedProductImage(
  final Product product,
  final ImageField imageField,
  final OpenFoodFactsLanguage language,
) {
  if (product.images == null) {
    return null;
  }
  for (final ProductImage productImage in product.images!) {
    if (productImage.field == imageField && productImage.language == language) {
      if (productImage.rev == null) {
        return null;
      }
      return productImage;
    }
  }
  return null;
}

/// Returns the languages for which [imageField] has images for that [product].
Iterable<OpenFoodFactsLanguage> getProductImageLanguages(
  final Product product,
  final ImageField imageField,
) {
  final Set<OpenFoodFactsLanguage> result = <OpenFoodFactsLanguage>{};
  result.addAll(TransientFile.getImageLanguages(imageField, product.barcode!));
  if (product.images == null) {
    return result;
  }
  for (final ProductImage productImage in product.images!) {
    if (imageField == productImage.field &&
        productImage.rev != null &&
        productImage.language != null) {
      result.add(productImage.language!);
    }
  }
  return result;
}
