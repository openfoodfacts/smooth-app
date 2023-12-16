import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
import 'package:smooth_app/pages/image/product_image_other_page.dart';
import 'package:smooth_app/query/product_query.dart';

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
  late final Future<List<int>> _loading = _loadOtherPics();

  /// Number of columns for the grid.
  static const int _columns = 3;

  Future<List<int>> _loadOtherPics() async =>
      OpenFoodAPIClient.getProductImageIds(
        widget.product.barcode!,
        uriHelper: ProductQuery.uriProductHelper,
        user: ProductQuery.getUser(),
      );

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double squareSize = screenWidth / _columns;
    return FutureBuilder<List<int>>(
      future: _loading,
      builder: (
        final BuildContext context,
        final AsyncSnapshot<List<int>> snapshot,
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
        final List<int> ids = snapshot.data!;
        if (ids.isEmpty) {
          // very unlikely btw.
          return Text(
            appLocalizations.edit_photo_select_existing_downloaded_none,
          );
        }
        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columns,
          ),
          delegate: SliverChildBuilderDelegate(
            (final BuildContext context, final int index) {
              print(index);
              return InkWell(
                onTap: () async =>
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<bool>(
                        builder: (BuildContext context) =>
                            ProductImageOtherPage(
                              widget.product,
                              ids[index],
                            ),
                      ),
                    ),
                child: SmoothImage(
                  width: squareSize,
                  height: squareSize,
                  imageProvider: NetworkImage(
                    ImageHelper.getUploadedImageUrl(
                      widget.product.barcode!,
                      ids[index],
                      ImageSize.DISPLAY,
                    ),
                  ),
                ),
              );
            },
            childCount: ids.length,
          ),

          //scrollDirection: Axis.vertical,
        );
      },
    );
  }
}
