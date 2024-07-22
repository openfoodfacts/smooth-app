import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image/product_image_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
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
                loadingBuilder: (
                  _,
                  final Widget child,
                  final ImageChunkEvent? loadingProgress,
                ) {
                  if (loadingProgress != null) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  } else {
                    return child;
                  }
                },
                errorBuilder: (_, __, ___) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const icons.Warning(
                      size: 48.0,
                      color: Colors.red,
                    ),
                    const SizedBox(height: SMALL_SPACE),
                    Text(AppLocalizations.of(context).error_loading_photo),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: SMALL_SPACE + MediaQuery.viewPaddingOf(context).bottom,
          left: SMALL_SPACE,
          right: SMALL_SPACE,
          child: IntrinsicHeight(
            child: Row(
              children: <Widget>[
                _ProductImageDetailsButton(
                  image: image,
                  barcode: barcode,
                ),
                const Spacer(),
                if (image.expired) _ProductImageOutdatedLabel(colors: colors),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductImageOutdatedLabel extends StatelessWidget {
  const _ProductImageOutdatedLabel({
    required this.colors,
  });

  final SmoothColorsThemeExtension colors;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      child: SizedBox(
        height: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.red.withOpacity(0.9),
            borderRadius: CIRCULAR_BORDER_RADIUS,
          ),
          child: Padding(
            padding: const EdgeInsets.all(SMALL_SPACE),
            child: Row(
              children: <Widget>[
                const icons.Outdated(
                  size: 18.0,
                  color: Colors.white,
                ),
                const SizedBox(width: SMALL_SPACE),
                Text(
                  AppLocalizations.of(context).product_image_outdated,
                  style: const TextStyle(
                    fontSize: 13.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductImageDetailsButton extends StatelessWidget {
  const _ProductImageDetailsButton({
    required this.image,
    required this.barcode,
  });

  final ProductImage image;
  final String barcode;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String url = image.url ??
        image.getUrl(
          barcode,
          uriHelper: ProductQuery.uriProductHelper,
        );

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.black45,
        borderRadius: CIRCULAR_BORDER_RADIUS,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: CIRCULAR_BORDER_RADIUS,
          onTap: () {
            showSmoothModalSheet(
                context: context,
                builder: (BuildContext context) {
                  return SmoothModalSheet(
                    title: appLocalizations.photo_viewer_details_title,
                    body: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(appLocalizations
                              .photo_viewer_details_contributor_title),
                          // TODO(g123k): add contributor
                          subtitle: const Text('TODO'),
                        ),
                        ListTile(
                          title: Text(
                              appLocalizations.photo_viewer_details_date_title),
                          subtitle: Text(image.uploaded != null
                              ? DateFormat.yMMMMEEEEd().format(image.uploaded!)
                              : '-'),
                        ),
                        ListTile(
                          title: Text(
                              appLocalizations.photo_viewer_details_size_title),
                          subtitle: Text(
                            image.width != null && image.height != null
                                ? appLocalizations
                                    .photo_viewer_details_size_value(
                                    image.width!,
                                    image.height!,
                                  )
                                : '-',
                          ),
                        ),
                        if (url.isNotEmpty)
                          ListTile(
                            title: Text(appLocalizations
                                .photo_viewer_details_url_title),
                            subtitle: Text(url),
                            trailing: const Icon(Icons.open_in_new_rounded),
                            onTap: () {
                              LaunchUrlHelper.launchURL(url);
                            },
                          ),
                        SizedBox(
                            height: MediaQuery.viewPaddingOf(context).bottom),
                      ],
                    ),
                  );
                });
          },
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: SMALL_SPACE,
              top: SMALL_SPACE,
              bottom: SMALL_SPACE,
              end: MEDIUM_SPACE,
            ),
            child: Semantics(
              label: appLocalizations
                  .photo_viewer_details_button_accessibility_label,
              button: true,
              excludeSemantics: true,
              child: Row(
                children: <Widget>[
                  const icons.Info(
                    size: 15.0,
                    color: Colors.white,
                  ),
                  const SizedBox(width: SMALL_SPACE),
                  Text(
                    appLocalizations.photo_viewer_details_button,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
