import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/pages/image/product_image_helper.dart';
import 'package:smooth_app/pages/image/uploaded_image_gallery.dart';
import 'package:smooth_app/pages/preferences/user_preferences_languages_list.dart';
import 'package:smooth_app/pages/product/helpers/pinch_to_zoom_indicator.dart';
import 'package:smooth_app/pages/product/owner_field_info.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/text/text_extensions.dart';

/// Full page display of a raw product image.
class ProductImageOtherPage extends StatefulWidget {
  const ProductImageOtherPage({
    required this.product,
    required this.language,
    required this.images,
    required this.currentImage,
    this.heroTag,
  }) : assert(images.length > 0);

  final Product product;
  final OpenFoodFactsLanguage language;
  final List<ProductImage> images;
  final ProductImage currentImage;
  final String? heroTag;

  @override
  State<ProductImageOtherPage> createState() => _ProductImageOtherPageState();

  static Future<ProductImagePageResult?> usePhotoAs({
    required BuildContext context,
    required Product product,
    required OpenFoodFactsLanguage language,
    required ProductImage productImage,
  }) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    final List<ImageField> imageFields =
        ImageFieldSmoothieExtension.getOrderedMainImageFields(
          product.productType,
        );

    final Widget existingPictureIcon = icons.Picture.check(
      color: extension.success,
      semanticLabel: appLocalizations.photo_already_exists,
    );
    final Widget missingPictureIcon = icons.Picture.error(
      color: extension.error,
      semanticLabel: appLocalizations.photo_missing,
    );

    final ImageField?
    selectedImageField = await showSmoothListOfChoicesModalSheet<ImageField>(
      context: context,
      title: appLocalizations.photo_viewer_use_picture_as_title(
        Languages().getNameInLanguage(language),
      ),
      padding: const EdgeInsetsDirectional.only(start: 15.0, end: 19.0),
      labels: imageFields
          .map((ImageField imageField) {
            return switch (imageField) {
              ImageField.FRONT => appLocalizations.photo_field_front,
              ImageField.INGREDIENTS =>
                appLocalizations.photo_field_ingredients,
              ImageField.NUTRITION => appLocalizations.photo_field_nutrition,
              ImageField.PACKAGING => appLocalizations.photo_field_packaging,
              ImageField.OTHER => throw UnimplementedError(),
            };
          })
          .toList(growable: false),
      values: imageFields,
      prefixIcons: imageFields
          .map((ImageField imageField) {
            return switch (imageField) {
              ImageField.FRONT => const icons.Milk.happy(),
              ImageField.INGREDIENTS => const icons.Ingredients.alt(),
              ImageField.NUTRITION => const icons.NutritionFacts(),
              ImageField.PACKAGING => const icons.Recycling(),
              ImageField.OTHER => throw UnimplementedError(),
            };
          })
          .toList(growable: false),
      suffixIcons: imageFields
          .map((ImageField imageField) {
            final bool exists = TransientFile.fromProduct(
              product,
              imageField,
              language,
            ).isImageAvailable();
            return exists ? existingPictureIcon : missingPictureIcon;
          })
          .toList(growable: false),
    );

    if (context.mounted && selectedImageField != null) {
      final CropParameters? cropParameters =
          await UploadedImageGallery.useExistingPhotoFor(
            context: context,
            rawImage: productImage,
            barcode: product.barcode!,
            imageField: selectedImageField,
            isLoggedInMandatory: true,
            productType: product.productType,
            language: language,
          );

      if (cropParameters != null) {
        return ProductImagePageResult(
          cropParameters: cropParameters,
          imageField: selectedImageField,
        );
      }
    }

    return null;
  }
}

// Tuned so the text of a nutrition table is readable.
const double _MAX_ZOOM_FACTOR = 4.0;

class _ProductImageOtherPageState extends State<ProductImageOtherPage> {
  late final PageController _pageController;
  late int _currentIndex;
  Set<int> _zoomedIndexes = const <int>{};

