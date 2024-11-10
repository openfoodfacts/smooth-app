import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_base_card.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/extension_on_text_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image/product_image_helper.dart';
import 'package:smooth_app/pages/product/product_image_gallery_view.dart';
import 'package:smooth_app/pages/product/product_page/new_product_page.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class ProductTitleCard extends StatelessWidget {
  const ProductTitleCard(
    this.product,
    this.isSelectable, {
    this.dense = false,
    this.isRemovable = true,
    this.onRemove,
  });

  final Product product;
  final bool dense;
  final bool isSelectable;
  final bool isRemovable;
  final OnRemoveCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final Widget trailing = _ProductTitleCardTrailing(
      removable: isRemovable,
      selectable: isSelectable,
      onRemove: onRemove,
    );

    final List<Widget> children;

    if (dense) {
      children = <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _ProductTitleCardName(
                selectable: isSelectable,
                dense: dense,
              ),
            ),
            trailing,
          ],
        ),
        _ProductTitleCardBrand(
          removable: isRemovable,
          selectable: isSelectable,
        ),
      ];
    } else {
      children = <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(top: SMALL_SPACE),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _ProductTitleCardPicture(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: SMALL_SPACE,
                      top: VERY_SMALL_SPACE,
                      bottom: VERY_SMALL_SPACE,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight:
                                DefaultTextStyle.of(context).style.fontSize! *
                                    2.0,
                          ),
                          child: _ProductTitleCardName(
                            selectable: isSelectable,
                            dense: dense,
                          ),
                        ),
                        const SizedBox(height: SMALL_SPACE),
                        _ProductTitleCardBrand(
                          removable: isRemovable,
                          selectable: isSelectable,
                        ),
                        const SizedBox(height: 2.0),
                        trailing,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return Provider<Product>.value(
      value: product,
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _ProductTitleCardName extends StatelessWidget {
  const _ProductTitleCardName({
    required this.selectable,
    this.dense = false,
  });

  final bool dense;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Product product = context.watch<Product>();

    final TextStyle? textStyle = Theme.of(context).textTheme.headlineMedium;

    return Text(
      getProductName(product, appLocalizations),
      style: dense ? textStyle : textStyle?.copyWith(fontSize: 18.0),
      textAlign: TextAlign.start,
      maxLines: dense ? 2 : null,
      overflow: TextOverflow.ellipsis,
    ).selectable(isSelectable: selectable);
  }
}

class _ProductTitleCardBrand extends StatelessWidget {
  const _ProductTitleCardBrand({
    required this.selectable,
    required this.removable,
  });

  final bool selectable;
  final bool removable;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Product product = context.watch<Product>();

    final String brands = getProductBrands(product, appLocalizations);
    final String quantity = product.quantity ?? '';

    final String subtitleText;

    if (removable && !selectable) {
      subtitleText = '$brands${quantity == '' ? '' : ', $quantity'}';
    } else {
      subtitleText = brands;
    }

    return Text(
      subtitleText,
      style: Theme.of(context).textTheme.bodyMedium,
      textAlign: TextAlign.start,
    ).selectable(isSelectable: selectable);
  }
}

class _ProductTitleCardTrailing extends StatelessWidget {
  const _ProductTitleCardTrailing({
    required this.selectable,
    required this.removable,
    required this.onRemove,
  });

  final bool selectable;
  final bool removable;
  final OnRemoveCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final Product product = context.watch<Product>();

    if (removable && !selectable) {
      return Align(
        alignment: AlignmentDirectional.centerEnd,
        child: ProductCardCloseButton(
          onRemove: onRemove,
          padding: const EdgeInsetsDirectional.only(
            start: SMALL_SPACE,
            top: SMALL_SPACE,
            bottom: SMALL_SPACE,
          ),
        ),
      );
    } else {
      return Text(
        product.quantity ?? '',
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.end,
      ).selectable(isSelectable: selectable);
    }
  }
}

class _ProductTitleCardPicture extends StatefulWidget {
  const _ProductTitleCardPicture();

  @override
  State<_ProductTitleCardPicture> createState() =>
      _ProductTitleCardPictureState();
}

class _ProductTitleCardPictureState extends State<_ProductTitleCardPicture> {
  bool _imageError = false;

  @override
  Widget build(BuildContext context) {
    final Product product = context.watch<Product>();
    final (ImageProvider, bool)? imageProvider = getImageProvider(product);
    final double size = MediaQuery.sizeOf(context).width * 0.25;

    final Widget inkWell = InkWell(
      onTap: () async => Navigator.push<void>(
        context,
        MaterialPageRoute<bool>(
          builder: (BuildContext context) => ProductImageGalleryView(
            product: product,
          ),
        ),
      ),
      splashColor: getSplashColor(context),
    );

    Widget child;
    if (_imageError) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);

