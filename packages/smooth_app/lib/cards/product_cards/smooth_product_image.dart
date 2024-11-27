import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/image/product_image_helper.dart';
import 'package:smooth_app/pages/product/product_page/new_product_page.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class ProductPicture extends StatefulWidget {
  ProductPicture.fromProduct({
    required Product product,
    required ImageField imageField,
    required Size size,
    OpenFoodFactsLanguage? language,
    String? fallbackUrl,
    VoidCallback? onTap,
    String? heroTag,
    bool? showObsoleteIcon,
    BorderRadius? borderRadius,
    double? imageFoundBorder,
    double? imageNotFoundBorder,
    TextStyle? errorTextStyle,
  }) : this._(
          transientFile: null,
          product: product,
          imageField: imageField,
          language: language ?? ProductQuery.getLanguage(),
          size: size,
          fallbackUrl: fallbackUrl,
          heroTag: heroTag,
          onTap: onTap,
          borderRadius: borderRadius,
          imageFoundBorder: imageFoundBorder ?? 0.0,
          imageNotFoundBorder: imageNotFoundBorder ?? 0.0,
          errorTextStyle: errorTextStyle,
          showObsoleteIcon: showObsoleteIcon ?? false,
        );

  ProductPicture.fromTransientFile({
    required TransientFile transientFile,
    required Size size,
    String? fallbackUrl,
    VoidCallback? onTap,
    String? heroTag,
    bool? showObsoleteIcon,
    BorderRadius? borderRadius,
    double? imageFoundBorder,
    double? imageNotFoundBorder,
    TextStyle? errorTextStyle,
  }) : this._(
          transientFile: transientFile,
          product: null,
          imageField: null,
          language: null,
          size: size,
          fallbackUrl: fallbackUrl,
          heroTag: heroTag,
          onTap: onTap,
          borderRadius: borderRadius,
          imageFoundBorder: imageFoundBorder ?? 0.0,
          imageNotFoundBorder: imageNotFoundBorder ?? 0.0,
          errorTextStyle: errorTextStyle,
          showObsoleteIcon: showObsoleteIcon ?? false,
        );

  ProductPicture._({
    required this.product,
    required this.imageField,
    required this.language,
    required this.transientFile,
    required this.size,
    this.fallbackUrl,
    this.heroTag,
    this.onTap,
    this.borderRadius,
    this.imageFoundBorder = 0.0,
    this.imageNotFoundBorder = 0.0,
    this.errorTextStyle,
    this.showObsoleteIcon = false,
    super.key,
  })  : assert(imageFoundBorder >= 0.0),
        assert(imageNotFoundBorder >= 0.0),
        assert(heroTag == null || heroTag.isNotEmpty),
        assert(size.width >= 0.0 && size.height >= 0.0);

  final Product? product;
  final ImageField? imageField;
  final OpenFoodFactsLanguage? language;

  final TransientFile? transientFile;
  final Size size;
  final String? fallbackUrl;
  final VoidCallback? onTap;

  final String? heroTag;

  /// Show the obsolete icon on top of the image
  final bool showObsoleteIcon;

  /// Rounded borders around the image
  final BorderRadius? borderRadius;
  final double imageFoundBorder;
  final double imageNotFoundBorder;

  /// Style when there is no image/an error
  final TextStyle? errorTextStyle;

  @override
  State<ProductPicture> createState() => _ProductPictureState();

  static String generateHeroTag(String barcode, ImageField imageField) =>
      'photo_${barcode}_${imageField.offTag}';
}

class _ProductPictureState extends State<ProductPicture> {
  bool _imageError = false;

  @override
  Widget build(BuildContext context) {
    final (ImageProvider?, bool)? imageProvider = _getImageProvider(
      widget.product,
      widget.transientFile,
    );

    final Widget? inkWell = widget.onTap != null
        ? InkWell(
            onTap: widget.onTap,
            splashColor: _getSplashColor(context),
          )
        : null;

    Widget child;
    if (_imageError) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);

