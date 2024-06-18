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
    required this.product,
  });

  final Product product;

  @override
  State<ProductImageGalleryOtherView> createState() =>
      _ProductImageGalleryOtherViewState();
}

class _ProductImageGalleryOtherViewState
    extends State<ProductImageGalleryOtherView> {
  late final Future<FetchedProduct> _loading = _loadOtherPics();

  Future<FetchedProduct> _loadOtherPics() async =>
      ProductRefresher().silentFetchAndRefresh(
        localDatabase: context.read<LocalDatabase>(),
        barcode: widget.product.barcode!,
      );

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    List<ProductImage> rawImages = getRawProductImages(
      widget.product,
      ImageSize.DISPLAY,
    );
    if (rawImages.isNotEmpty) {
      return _RawGridGallery(widget.product, rawImages);
    }
    final double squareSize = _getSquareSize(context);
    return FutureBuilder<FetchedProduct>(
      future: _loading,
      builder: (
        final BuildContext context,
        final AsyncSnapshot<FetchedProduct> snapshot,
      ) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SliverToBoxAdapter(
            child: SizedBox(
              width: squareSize,
              height: squareSize,
              child: const CircularProgressIndicator.adaptive(),
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
          return _RawGridGallery(
            fetchedProduct.product ?? widget.product,
            rawImages,
          );
        }
        return SliverToBoxAdapter(
          child: Text(
            appLocalizations.edit_photo_select_existing_downloaded_none,
          ),
        );
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
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columns,
      ),
      delegate: SliverChildBuilderDelegate(
        (final BuildContext context, int index) {
          // order by descending ids
          index = rawImages.length - 1 - index;
          final ProductImage productImage = rawImages[index];
          return Padding(
            padding: EdgeInsetsDirectional.only(
              start: VERY_SMALL_SPACE,
              end: index % _columns == 0 ? VERY_SMALL_SPACE : 0.0,
              bottom: VERY_SMALL_SPACE,
            ),
            child: InkWell(
              onTap: () async => Navigator.push<void>(
                context,
                MaterialPageRoute<bool>(
                  builder: (BuildContext context) => ProductImageOtherPage(
                    product,
                    int.parse(productImage.imgid!),
                  ),
                ),
              ),
              child: ProductImageWidget(
                productImage: productImage,
                barcode: product.barcode!,
                squareSize: squareSize,
              ),
            ),
          );
        },
        addAutomaticKeepAlives: false,
        childCount: rawImages.length,
      ),
    );
  }
}
