import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/widgets/language_selector.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/product_image_button.dart';
import 'package:smooth_app/pages/product/product_image_swipeable_view.dart';
import 'package:smooth_app/resources/app_animations.dart';

/// Displays a full-screen image with an "edit" floating button.
class ProductImageViewer extends StatefulWidget {
  const ProductImageViewer({
    required this.product,
    required this.imageField,
    required this.language,
    required this.setLanguage,
    required this.isLoggedInMandatory,
  });

  final Product product;
  final ImageField imageField;
  final OpenFoodFactsLanguage language;
  final Future<void> Function(OpenFoodFactsLanguage? newLanguage) setLanguage;
  final bool isLoggedInMandatory;

  @override
  State<ProductImageViewer> createState() => _ProductImageViewerState();
}

class _ProductImageViewerState extends State<ProductImageViewer>
    with UpToDateMixin {
  late ProductImageData _imageData;

  @override
  void initState() {
    super.initState();
    initUpToDate(widget.product, context.read<LocalDatabase>());
  }

  Widget _getImageButton(
    final ProductImageButtonType type,
    final bool imageExists,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
        child: type.getButton(
          product: upToDateProduct,
          imageField: widget.imageField,
          imageExists: imageExists,
          language: widget.language,
          isLoggedInMandatory: widget.isLoggedInMandatory,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    refreshUpToDate();
    _imageData = getProductImageData(
      upToDateProduct,
      widget.imageField,
      widget.language,
    );
    final TransientFile transientFile = _getTransientFile();
    final ImageProvider? imageProvider = transientFile.getImageProvider();
    final bool imageExists = imageProvider != null;
    final bool isLoading =
        transientFile.isImageAvailable() && !transientFile.isServerImage();
    final Iterable<OpenFoodFactsLanguage> selectedLanguages =
        getProductImageLanguages(
      upToDateProduct,
      widget.imageField,
    );

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(MINIMUM_TOUCH_SIZE / 2),
              child: imageProvider == null
                  ? Stack(
                      children: <Widget>[
                        const SizedBox.expand(child: PictureNotFound()),
                        Center(
                          child: Text(
                            selectedLanguages.isEmpty
                                ? appLocalizations.edit_photo_language_none
                                : appLocalizations
                                    .edit_photo_language_not_this_one,
                            style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(color: Colors.black) ??
                                const TextStyle(color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Positioned.fill(
                          child: Material(
                            type: MaterialType.transparency,
                            child: Semantics(
                              label: appLocalizations.take_photo_title,
                              child: InkWell(
                                onTap: () async {
                                  await confirmAndUploadNewPicture(
                                    context,
                                    imageField: widget.imageField,
                                    barcode: barcode,
                                    productType: upToDateProduct.productType,
                                    language: widget.language,
                                    isLoggedInMandatory: true,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox.expand(
                      child: Stack(
                        children: <Widget>[
                          Positioned.fill(
                            child: AnimatedOpacity(
                              opacity: isLoading ? 0.5 : 1.0,
                              duration: SmoothAnimationsDuration.short,
                              child: PhotoView(
                                minScale: 0.2,
                                imageProvider: imageProvider,
                                heroAttributes: PhotoViewHeroAttributes(
                                    tag: ProductImageSwipeableView.getHeroTag(
                                      widget.imageField,
                                    ),
                                    flightShuttleBuilder: (
                                      _,
                                      Animation<double> animation,
                                      HeroFlightDirection flightDirection,
                                      BuildContext fromHeroContext,
                                      BuildContext toHeroContext,
                                    ) {
                                      return AnimatedBuilder(
                                        animation: animation,
                                        builder: (_, __) {
                                          Widget widget;
                                          if (flightDirection ==
                                              HeroFlightDirection.push) {
                                            widget = fromHeroContext.widget;
                                          } else {
                                            widget = toHeroContext.widget;
                                          }

                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                    1 - animation.value) *
                                                ROUNDED_RADIUS.x,
                                            child: widget,
                                          );
                                        },
                                      );
                                    }),
                                backgroundDecoration: const BoxDecoration(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          if (isLoading)
                            Center(
                              child: CloudUploadAnimation.circle(
                                size: MediaQuery.sizeOf(context).longestSide *
                                    0.2,
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(SMALL_SPACE),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(LARGE_SPACE),
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: LanguageSelector(
                      setLanguage: widget.setLanguage,
                      displayedLanguage: widget.language,
                      selectedLanguages: selectedLanguages,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 13.0,
                        vertical: SMALL_SPACE,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: _getImageButton(
                  ProductImageButtonType.server,
                  imageExists,
                ),
              ),
              Expanded(
                child: _getImageButton(
                  ProductImageButtonType.local,
                  imageExists,
                ),
              ),
            ],
          ),
          if (imageProvider != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: _getImageButton(
                    ProductImageButtonType.unselect,
                    imageExists,
                  ),
                ),
                Expanded(
                  child: _getImageButton(
                    ProductImageButtonType.edit,
                    imageExists,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  TransientFile _getTransientFile() => TransientFile.fromProductImageData(
        _imageData,
        barcode,
        widget.language,
      );
}