      child = _ProductPictureAssetsSvg(
        asset: 'assets/product/product_error.svg',
        semanticsLabel:
            appLocalizations.product_page_image_error_accessibility_label,
        text: appLocalizations.product_page_image_error,
        textStyle: TextStyle(
          color: context.extension<SmoothColorsThemeExtension>().red,
        ).merge(widget.errorTextStyle ?? const TextStyle()),
        size: widget.size,
        borderRadius: widget.borderRadius,
        border: widget.imageNotFoundBorder,
        child: inkWell,
      );
    } else if (imageProvider?.$1 != null) {
      child = _ProductPictureWithImageProvider(
        imageProvider: imageProvider!.$1!,
        outdated: imageProvider.$2,
        heroTag: widget.heroTag,
        size: widget.size,
        showOutdated: widget.showObsoleteIcon,
        borderRadius: widget.borderRadius,
        border: widget.imageFoundBorder,
        onError: () {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            setState(() => _imageError = true);
          });
        },
        child: inkWell,
      );
    } else {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);

      child = _ProductPictureAssetsSvg(
        asset: 'assets/product/product_not_found_text.svg',
        semanticsLabel: appLocalizations
            .product_page_image_no_image_available_accessibility_label,
        text: appLocalizations.product_page_image_no_image_available,
        textStyle: TextStyle(
          color: context.extension<SmoothColorsThemeExtension>().primaryDark,
        ).merge(widget.errorTextStyle ?? const TextStyle()),
        borderRadius: widget.borderRadius,
        border: widget.imageNotFoundBorder,
        size: widget.size,
        child: inkWell,
      );
    }

    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: child,
      );
    } else {
      return child;
    }
  }

  /// The splash tries to use the product compatibility as the accent color
  Color? _getSplashColor(BuildContext context) {
    try {
      return context.read<ProductPageCompatibility>().color?.withOpacity(0.5);
    } catch (_) {
      return null;
    }
  }

  /// Returns the image provider for the product.
  /// If this is a [TransientFile], the boolean indicates whether the image is
  /// outdated or not.
  (ImageProvider?, bool)? _getImageProvider(
    Product? product,
    TransientFile? transientFile,
  ) {
    if (transientFile != null) {
      return (transientFile.getImageProvider(), transientFile.expired);
    }

    final TransientFile productTransientFile = TransientFile.fromProduct(
      product!,
      widget.imageField!,
      widget.language ?? ProductQuery.getLanguage(),
    );
    final ImageProvider? imageProvider =
        productTransientFile.getImageProvider();

    if (imageProvider != null) {
      return (imageProvider, productTransientFile.expired);
    } else if (widget.fallbackUrl?.isNotEmpty == true) {
      return (NetworkImage(widget.fallbackUrl!), false);
    } else {
      return null;
    }
  }
}

class _ProductPictureWithImageProvider extends StatelessWidget {
  const _ProductPictureWithImageProvider({
    required this.imageProvider,
    required this.outdated,
    required this.size,
    required this.child,
    required this.onError,
    required this.showOutdated,
    required this.border,
    this.borderRadius,
    this.heroTag,
  });

  final ImageProvider imageProvider;
  final bool outdated;
  final Size size;
  final Widget? child;
  final VoidCallback onError;
  final bool showOutdated;
  final BorderRadius? borderRadius;
  final double border;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool lightTheme = context.lightTheme();

    final Widget image = Semantics(
      label: appLocalizations.product_page_image_front_accessibility_label,
      image: true,
      excludeSemantics: true,
      child: SizedBox.fromSize(
        size: size,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: ColoredBox(
                color: lightTheme ? Colors.white : Colors.black,
                child: ClipRRect(
                  child: Opacity(
                    opacity: lightTheme ? 0.3 : 0.55,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                      child: Image(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: _buildImage(),
            ),
            if (child != null)
              Positioned.fill(
                child: Material(
                  type: MaterialType.transparency,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      border: border > 0.0
                          ? Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 1.0,
                            )
                          : null,
                    ),
                    child: child,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (showOutdated && outdated) {
      return Semantics(
        label: appLocalizations
            .product_page_image_front_outdated_message_accessibility_label,
        image: true,
        excludeSemantics: true,
        child: Tooltip(
          message: appLocalizations.product_page_image_front_outdated_message,
          child: Stack(
            children: <Widget>[
              image,
              Positioned.directional(
                bottom: 2.0,
                end: 2.0,
                textDirection: Directionality.of(context),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: borderRadius,
                  ),
                  child: const Padding(
                    padding: EdgeInsetsDirectional.only(
                      top: 4.5,
                      bottom: 5.5,
                      start: 5.0,
                      end: 5.0,
                    ),
                    child: icons.Outdated(
                      size: 15.0,
                      color: Color(0xFF616161),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return image;
  }

  Widget _buildImage() {
    final Widget image = Image(
      width: size.width,
      height: size.height,
      fit: BoxFit.contain,
      image: imageProvider,
      loadingBuilder: (_, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      errorBuilder: (_, __, ___) {
        onError.call();
        return EMPTY_WIDGET;
      },
    );

    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: image,
      );
    } else {
      return image;
    }
  }
}

class _ProductPictureAssetsSvg extends StatelessWidget {
  _ProductPictureAssetsSvg({
    required this.asset,
    required this.semanticsLabel,
    required this.text,
    required this.textStyle,
    required this.size,
    required this.child,
    this.borderRadius,
    this.border = 0.0,
  })  : assert(asset.isNotEmpty),
        assert(size.width > 0.0 && size.height > 0.0);

  final String asset;
  final String semanticsLabel;
  final String? text;
  final TextStyle? textStyle;
  final Size size;
  final Widget? child;
  final BorderRadius? borderRadius;
  final double border;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      image: true,
      excludeSemantics: true,
      child: SizedBox.fromSize(
        size: size,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: SvgPicture.asset(
                asset,
                width: size.width,
                height: size.height,
                fit: BoxFit.cover,
              ),
            ),
            if (text != null)
              Padding(
                padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
                child: AutoSizeText(
                  text!,
                  maxLines: 2,
                  minFontSize: 5.0,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ).merge(textStyle),
                ),
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  border: border > 0.0
                      ? Border.all(
                          color: (textStyle?.color ??
                                  Theme.of(context).dividerColor)
                              .withOpacity(0.2),
                          width: 1.0,
                        )
                      : null,
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