  @override
  void initState() {
    super.initState();
    _currentIndex = math.max(0, widget.images.indexOf(widget.currentImage));
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension colors = Theme.of(context)
        .extension<SmoothColorsThemeExtension>()!;
    final ProductImage currentImage = widget.images[_currentIndex];

    return SmoothScaffold(
      appBar: buildEditProductAppBar(
        context: context,
        title: appLocalizations.edit_product_form_item_photos_title,
        product: widget.product,
        actions: <Widget>[
          IconButton(
            onPressed: () => _usePhotoAs(),
            tooltip: appLocalizations.photo_viewer_action_use_picture_as,
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Positioned.fill(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return PhotoViewGallery.builder(
                  pageController: _pageController,
                  itemCount: widget.images.length,
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  onPageChanged: (int index) =>
                      setState(() => _currentIndex = index),
                  scaleStateChangedCallback: _onScaleStateChanged,
                  builder: (BuildContext context, int index) =>
                      _buildPage(index, constraints.biggest),
                );
              },
            ),
          ),
          Positioned(
            top: SMALL_SPACE,
            child: _ProductImagePageIndicator(
              index: _currentIndex,
              items: widget.images.length,
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
                    image: currentImage,
                    barcode: widget.product.barcode!,
                    productType: widget.product.productType,
                  ),
                  if (currentImage.expired)
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: _ProductImageOutdatedLabel(colors: colors),
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: SMALL_SPACE),
                  const PinchToZoomExplainer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  PhotoViewGalleryPageOptions _buildPage(int index, Size viewport) {
    final ProductImage image = widget.images[index];
    final String? heroTag = widget.heroTag;

    return PhotoViewGalleryPageOptions.customChild(
      child: _ProductImageZoomablePage(
        image: image,
        barcode: widget.product.barcode!,
        productType: widget.product.productType,
        showOriginal: _zoomedIndexes.contains(index),
      ),
      childSize: _computeChildSize(image, viewport),
      // Zooming out below the fit would block the swipe to the next photo.
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * _MAX_ZOOM_FACTOR,
      heroAttributes:
          image == widget.currentImage && heroTag != null && heroTag.isNotEmpty
          ? PhotoViewHeroAttributes(tag: heroTag)
          : null,
    );
  }

  // The gallery shares one callback between all the pages, without the page
  // index: the current page is the only one a gesture can zoom.
  void _onScaleStateChanged(PhotoViewScaleState state) {
    final int index = _currentIndex;
    if (state == PhotoViewScaleState.initial ||
        _zoomedIndexes.contains(index)) {
      return;
    }

    // This callback can be called while the gallery is laid out.
    if (WidgetsBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _markZoomed(index));
    } else {
      _markZoomed(index);
    }
  }

  void _markZoomed(int index) {
    if (mounted && !_zoomedIndexes.contains(index)) {
      setState(() => _zoomedIndexes = <int>{..._zoomedIndexes, index});
    }
  }

  Future<void> _usePhotoAs() async {
    final ProductImagePageResult? res = await ProductImageOtherPage.usePhotoAs(
      context: context,
      product: widget.product,
      language: widget.language,
      productImage: widget.images[_currentIndex],
    );

    if (mounted && res != null) {
      Navigator.of(context).pop<ProductImagePageResult>(res);
    }
  }
}

/// The size of the photo when it fits the [viewport].
///
/// It only depends on the photo ratio: the spinner and the error message are
/// part of the zoomable child, so a pixel size would shrink them.
/// Returns null when the photo size is unknown (the child then fills the
/// viewport).
Size? _computeChildSize(ProductImage image, Size viewport) {
  final int? width = image.width;
  final int? height = image.height;

  if (width == null ||
      height == null ||
      width <= 0 ||
      height <= 0 ||
      viewport.isEmpty) {
    return null;
  }

  return applyBoxFit(
    BoxFit.contain,
    Size(width.toDouble(), height.toDouble()),
    viewport,
  ).destination;
}

/// A resized photo, then the original one once the page has been zoomed.
///
/// Both layers share the same layout: the gallery keeps the zoom when the
/// original arrives only if the child size does not change.
class _ProductImageZoomablePage extends StatelessWidget {
  const _ProductImageZoomablePage({
    required this.image,
    required this.barcode,
    required this.productType,
    required this.showOriginal,
  });

  final ProductImage image;
  final String barcode;
  final ProductType? productType;
  final bool showOriginal;

  @override
  Widget build(BuildContext context) {
    final UriProductHelper uriHelper = ProductQuery.getUriProductHelper(
      productType: productType,
    );

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image.network(
          image.getUrl(barcode, uriHelper: uriHelper),
          fit: BoxFit.contain,
          loadingBuilder: (_, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress != null) {
              return const Center(child: CircularProgressIndicator.adaptive());
            } else {
              return child;
            }
          },
          errorBuilder: (_, _, _) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const icons.Warning(size: 48.0, color: Colors.red),
              const SizedBox(height: SMALL_SPACE),
              Text(AppLocalizations.of(context).error_loading_photo),
            ],
          ),
        ),
        if (showOriginal)
          Image.network(
            image.getUrl(
              barcode,
              uriHelper: uriHelper,
              imageSize: ImageSize.ORIGINAL,
            ),
            fit: BoxFit.contain,
            frameBuilder:
                (_, Widget child, int? frame, bool wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) {
                    return child;
                  }

                  return AnimatedOpacity(
                    opacity: frame == null ? 0.0 : 1.0,
                    duration: SmoothAnimationsDuration.short,
                    child: child,
                  );
                },
            errorBuilder: (_, _, _) => EMPTY_WIDGET,
          ),
      ],
    );
  }
}

