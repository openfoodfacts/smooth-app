import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image/product_image_other_page.dart';
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

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    final double squareSize = _getSquareSize(context);
    final DateTime now = DateTime.now();
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columns,
      ),
      delegate: SliverChildBuilderDelegate(
        (final BuildContext context, int index) {
          // order by descending ids
          index = rawImages.length - 1 - index;
          final ProductImage productImage = rawImages[index];
          final DateTime? uploaded = productImage.uploaded;
          final String? date;
          final bool expired;
          if (uploaded == null) {
            date = null;
            expired = false;
          } else {
            date = _dateFormat.format(uploaded);
            expired = now.difference(uploaded).inDays > 365;
          }
          final Widget image = SmoothImage(
            width: squareSize,
            height: squareSize,
            imageProvider: NetworkImage(productImage.getUrl(product.barcode!)),
            rounded: false,
          );
          return InkWell(
            onTap: () async => Navigator.push<void>(
              context,
              MaterialPageRoute<bool>(
                builder: (BuildContext context) => ProductImageOtherPage(
                  product,
                  int.parse(productImage.imgid!),
                ),
              ),
            ),
            child: date == null
                ? image
                : Stack(
                    children: <Widget>[
                      image,
                      SizedBox(
                        width: squareSize,
                        height: squareSize,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(SMALL_SPACE),
                            child: Container(
                              height: VERY_LARGE_SPACE,
                              color: expired
                                  ? Colors.red.withAlpha(128)
                                  : Colors.white.withAlpha(128),
                              child: Center(
                                child: AutoSizeText(
                                  date,
                                  maxLines: 1,
                                ),
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
}
