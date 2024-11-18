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
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';

SmoothAppBar buildEditProductAppBar({
  required final BuildContext context,
  required final String title,
  required final Product product,
  final PreferredSizeWidget? bottom,
  final List<Widget>? actions,
}) =>
    SmoothAppBar(
      centerTitle: false,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subTitle: Text(
        getProductNameAndBrands(product, AppLocalizations.of(context)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: actions,
      bottom: bottom,
      ignoreSemanticsForSubtitle: true,
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
  Widget? title,
  EdgeInsetsGeometry? titlePadding,
  required Widget body,
  EdgeInsetsGeometry? padding = EdgeInsets.zero,
  EdgeInsetsGeometry? margin = const EdgeInsets.symmetric(
    horizontal: SMALL_SPACE,
  ),
  BorderRadius? borderRadius,
}) {
  assert(
    (header != null && title == null) || header == null,
    "You can't pass a header and a title at the same time",
  );

  Widget child;

  if (title != null) {
    child = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _ProductSmoothCardTitle(
          title: title,
          padding: titlePadding,
        ),
        body,
      ],
    );
  } else if (header != null) {
    child = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        header,
        body,
      ],
    );
  } else {
    child = body;
  }

  return SmoothCard(
    margin: margin,
    padding: padding,
    borderRadius: borderRadius,
    child: child,
  );
}

class _ProductSmoothCardTitle extends StatelessWidget {
  const _ProductSmoothCardTitle({
    required this.title,
    this.padding,
  });

  final Widget title;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension colors =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;
    final EdgeInsetsGeometry effectivePadding = padding ??
        const EdgeInsetsDirectional.symmetric(
          vertical: MEDIUM_SPACE,
        );
    final TextStyle titleStyle =
        Theme.of(context).textTheme.displaySmall ?? const TextStyle();
    final double fontSize = titleStyle.fontSize ?? 15.0;

    return Container(
      constraints: BoxConstraints(
        minHeight:
            MEDIUM_SPACE * 2 + MediaQuery.textScalerOf(context).scale(fontSize),
      ),
      decoration: BoxDecoration(
        color: context.lightTheme()
            ? colors.primaryMedium
            : colors.primarySemiDark,
        borderRadius: const BorderRadius.vertical(
          top: ROUNDED_RADIUS,
        ),
      ),
      padding: effectivePadding,
      child: Center(
        child: DefaultTextStyle(
          style: titleStyle,
          textAlign: TextAlign.center,
          child: SizedBox(
            width: double.infinity,
            child: title,
          ),
        ),
      ),
    );
  }
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
  for (final ImageField imageField
      in ImageFieldSmoothieExtension.getOrderedMainImageFields(
          product.productType)) {
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
      imageId: productImage.imgid,
      imageField: imageField,
      imageUrl: productImage.getUrl(
        product.barcode!,
        imageSize: ImageSize.DISPLAY,
        uriHelper: ProductQuery.getUriProductHelper(
          productType: product.productType,
        ),
      ),
      language: language,
    );
  }
  return getEmptyProductImageData(imageField);
}

ProductImageData getEmptyProductImageData(final ImageField imageField) =>
    ProductImageData(
      imageField: imageField,
      imageId: null,
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

/// Returns an id-sorted list of raw images matching the imageSize if possible.
List<ProductImage> getRawProductImages(
  final Product product,
  final ImageSize imageSize,
) {
  final List<ProductImage>? rawImages = product.getRawImages();
  if (rawImages == null) {
    return <ProductImage>[];
  }
  final Map<int, ProductImage> map = <int, ProductImage>{};
  for (final ProductImage productImage in rawImages) {
    final int? imageId = int.tryParse(productImage.imgid!);
    if (imageId == null) {
// highly unlikely
      continue;
    }
    final ProductImage? previous = map[imageId];
    if (previous == null) {
      map[imageId] = productImage;
      continue;
    }
    final ImageSize? currentImageSize = productImage.size;
    if (currentImageSize == null) {
// highly unlikely
      continue;
    }
    final ImageSize? previousImageSize = previous.size;
    if (previousImageSize == imageSize) {
// we already have the best
      continue;
    }
    map[imageId] = productImage;
  }
  final List<ProductImage> result = List<ProductImage>.of(map.values);
  result.sort(
    (
      final ProductImage a,
      final ProductImage b,
    ) {
      final int result = (a.uploaded?.millisecondsSinceEpoch ?? 0).compareTo(
        b.uploaded?.millisecondsSinceEpoch ?? 0,
      );
      if (result != 0) {
        return result;
      }
      return (int.tryParse(a.imgid ?? '0') ?? 0).compareTo(
        int.tryParse(b.imgid ?? '0') ?? 0,
      );
    },
  );
  return result;
}
