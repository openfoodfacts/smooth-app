import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/image/product_image_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

/// Displays a product image thumbnail with the upload date.
class ProductImageWidget extends StatelessWidget {
  const ProductImageWidget({
    required this.productImage,
    required this.barcode,
    required this.squareSize,
    required this.productType,
    this.imageSize,
    this.heroTag,
  });

  final ProductImage productImage;
  final String barcode;
  final double squareSize;
  final String? heroTag;
  final ProductType? productType;

  /// Allows to fetch the optimized version of the image
  final ImageSize? imageSize;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension colors =
        context.extension<SmoothColorsThemeExtension>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final DateFormat dateFormat =
        DateFormat.yMd(ProductQuery.getLanguage().offTag);

    final Widget image = SmoothImage(
      cacheHeight:
          (squareSize * MediaQuery.devicePixelRatioOf(context)).toInt(),
      width: squareSize,
      height: squareSize,
      imageProvider: NetworkImage(
        productImage.getUrl(
          barcode,
          uriHelper: ProductQuery.getUriProductHelper(
            productType: productType,
          ),
          imageSize: imageSize,
        ),
      ),
      heroTag: heroTag,
      rounded: false,
    );
    final DateTime? uploaded = productImage.uploaded;
    if (uploaded == null) {
      return image;
    }
    final bool expired = productImage.expired;
    final String date = dateFormat.format(uploaded);

    return Semantics(
      label: expired
          ? appLocalizations.product_image_outdated_accessibility_label(date)
          : appLocalizations.product_image_accessibility_label(date),
      excludeSemantics: true,
      button: true,
      child: SmoothCard(
        padding: EdgeInsets.zero,
        color: colors.primaryBlack,
        borderRadius: ANGULAR_BORDER_RADIUS,
        margin: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: ANGULAR_BORDER_RADIUS,
          child: Column(
            children: <Widget>[
              Expanded(
                child: image,
              ),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SMALL_SPACE,
                    vertical: VERY_SMALL_SPACE,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: AutoSizeText(
                          date,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      if (expired)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: VERY_SMALL_SPACE,
                          ),
                          child: icons.Outdated(
                            size: 18.0,
                            color: colors.warning,
                          ),
                        ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
