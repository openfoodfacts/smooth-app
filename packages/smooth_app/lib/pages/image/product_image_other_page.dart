import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/pages/image/product_image_helper.dart';
import 'package:smooth_app/pages/image/uploaded_image_gallery.dart';
import 'package:smooth_app/pages/preferences/user_preferences_languages_list.dart';
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
  });

  final Product product;
  final OpenFoodFactsLanguage language;
  final List<ProductImage> images;
  final ProductImage currentImage;
  final String? heroTag;

  @override
  State<ProductImageOtherPage> createState() => _ProductImageOtherPageState();

  static Future<ProductImagePageResult?> usePhotoAs({
    required final BuildContext context,
    required final Product product,
    required final OpenFoodFactsLanguage language,
    required final ProductImage productImage,
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
          .map((final ImageField imageField) {
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
          .map((final ImageField imageField) {
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
          .map((final ImageField imageField) {
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
              child: PageView(
                controller: _pageController,
                children: widget.images
                    .map((final ProductImage image) {
                      return _ProductImageViewer(
                        image: image,
                        barcode: widget.product.barcode!,
                        language: widget.language,
                        heroTag: widget.currentImage == image
                            ? widget.heroTag
                            : null,
                        productType: widget.product.productType,
                      );
                    })
                    .toList(growable: false),
              ),
            ),
            Positioned(
              top: SMALL_SPACE,
              child: _ProductImagePageIndicator(items: widget.images.length),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _usePhotoAs() async {
    final ProductImagePageResult? res = await ProductImageOtherPage.usePhotoAs(
      context: context,
      product: widget.product,
      language: widget.language,
      productImage: widget.currentImage,
    );

    if (mounted && res != null) {
      Navigator.of(context).pop<ProductImagePageResult>(res);
    }
  }
}

class _ProductImageViewer extends StatelessWidget {
  const _ProductImageViewer({
    required this.image,
    required this.barcode,
    required this.language,
    required this.productType,
    this.heroTag,
  });

  final ProductImage image;
  final String barcode;
  final OpenFoodFactsLanguage language;
  final String? heroTag;
  final ProductType? productType;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension colors = Theme.of(
      context,
    ).extension<SmoothColorsThemeExtension>()!;

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
                    uriHelper: ProductQuery.getUriProductHelper(
                      productType: productType,
                    ),
                  ),
                ),
                fit: BoxFit.contain,
                loadingBuilder:
                    (
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
                errorBuilder: (_, _, _) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const icons.Warning(size: 48.0, color: Colors.red),
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
                  productType: productType,
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
              children: <Widget>[
                const icons.Outdated(size: 18.0, color: Colors.white),
                const SizedBox(width: SMALL_SPACE),
                Text(
                  AppLocalizations.of(context).product_image_outdated,
                  style: const TextStyle(fontSize: 13.0, color: Colors.white),
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
              ? MaterialLocalizations.of(
                  context,
                ).formatFullDate(image.uploaded!).firstLetterInUppercase()
              : '-',
          leading: const icons.Calendar(),
        ),
        ModalSheetItem(
          title: appLocalizations.photo_viewer_details_size_title,
          subTitle: image.width != null && image.height != null
              ? appLocalizations.photo_viewer_details_size_value(
                  image.width!,
                  image.height!,
                )
              : '-',
          leading: const icons.Move(),
        ),
        if (url.isNotEmpty)
          ModalSheetItem(
            title: appLocalizations.photo_viewer_details_url_title,
            subTitle: url,
            leading: const icons.ImageGallery(),
            trailing: const icons.ExternalLink(),
            onTap: () => LaunchUrlHelper.launchURL(url),
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
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: CIRCULAR_BORDER_RADIUS,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: BALANCED_SPACE,
          vertical: SMALL_SPACE,
        ),
        child: Selector<PageController, int>(
          selector: (_, PageController value) {
            if (!value.position.hasPixels) {
              return 0;
            }

            final int page = (value.offset / value.position.viewportDimension)
                .round();
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
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            );
          },
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
