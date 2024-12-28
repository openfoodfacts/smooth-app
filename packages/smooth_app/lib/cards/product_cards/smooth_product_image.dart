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
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/pages/image/product_image_helper.dart';
import 'package:smooth_app/pages/product/owner_field_info.dart';
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
    bool showObsoleteIcon = false,
    bool showOwnerIcon = false,
    BorderRadius? borderRadius,
    double imageFoundBorder = 0.0,
    double imageNotFoundBorder = 0.0,
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
          imageFoundBorder: imageFoundBorder,
          imageNotFoundBorder: imageNotFoundBorder,
          errorTextStyle: errorTextStyle,
          showObsoleteIcon: showObsoleteIcon,
          showOwnerIcon: showOwnerIcon,
        );

  ProductPicture.fromTransientFile({
    required TransientFile transientFile,
    required Size size,
    OpenFoodFactsLanguage? language,
    Product? product,
    ImageField? imageField,
    String? fallbackUrl,
    VoidCallback? onTap,
    String? heroTag,
    bool showObsoleteIcon = false,
    bool showOwnerIcon = false,
    BorderRadius? borderRadius,
    double imageFoundBorder = 0.0,
    double imageNotFoundBorder = 0.0,
    TextStyle? errorTextStyle,
  }) : this._(
          transientFile: transientFile,
          product: product,
          imageField: imageField,
          language: language,
          size: size,
          fallbackUrl: fallbackUrl,
          heroTag: heroTag,
          onTap: onTap,
          borderRadius: borderRadius,
          imageFoundBorder: imageFoundBorder,
          imageNotFoundBorder: imageNotFoundBorder,
          errorTextStyle: errorTextStyle,
          showObsoleteIcon: showObsoleteIcon,
          showOwnerIcon: showOwnerIcon,
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
    this.showOwnerIcon = false,
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

  /// Show the owner icon on top of the image
  final bool showOwnerIcon;

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
            appLocalizations.product_image_error_accessibility_label(
          widget.imageField?.getPictureAccessibilityLabel(appLocalizations) ??
              appLocalizations.product_image_front_accessibility_label,
        ),
        text: appLocalizations.product_image_error,
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
        imageField: widget.imageField,
        outdated: imageProvider.$2,
        locked: widget.imageField != null &&
            widget.product?.isImageLocked(
                  widget.imageField!,
                  widget.language ?? ProductQuery.getLanguage(),
                ) ==
                true,
        heroTag: widget.heroTag,
        size: widget.size,
        showOutdated: widget.showObsoleteIcon,
        showOwner: widget.showOwnerIcon,
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
      return context
          .read<ProductPageCompatibility>()
          .color
          ?.withValues(alpha: 0.5);
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
    required this.locked,
    required this.size,
    required this.child,
    required this.onError,
    required this.showOutdated,
    required this.showOwner,
    required this.border,
    this.imageField,
    this.borderRadius,
    this.heroTag,
  });

  final ImageProvider imageProvider;
  final ImageField? imageField;
  final bool outdated;
  final bool locked;
  final Size size;
  final Widget? child;
  final VoidCallback onError;
  final bool showOutdated;
  final bool showOwner;
  final BorderRadius? borderRadius;
  final double border;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool lightTheme = context.lightTheme();

    final Widget image = Semantics(
      label: imageField?.getPictureAccessibilityLabel(appLocalizations) ??
          appLocalizations.product_image_front_accessibility_label,
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

    final Widget? iconOutdated = showOutdated && outdated
        ? _OutdatedProductPictureIcon(
            appLocalizations: appLocalizations,
            borderRadius: borderRadius,
            imageField: imageField,
          )
        : null;

    final Widget? iconLocked = showOwner && locked
        ? _LockedProductPictureIcon(
            appLocalizations: appLocalizations,
            borderRadius: borderRadius,
            imageField: imageField,
          )
        : null;

    Widget? icons;
    if (iconOutdated == null) {
      icons = iconLocked;
    } else if (iconLocked == null) {
      icons = iconOutdated;
    } else {
      icons = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          iconOutdated,
          const SizedBox(height: SMALL_SPACE),
          iconLocked,
        ],
      );
    }

    if (icons != null) {
      return Stack(
        children: <Widget>[
          image,
          Positioned.directional(
            bottom: 2.0,
            end: 2.0,
            textDirection: Directionality.of(context),
            child: IconTheme(
              data: const IconThemeData(
                color: Color(0xFF616161),
              ),
              child: icons,
            ),
          ),
        ],
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

class _OutdatedProductPictureIcon extends StatelessWidget {
  const _OutdatedProductPictureIcon({
    required this.appLocalizations,
    required this.borderRadius,
    this.imageField,
  });

  final ImageField? imageField;
  final AppLocalizations appLocalizations;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return _ProductPictureIcon(
      semanticsLabel:
          appLocalizations.product_image_outdated_message_accessibility_label(
        imageField?.getPictureAccessibilityLabel(appLocalizations) ??
            appLocalizations.product_image_front_accessibility_label,
      ),
      icon: const icons.Outdated(size: 15.0),
      padding: const EdgeInsetsDirectional.only(
        top: 4.5,
        bottom: 5.5,
        start: 5.0,
        end: 5.0,
      ),
      borderRadius: borderRadius,
    );
  }
}

class _LockedProductPictureIcon extends StatelessWidget {
  const _LockedProductPictureIcon({
    required this.appLocalizations,
    required this.borderRadius,
    this.imageField,
  });

  final ImageField? imageField;
  final AppLocalizations appLocalizations;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return _ProductPictureIcon(
      semanticsLabel:
          appLocalizations.product_image_locked_message_accessibility_label(
        imageField?.getPictureAccessibilityLabel(appLocalizations) ??
            appLocalizations.product_image_front_accessibility_label,
      ),
      icon: IconTheme.merge(
        data: const IconThemeData(size: 16.0),
        child: const OwnerFieldIcon(),
      ),
      padding: const EdgeInsetsDirectional.only(
        top: 4.5,
        bottom: 5.5,
        start: 5.0,
        end: 5.0,
      ),
      borderRadius: borderRadius,
    );
  }
}

class _ProductPictureIcon extends StatelessWidget {
  const _ProductPictureIcon({
    required this.semanticsLabel,
    required this.icon,
    required this.padding,
    this.borderRadius,
  });

  final String semanticsLabel;
  final Widget icon;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      image: true,
      excludeSemantics: true,
      child: Tooltip(
        message: semanticsLabel,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: borderRadius,
          ),
          child: Padding(
            padding: padding,
            child: icon,
          ),
        ),
      ),
    );
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
                              .withValues(alpha: 0.2),
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
