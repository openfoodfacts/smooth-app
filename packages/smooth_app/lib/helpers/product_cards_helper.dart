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

String getProductName(Product product, AppLocalizations appLocalizations) =>
    product.productName ?? appLocalizations.unknownProductName;

String getProductBrands(Product product, AppLocalizations appLocalizations) {
  final String? brands = product.brands;
  if (brands == null) {
    return appLocalizations.unknownBrand;
  } else {
    return formatProductBrands(brands);
  }
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
  final OpenFoodFactsLanguage language, {
  final bool includeOther = true,
}) {
  final List<ImageField> imageFields = List<ImageField>.of(
    ImageFieldSmoothieExtension.orderedMain,
    growable: true,
  );
  if (includeOther) {
    imageFields.add(ImageField.OTHER);
  }
  final List<ProductImageData> result = <ProductImageData>[];
  for (final ImageField element in imageFields) {
    result.add(getProductImageData(product, element, language));
  }
  return result;
}

/// Returns data about the "best" image: for the language, or the default.
///
/// With [forceLanguage] you say you don't want the default as a fallback.
ProductImageData getProductImageData(
  final Product product,
  final ImageField imageField,
  final OpenFoodFactsLanguage language, {
  final bool forceLanguage = false,
}) {
  final ProductImage? productImage = getLocalizedProductImage(
    product,
    imageField,
    language,
  );
  final String? imageUrl;
  final OpenFoodFactsLanguage? imageLanguage;
  if (productImage != null) {
    // we found a localized version for this image
    imageLanguage = language;
    imageUrl = getLocalizedProductImageUrl(product, productImage);
  } else {
    imageLanguage = null;
    imageUrl = forceLanguage ? null : imageField.getUrl(product);
  }

  return ProductImageData(
    imageField: imageField,
    imageUrl: imageUrl,
    language: imageLanguage,
  );
}

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

List<MapEntry<ProductImageData, ImageProvider?>> getSelectedImages(
  final Product product,
  final OpenFoodFactsLanguage language,
) {
  final Map<ProductImageData, ImageProvider?> result =
      <ProductImageData, ImageProvider?>{};
  final List<ProductImageData> allProductImagesData =
      getProductMainImagesData(product, language, includeOther: false);
  for (final ProductImageData imageData in allProductImagesData) {
    result[imageData] = TransientFile.fromProductImageData(
      imageData,
      product.barcode!,
      language,
    ).getImageProvider();
  }
  return result.entries.toList();
}

String _getImageRoot() =>
    OpenFoodAPIConfiguration.globalQueryType == QueryType.PROD
        ? 'https://images.openfoodfacts.org/images/products'
        : 'https://images.openfoodfacts.net/images/products';

String getLocalizedProductImageUrl(
  final Product product,
  final ProductImage productImage,
) =>
    '${_getImageRoot()}/'
    '${ImageHelper.getBarcodeSubPath(product.barcode!)}/'
    '${ImageHelper.getProductImageFilename(productImage, imageSize: ImageSize.DISPLAY)}';

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
