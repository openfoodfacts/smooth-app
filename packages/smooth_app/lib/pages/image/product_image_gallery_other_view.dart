import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image/product_image_other_page.dart';
import 'package:smooth_app/pages/image/product_image_widget.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/widgets/smooth_indicator_icon.dart';

/// Number of columns for the grid.
const int _columns = 3;

/// Square size of a thumbnail.
double _getSquareSize(final BuildContext context) {
  final double screenWidth = MediaQuery.sizeOf(context).width;
  return screenWidth / _columns;
}

/// Display of the other pictures of a product.
class ProductImageGalleryOtherView extends StatefulWidget {
  const ProductImageGalleryOtherView({
    required this.onPhotosAvailable,
    super.key,
  });

  final Function(bool hasPhotos) onPhotosAvailable;

  @override
  State<ProductImageGalleryOtherView> createState() =>
      _ProductImageGalleryOtherViewState();
}

class _ProductImageGalleryOtherViewState
    extends State<ProductImageGalleryOtherView> {
  Future<FetchedProduct> _loadOtherPics(Product product) async =>
      ProductRefresher().silentFetchAndRefresh(
        localDatabase: context.read<LocalDatabase>(),
        barcode: product.barcode!,
      );

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Product product = context.watch<Product>();
    context.read<OpenFoodFactsLanguage>();

    List<ProductImage> rawImages = getRawProductImages(
      product,
      ImageSize.DISPLAY,
    );

    if (rawImages.isNotEmpty) {
      widget.onPhotosAvailable(true);
      return _RawGridGallery(product, rawImages);
    }
    final double squareSize = _getSquareSize(context);
    return FutureBuilder<FetchedProduct>(
      future: _loadOtherPics(product),
      builder: (
        final BuildContext context,
        final AsyncSnapshot<FetchedProduct> snapshot,
      ) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SliverToBoxAdapter(
            child: Center(
              child: SizedBox(
                width: squareSize,
                height: squareSize,
                child: const CircularProgressIndicator.adaptive(),
              ),
            ),
          );
        }
        if (snapshot.data == null) {
          return SliverToBoxAdapter(
            child: Text(
              snapshot.error?.toString() ??
                  appLocalizations.loading_dialog_default_error_message,
            ),
          );
        }
        final FetchedProduct fetchedProduct = snapshot.data!;
        if (fetchedProduct.product != null) {
          rawImages = getRawProductImages(
            fetchedProduct.product!,
            ImageSize.DISPLAY,
          );
        }
        if (rawImages.isNotEmpty) {
          widget.onPhotosAvailable(true);
          return _RawGridGallery(
            fetchedProduct.product ?? product,
            rawImages,
          );
        }

        widget.onPhotosAvailable(false);
        return const SliverToBoxAdapter(child: EMPTY_WIDGET);
      },
    );
  }
}

class _RawGridGallery extends StatelessWidget {
  const _RawGridGallery(this.product, this.rawImages);

  final Product product;
  final List<ProductImage> rawImages;

  @override
  Widget build(BuildContext context) {
    final double squareSize = _getSquareSize(context);
    final ImageSize? imageSize = _computeImageSize(squareSize);
    final OpenFoodFactsLanguage language =
        context.read<OpenFoodFactsLanguage>();

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columns,
      ),
      delegate: SliverChildBuilderDelegate(
        (final BuildContext context, int index) {
          // order by descending ids
          index = rawImages.length - 1 - index;
          final ProductImage productImage = rawImages[index];
          final String? heroTag = productImage.imgid;

          return Padding(
            padding: EdgeInsetsDirectional.only(
              start: VERY_SMALL_SPACE,
              end: index % _columns == 0 ? VERY_SMALL_SPACE : 0.0,
              bottom: VERY_SMALL_SPACE,
            ),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: ProductImageWidget(
                    productImage: productImage,
                    barcode: product.barcode!,
                    squareSize: squareSize,
                    imageSize: imageSize,
                    heroTag: heroTag,
                    productType: product.productType,
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      borderRadius: ANGULAR_BORDER_RADIUS,
                      onTap: () async => _openOtherPage(
                        context: context,
                        product: product,
                        rawImages: rawImages,
                        productImage: productImage,
                        heroTag: heroTag!,
                        language: language,
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 0.0,
                  end: 0.0,
                  child: Tooltip(
                    message: AppLocalizations.of(context)
                        .photo_viewer_use_picture_as_tooltip,
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () async => _usePhotoAs(
                          context: context,
                          product: product,
                          rawImages: rawImages,
                          productImage: productImage,
                          heroTag: heroTag!,
                          language: language,
                        ),
                        child: const SmoothIndicatorIcon(
                          padding: EdgeInsetsDirectional.all(VERY_SMALL_SPACE),
                          icon: Icon(Icons.more_vert_outlined, size: 17.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        addAutomaticKeepAlives: false,
        childCount: rawImages.length,
      ),
    );
  }

  ImageSize? _computeImageSize(double squareSize) => <ImageSize>[
        ImageSize.THUMB,
        ImageSize.SMALL,
        ImageSize.DISPLAY
      ].firstWhereOrNull(
        (ImageSize element) => squareSize <= int.parse(element.number),
      );

  Future<void> _openOtherPage({
    required final BuildContext context,
    required final Product product,
    required final List<ProductImage> rawImages,
    required final ProductImage productImage,
    required final String heroTag,
    required final OpenFoodFactsLanguage language,
  }) async {
    await Navigator.push<ProductImagePageResult>(
      context,
      MaterialPageRoute<ProductImagePageResult>(
        builder: (BuildContext context) {
          return ProductImageOtherPage(
            product: product,
            language: language,
            images: rawImages.reversed.toList(growable: false),
            currentImage: productImage,
            heroTag: heroTag,
          );
        },
      ),
    );
  }

  Future<ProductImagePageResult?> _usePhotoAs({
    required final BuildContext context,
    required final Product product,
    required final List<ProductImage> rawImages,
    required final ProductImage productImage,
    required final String heroTag,
    required final OpenFoodFactsLanguage language,
  }) =>
      ProductImageOtherPage.usePhotoAs(
        context: context,
        product: product,
        language: language,
        productImage: productImage,
      );
}
