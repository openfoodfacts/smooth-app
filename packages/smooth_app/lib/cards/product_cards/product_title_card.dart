import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_base_card.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_image.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/gallery_view/product_image_gallery_view.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class ProductTitleCard extends StatelessWidget {
  const ProductTitleCard(
    this.product,
    this.isSelectable, {
    this.heroTag,
    this.isPictureVisible = true,
    this.expandableBrands = false,
    this.dense = false,
    this.onRemove,
  });

  final Product product;
  final bool dense;
  final bool isSelectable;
  final String? heroTag;
  final OnRemoveCallback? onRemove;
  final bool isPictureVisible;
  final bool expandableBrands;

  @override
  Widget build(BuildContext context) {
    final Size imageSize = Size.square(
      MediaQuery.sizeOf(context).width * (dense ? 0.22 : 0.25),
    );

    Widget child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: DefaultTextStyle.of(context).style.fontSize! * 2.0,
          ),
          child: _ProductTitleCardName(selectable: isSelectable, dense: dense),
        ),
        const SizedBox(height: SMALL_SPACE),
        _ProductTitleCardBrands(dense: dense, expandable: expandableBrands),
        const SizedBox(height: 2.0),
        _ProductTitleCardQuantity(selectable: isSelectable),
      ],
    );

    if (isSelectable) {
      child = SelectionArea(child: child);
    }

    final List<Widget> children = <Widget>[
      Padding(
        padding: const EdgeInsetsDirectional.only(top: SMALL_SPACE),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (isPictureVisible)
                TooltipTheme(
                  data: TooltipThemeData(
                    verticalOffset: imageSize.width / 2,
                    preferBelow: true,
                  ),
                  child: ProductPicture.fromProduct(
                    product: product,
                    imageField: ImageField.FRONT,
                    fallbackUrl: product.imageFrontUrl,
                    allowAlternativeLanguage: true,
                    size: imageSize,
                    showObsoleteIcon: true,
                    imageFoundBorder: 1.0,
                    imageNotFoundBorder: 1.0,
                    heroTag: heroTag,
                    noImageBuilder: (_) => const PictureNotFound(),
                    onTap: !dense
                        ? () async => Navigator.push<void>(
                            context,
                            MaterialPageRoute<bool>(
                              builder: (BuildContext context) =>
                                  ProductImageGalleryView(product: product),
                            ),
                          )
                        : null,
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: SMALL_SPACE,
                    top: VERY_SMALL_SPACE,
                    bottom: VERY_SMALL_SPACE,
                  ),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    ];

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
  const _ProductTitleCardName({required this.selectable, this.dense = false});

  final bool dense;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Product product = context.watch<Product>();

    final TextStyle? textStyle = Theme.of(context).textTheme.headlineMedium;

    final (OpenFoodFactsLanguage lng, String productName) =
        getProductNameWithLanguage(product, appLocalizations);

    final Widget child = Text(
      productName,
      style: dense ? textStyle : textStyle?.copyWith(fontSize: 18.0),
      textAlign: TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    if (lng != ProductQuery.getLanguage()) {
      return Wrap(
        spacing: SMALL_SPACE,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          child,
          _ProductTitleChip(label: lng.offTag.toUpperCase()),
        ],
      );
    }

    return child;
  }
}

class _ProductTitleCardBrands extends StatefulWidget {
  const _ProductTitleCardBrands({required this.expandable, this.dense = false});

  final bool dense;
  final bool expandable;

  @override
  State<_ProductTitleCardBrands> createState() =>
      _ProductTitleCardBrandsState();
}

class _ProductTitleCardBrandsState extends State<_ProductTitleCardBrands> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Product product = context.watch<Product>();

    final List<String> brands = getProductBrandsList(product, appLocalizations);

    TextStyle style = Theme.of(context).textTheme.bodyMedium!;
    if (brands.isEmpty) {
      style = style.copyWith(fontStyle: FontStyle.italic);
    }

    final Widget child = Text(
      _getBrandsText(brands),
      maxLines: widget.dense ? 1 : 2,
      overflow: widget.dense ? TextOverflow.ellipsis : null,
      style: style,
      textAlign: TextAlign.start,
    );

    if (brands.length <= 1 || !widget.expandable) {
      return child;
    }

    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Wrap(
        spacing: SMALL_SPACE,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          child,
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: ClipRRect(
              child: Align(
                widthFactor: !_expanded ? 1.0 : 0.0,
                child: _ProductTitleChip(label: '+${brands.length - 1}'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBrandsText(List<String> brands) {
    if (brands.isEmpty) {
      return AppLocalizations.of(context).unknownBrand;
    }
    if (_expanded) {
      return brands.join(', ');
    }
    return brands.first;
  }
}

class _ProductTitleCardQuantity extends StatelessWidget {
  const _ProductTitleCardQuantity({required this.selectable});

  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final Product product = context.watch<Product>();

    TextStyle style = Theme.of(context).textTheme.bodyMedium!;
    if (product.quantity == null) {
      style = style.copyWith(fontStyle: FontStyle.italic);
    }

    return Text(
      product.quantity ?? AppLocalizations.of(context).unknownQuantity,
      style: style,
      textAlign: TextAlign.end,
    );
  }
}

class _ProductTitleChip extends StatelessWidget {
  const _ProductTitleChip({required this.label}) : assert(label.length > 0);

  final String label;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return SelectionContainer.disabled(
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: ANGULAR_BORDER_RADIUS,
          side: BorderSide(
            color: lightTheme
                ? extension.primaryMedium
                : extension.primaryNormal,
          ),
        ),
        color: lightTheme ? extension.primaryLight : extension.primarySemiDark,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: SMALL_SPACE,
            vertical: VERY_SMALL_SPACE,
          ),
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ),
    );
  }
}
