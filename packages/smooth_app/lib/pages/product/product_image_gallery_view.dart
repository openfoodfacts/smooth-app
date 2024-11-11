import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
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
import 'package:smooth_app/resources/app_icons.dart' as icons;
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
        ),
        floatingActionButton: FloatingActionButton.extended(
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
          label: Text(appLocalizations.add_photo_button_label),
          icon: const Icon(Icons.add_a_photo),
        ),
        body: Column(
          children: <Widget>[
            LanguageSelector(
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
                        height: _computeItemHeight(),
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return _PhotoRow(
                            position: index,
                            imageField: _mainImageFields[index],
                            product: upToDateProduct,
                            language: _language,
                          );
                        },
                        childCount: _mainImageFields.length,
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
                    // Extra space to be above the FAB
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: SizedBox(
                        height: (Theme.of(context)
                                    .floatingActionButtonTheme
                                    .extendedSizeConstraints
                                    ?.maxHeight ??
                                56.0) +
                            16.0,
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

  double _computeItemHeight() {
    final TextStyle? textStyle = Theme.of(context).textTheme.headlineMedium;

    return (MediaQuery.sizeOf(context).width / 2) +
        SMALL_SPACE +
        ((textStyle?.fontSize ?? 15.0) * 2) * (textStyle?.height ?? 2.0);
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

    return Semantics(
      image: true,
      button: true,
      label: expired
          ? appLocalizations.product_image_outdated_accessibility_label(label)
          : label,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(
          top: SMALL_SPACE,
        ),
        child: InkWell(
          onTap: () => _openImage(
            context: context,
            initialImageIndex: position,
          ),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: SmoothImage(
                      rounded: false,
                      imageProvider: transientFile.getImageProvider(),
                    ),
                  ),
                  if (transientFile.isImageAvailable() &&
                      !transientFile.isServerImage())
                    const Center(
                      child: CloudUploadAnimation.circle(size: 30.0),
                    ),
                  if (expired)
                    Positioned.directional(
                      textDirection: Directionality.of(context),
                      bottom: VERY_SMALL_SPACE,
                      end: VERY_SMALL_SPACE,
                      child: const icons.Outdated(
                        color: Colors.black87,
                        shadow: Shadow(
                          color: Colors.white38,
                          blurRadius: 2.0,
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
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
