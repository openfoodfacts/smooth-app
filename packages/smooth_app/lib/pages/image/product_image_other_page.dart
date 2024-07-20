import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Full page display of a raw product image.
class ProductImageOtherPage extends StatefulWidget {
  const ProductImageOtherPage({
    required this.product,
    required this.images,
    required this.currentImage,
    this.heroTag,
  });

  final Product product;
  final List<ProductImage> images;
  final ProductImage currentImage;
  final String? heroTag;

  @override
  State<ProductImageOtherPage> createState() => _ProductImageOtherPageState();
}

class _ProductImageOtherPageState extends State<ProductImageOtherPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.images.indexOf(widget.currentImage),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return ChangeNotifierProvider<PageController>.value(
      value: _pageController,
      child: SmoothScaffold(
        appBar: buildEditProductAppBar(
          context: context,
          title: appLocalizations.edit_product_form_item_photos_title,
          product: widget.product,
        ),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Positioned.fill(
              child: PageView(
                controller: _pageController,
                children: widget.images.map(
                  (final ProductImage image) {
                    return _ProductImageViewer(
                      image: image,
                      barcode: widget.product.barcode!,
                      heroTag:
                          widget.currentImage == image ? widget.heroTag : null,
                    );
                  },
                ).toList(growable: false),
              ),
            ),
            Positioned(
              top: SMALL_SPACE,
              child: _ProductImagePageIndicator(
                items: widget.images.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImageViewer extends StatelessWidget {
  const _ProductImageViewer({
    required this.image,
    required this.barcode,
    this.heroTag,
  });

  final ProductImage image;
  final String barcode;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension colors =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: HeroMode(
            enabled: heroTag?.isNotEmpty == true,
            child: Hero(
              tag: heroTag ?? '',
              child: Image(
                image: NetworkImage(
                  image.getUrl(
                    barcode,
                    uriHelper: ProductQuery.uriProductHelper,
                  ),
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned.directional(
          textDirection: Directionality.of(context),
          end: SMALL_SPACE,
          bottom: SMALL_SPACE,
          child: Offstage(
            // TODOoffstage: image.expired,
            offstage: false,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.red.withOpacity(0.9),
                borderRadius: CIRCULAR_BORDER_RADIUS,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(1.0, 1.0),
                    blurRadius: 2.0,
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(SMALL_SPACE),
                child: Row(
                  children: <Widget>[
                    Outdated(
                      size: 18.0,
                      color: Colors.white,
                    ),
                    SizedBox(width: SMALL_SPACE),
                    Text(
                      'This photo may be outdated',
                      style: TextStyle(
                        fontSize: 13.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductImagePageIndicator extends StatelessWidget {
  const _ProductImagePageIndicator({required this.items});

  final int items;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: CIRCULAR_BORDER_RADIUS,
      ),
      child: Padding(
        padding: const EdgeInsets.all(SMALL_SPACE),
        child: Selector<PageController, int>(
          selector: (_, PageController value) {
            if (!value.position.hasPixels) {
              return 0;
            }

            final int page =
                (value.offset / value.position.viewportDimension).round();
            if (page < 0) {
              return 0;
            } else if (page > items - 1) {
              return items - 1;
            } else {
              return page;
            }
          },
          shouldRebuild: (int previous, int next) => previous != next,
          builder: (BuildContext context, int progress, _) {
            return Text(
              '${progress + 1} / $items',
              style: const TextStyle(color: Colors.white),
            );
          },
        ),
      ),
    );
  }
}
