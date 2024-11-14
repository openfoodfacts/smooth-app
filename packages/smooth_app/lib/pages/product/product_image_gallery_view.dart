import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_image.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/language_selector.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_app_logo.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image/product_image_gallery_other_view.dart';
import 'package:smooth_app/pages/image/product_image_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/product_image_swipeable_view.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_animations.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/widgets/slivers.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Display of the main 4 pictures of a product, with edit options.
class ProductImageGalleryView extends StatefulWidget {
  const ProductImageGalleryView({
    required this.product,
  });

  final Product product;

  @override
  State<ProductImageGalleryView> createState() =>
      _ProductImageGalleryViewState();
}

class _ProductImageGalleryViewState extends State<ProductImageGalleryView>
    with UpToDateMixin {
  late OpenFoodFactsLanguage _language;
  late final List<ImageField> _mainImageFields;
  bool _clickedOtherPictureButton = false;

  @override
  void initState() {
    super.initState();
    initUpToDate(widget.product, context.read<LocalDatabase>());
    _language = ProductQuery.getLanguage();
    _mainImageFields = ImageFieldSmoothieExtension.getOrderedMainImageFields(
      widget.product.productType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    refreshUpToDate();
    return SmoothSharedAnimationController(
      child: SmoothScaffold(
        appBar: buildEditProductAppBar(
          context: context,
          title: appLocalizations.edit_product_form_item_photos_title,
          product: upToDateProduct,
          bottom: PreferredSize(
            preferredSize: const Size(double.infinity, 50.0),
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 55.0),
              child: LanguageSelector(
                setLanguage: (final OpenFoodFactsLanguage? newLanguage) async {
                  if (newLanguage == null || newLanguage == _language) {
                    return;
                  }
                  setState(() => _language = newLanguage);
                },
                displayedLanguage: _language,
                selectedLanguages: null,
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 13.0,
                  vertical: SMALL_SPACE,
                ),
              ),
            ),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                AnalyticsHelper.trackProductEdit(
                  AnalyticsEditEvents.photos,
                  upToDateProduct,
                  true,
                );
                await confirmAndUploadNewPicture(
                  context,
                  imageField: ImageField.OTHER,
                  barcode: barcode,
                  language: ProductQuery.getLanguage(),
                  isLoggedInMandatory: true,
                  productType: upToDateProduct.productType,
                );
              },
              tooltip: appLocalizations.add_photo_button_label,
              icon: const Icon(Icons.add_a_photo),
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ProductRefresher().fetchAndRefresh(
                  barcode: barcode,
                  context: context,
                ),
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                        crossAxisCount: 2,
                        height: (MediaQuery.sizeOf(context).width / 2.15) +
                            _PhotoRow.itemHeight,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return Padding(
                            padding: EdgeInsetsDirectional.only(
                              top: VERY_SMALL_SPACE,
                              start: index.isOdd
                                  ? VERY_SMALL_SPACE / 2
                                  : VERY_SMALL_SPACE,
                              end: index.isOdd
                                  ? VERY_SMALL_SPACE
                                  : VERY_SMALL_SPACE / 2,
                            ),
                            child: _PhotoRow(
                              position: index,
                              imageField: _mainImageFields[index],
                              product: upToDateProduct,
                              language: _language,
                            ),
                          );
                        },
                        childCount: _mainImageFields.length,
                        addAutomaticKeepAlives: false,
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        vertical: MEDIUM_SPACE,
                        horizontal: SMALL_SPACE,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          appLocalizations.more_photos,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                    ),
                    if (_shouldDisplayRawGallery())
                      ProductImageGalleryOtherView(product: upToDateProduct)
                    else
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(SMALL_SPACE),
                          child: SmoothLargeButtonWithIcon(
                            text: appLocalizations.view_more_photo_button,
                            icon: Icons.photo_camera_rounded,
                            onPressed: () => setState(
                              () => _clickedOtherPictureButton = true,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldDisplayRawGallery() =>
      _clickedOtherPictureButton ||
      (upToDateProduct.getRawImages()?.isNotEmpty == true);
}

class _PhotoRow extends StatelessWidget {
  const _PhotoRow({
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
                        child: LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints box) {
                          return ProductPicture(
                            product: product,
                            imageField: imageField,
                            size: Size(box.maxWidth, box.maxHeight),
                            onTap: null,
                            errorTextStyle: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                            heroTag: ProductImageSwipeableView.getHeroTag(
                              imageField,
                            ),
                          );
                        }),
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