class _ProductImageOutdatedLabel extends StatelessWidget {
  const _ProductImageOutdatedLabel({required this.colors});

  final SmoothColorsThemeExtension colors;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      child: SizedBox(
        height: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.error.withValues(alpha: 0.9),
            borderRadius: CIRCULAR_BORDER_RADIUS,
          ),
          child: Padding(
            padding: const EdgeInsets.all(SMALL_SPACE),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const icons.Outdated(size: 18.0, color: Colors.white),
                const SizedBox(width: SMALL_SPACE),
                Flexible(
                  child: Text(
                    AppLocalizations.of(context).product_image_outdated,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13.0, color: Colors.white),
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
    required this.productType,
  });

  final ProductImage image;
  final String barcode;
  final ProductType? productType;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String url =
        image.url ??
        image.getUrl(
          barcode,
          uriHelper: ProductQuery.getUriProductHelper(productType: productType),
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
          onTap: () => _showDetails(context, appLocalizations, url),
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
                  const icons.Info(size: 18.0, color: Colors.white),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: SMALL_SPACE,
                      bottom: 2.0,
                    ),
                    child: Text(
                      appLocalizations.photo_viewer_details_button,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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

  Future<dynamic> _showDetails(
    BuildContext context,
    AppLocalizations appLocalizations,
    String url,
  ) {
    final String originalUrl = image.getUrl(
      barcode,
      uriHelper: ProductQuery.getUriProductHelper(productType: productType),
      imageSize: ImageSize.ORIGINAL,
    );

    return showSmoothListOfItemsModalSheet(
      context: context,
      title: appLocalizations.photo_viewer_details_title,
      items: <ModalSheetItem>[
        ModalSheetItem(
          title: appLocalizations.photo_viewer_details_contributor_title,
          subTitle: image.contributor ?? '-',
          leading: const icons.Profile(),
          trailing: image.contributor?.startsWith('org') == true
              ? const OwnerFieldIcon()
              : null,
        ),
        ModalSheetItem(
          title: appLocalizations.photo_viewer_details_date_title,
          subTitle: image.uploaded != null
              ? MaterialLocalizations.of(context)
                    .formatFullDate(image.uploaded!)
                    .firstLetterInUppercase()
              : '-',
          leading: const icons.Calendar(),
        ),
        if (originalUrl.isNotEmpty)
          ModalSheetItem(
            title: appLocalizations.photo_viewer_details_original_title,
            subTitle: originalUrl,
            leading: const icons.ImageGallery(),
            trailing: const icons.ExternalLink(),
            onTap: () => LaunchUrlHelper.launchURL(originalUrl),
          ),
      ],
    );
  }
}

class _ProductImagePageIndicator extends StatelessWidget {
  const _ProductImagePageIndicator({required this.index, required this.items});

  final int index;
  final int items;

  @override
  Widget build(BuildContext context) {
    final String label = '${index + 1} / $items';

    return Semantics(
      value: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: CIRCULAR_BORDER_RADIUS,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: BALANCED_SPACE,
            vertical: SMALL_SPACE,
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class ProductImagePageResult {
  ProductImagePageResult({
    required this.cropParameters,
    required this.imageField,
  });

  final CropParameters cropParameters;
  final ImageField imageField;
}
