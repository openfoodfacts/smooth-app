import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_image.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/pages/image/product_image_helper.dart';
import 'package:smooth_app/pages/product/product_image_swipeable_view.dart';
import 'package:smooth_app/resources/app_animations.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class PhotoRow extends StatelessWidget {
  const PhotoRow({
    required this.position,
    required this.product,
    required this.language,
    required this.imageField,
  });

  static double itemHeight = 55.0;

  final int position;
  final Product product;
  final OpenFoodFactsLanguage language;
  final ImageField imageField;

  @override
  Widget build(BuildContext context) {
    final TransientFile transientFile = _getTransientFile(imageField);

    final bool expired = transientFile.expired;

    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String label = imageField.getProductImageTitle(appLocalizations);

    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    return Semantics(
      image: true,
      button: true,
      label: expired
          ? appLocalizations.product_image_outdated_accessibility_label(label)
          : label,
      excludeSemantics: true,
      child: Material(
        elevation: 1.0,
        type: MaterialType.card,
        color: extension.primaryBlack,
        borderRadius: ANGULAR_BORDER_RADIUS,
        child: InkWell(
          borderRadius: ANGULAR_BORDER_RADIUS,
          onTap: () => _openImage(
            context: context,
            initialImageIndex: position,
          ),
          child: ClipRRect(
            borderRadius: ANGULAR_BORDER_RADIUS,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: itemHeight,
                  child: Row(
                    children: <Widget>[
                      _PhotoRowIndicator(transientFile: transientFile),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SMALL_SPACE,
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: AutoSizeText(
                                  label,
                                  maxLines: 2,
                                  minFontSize: 10.0,
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    height: 1.2,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: SMALL_SPACE),
                              CircledArrow.right(
                                color: extension.primaryDark,
                                type: CircledArrowType.normal,
                                circleColor: Colors.white,
                                size: 20.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints box) {
                            return ProductPicture.fromTransientFile(
                              transientFile: transientFile,
                              size: Size(box.maxWidth, box.maxHeight),
                              onTap: null,
                              errorTextStyle: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                              heroTag: ProductPicture.generateHeroTag(
                                product.barcode!,
                                imageField,
                              ),
                            );
                          },
                        ),
                      ),
                      if (transientFile.isImageAvailable() &&
                          !transientFile.isServerImage())
                        const Center(
                          child: CloudUploadAnimation.circle(size: 50.0),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openImage({
    required BuildContext context,
    required int initialImageIndex,
  }) async =>
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ProductImageSwipeableView(
            initialImageIndex: initialImageIndex,
            product: product,
            isLoggedInMandatory: true,
            initialLanguage: language,
          ),
        ),
      );

  TransientFile _getTransientFile(
    final ImageField imageField,
  ) =>
      TransientFile.fromProduct(
        product,
        imageField,
        language,
      );
}

class _PhotoRowIndicator extends StatelessWidget {
  const _PhotoRowIndicator({
    required this.transientFile,
  });

  final TransientFile transientFile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30.0,
      height: double.infinity,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: ANGULAR_RADIUS,
          ),
          color: _getColor(
            context.extension<SmoothColorsThemeExtension>(),
          ),
        ),
        child: Center(child: child()),
      ),
    );
  }

  Widget? child() {
    if (transientFile.isImageAvailable()) {
      if (transientFile.expired) {
        return const Outdated(
          size: 18.0,
          color: Colors.white,
        );
      } else {
        return null;
      }
    } else {
      return const Warning(
        size: 15.0,
        color: Colors.white,
      );
    }
  }

  Color _getColor(SmoothColorsThemeExtension extension) {
    if (transientFile.isImageAvailable()) {
      if (transientFile.expired) {
        return extension.orange;
      } else {
        return extension.green;
      }
    } else {
      return extension.red;
    }
  }
}