      child = _ProductTitleCardPictureAssetsSvg(
        asset: 'assets/product/product_error.svg',
        semanticsLabel:
            appLocalizations.product_page_image_error_accessibility_label,
        text: appLocalizations.product_page_image_error,
        textStyle: TextStyle(
          color: Theme.of(context).extension<SmoothColorsThemeExtension>()!.red,
        ),
        size: size,
        child: inkWell,
      );
    } else if (imageProvider != null) {
      child = _ProductTitleCardPictureWithProvider(
        imageProvider: imageProvider.$1,
        outdated: imageProvider.$2,
        size: size,
        onError: () => setState(() => _imageError = true),
        child: inkWell,
      );
    } else {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);

      child = _ProductTitleCardPictureAssetsSvg(
        asset: 'assets/product/product_not_found_text.svg',
        semanticsLabel: appLocalizations
            .product_page_image_no_image_available_accessibility_label,
        text: appLocalizations.product_page_image_no_image_available,
        textStyle: TextStyle(
          color: Theme.of(context)
              .extension<SmoothColorsThemeExtension>()!
              .primaryDark,
        ),
        size: size,
        child: inkWell,
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(14.0)),
      child: child,
    );
  }

  Color? getSplashColor(BuildContext context) {
    try {
      return context.read<ProductPageCompatibility>().color?.withOpacity(0.5);
    } catch (_) {
      return null;
    }
  }

  /// Returns the image provider for the product.
  /// If this is a [TransientFile], the boolean indicates whether the image is
  /// outdated or not.
  (ImageProvider, bool)? getImageProvider(Product product) {
    final TransientFile transientFile = TransientFile.fromProductImageData(
      getProductImageData(
        product,
        ImageField.FRONT,
        ProductQuery.getLanguage(),
      ),
      product.barcode!,
      ProductQuery.getLanguage(),
    );
    final ImageProvider? imageProvider = transientFile.getImageProvider();

    if (imageProvider != null) {
      return (imageProvider, transientFile.expired);
    } else if (product.imageFrontUrl?.isNotEmpty == true) {
      return (NetworkImage(product.imageFrontUrl!), false);
    } else {
      return null;
    }
  }
}

class _ProductTitleCardPictureWithProvider extends StatelessWidget {
  const _ProductTitleCardPictureWithProvider({
    required this.imageProvider,
    required this.outdated,
    required this.size,
    required this.child,
    required this.onError,
  });

  final ImageProvider imageProvider;
  final bool outdated;
  final double size;
  final Widget child;
  final VoidCallback onError;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final Widget image = Semantics(
      label: appLocalizations.product_page_image_front_accessibility_label,
      image: true,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          children: <Widget>[
            ColoredBox(
              color: Colors.white,
              child: Opacity(
                opacity: context.lightTheme() ? 0.2 : 0.65,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                  child: Image(
                    image: imageProvider,
                    fit: BoxFit.cover,
                    height: size,
                    width: size,
                  ),
                ),
              ),
            ),
            Image(
              width: size,
              height: size,
              fit: BoxFit.contain,
              image: imageProvider,
              errorBuilder: (_, __, ___) {
                onError.call();
                return EMPTY_WIDGET;
              },
            ),
            Material(
              type: MaterialType.transparency,
              child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(14.0)),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1.0,
                    ),
                  ),
                  child: child),
            )
          ],
        ),
      ),
    );

    if (!outdated) {
      return Semantics(
        label: appLocalizations
            .product_page_image_front_outdated_message_accessibility_label,
        image: true,
        excludeSemantics: true,
        child: Tooltip(
          message: appLocalizations.product_page_image_front_outdated_message,
          verticalOffset: size / 2,
          preferBelow: true,
          child: Stack(
            children: <Widget>[
              image,
              Positioned.directional(
                bottom: 6.0,
                end: 6.0,
                textDirection: Directionality.of(context),
                child: const icons.Outdated(
                  size: 15.0,
                  color: Colors.black38,
                  shadow: Shadow(
                    color: Colors.white38,
                    blurRadius: 2.0,
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
}

class _ProductTitleCardPictureAssetsSvg extends StatelessWidget {
  const _ProductTitleCardPictureAssetsSvg({
    required this.asset,
    required this.semanticsLabel,
    required this.text,
    required this.textStyle,
    required this.size,
    required this.child,
  })  : assert(asset.length > 0),
        assert(size > 0.0);

  final String asset;
  final String semanticsLabel;
  final String? text;
  final TextStyle? textStyle;
  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      image: true,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: SvgPicture.asset(
                asset,
                width: size,
                height: size,
              ),
            ),
            if (text != null)
              Padding(
                padding: const EdgeInsets.all(SMALL_SPACE),
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
                  borderRadius: const BorderRadius.all(Radius.circular(14.0)),
                  border: Border.all(
                    color: (textStyle?.color ?? Theme.of(context).dividerColor)
                        .withOpacity(0.2),
                    width: 1.0,
                  ),
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
