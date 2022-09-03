import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/loading_sliver.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_images_view.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';

/// Displays a [SliverGrid] with tiles showing the images passed
/// via [imagesData]
class SmoothImagesSliverGrid extends SmoothImagesView {
  const SmoothImagesSliverGrid({
    required super.imagesData,
    super.onTap,
    super.loading = false,
    this.loadingCount = 6,
    this.maxTileWidth = VERY_LARGE_SPACE * 7,
    this.childAspectRatio = 1.5,
  });

  /// The number of shimmering tiles to display while [loading] is true
  final int loadingCount;

  /// The maximum width of a tile
  final double maxTileWidth;

  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<ProductImageData, ImageProvider?>> imageList =
        imagesData.entries.toList();

    return SliverPadding(
      padding: const EdgeInsets.all(MEDIUM_SPACE),
      sliver: SliverGrid(
        delegate: LoadingSliverChildBuilderDelegate(
            loading: loading,
            childCount: imageList.length,
            loadingWidget: _buildShimmer(),
            loadingCount: loadingCount,
            childBuilder: (BuildContext context, int index) {
              final MapEntry<ProductImageData, ImageProvider<Object>?> entry =
                  imageList[index];
              final ImageProvider? imageProvider = entry.value;

              return imageProvider == null
                  ? const PictureNotFound()
                  : Hero(
                      tag: entry.key.imageUrl!,
                      child: _ImageTile(
                        image: imageProvider,
                        onTap: onTap == null
                            ? null
                            : () => onTap!(entry.key, entry.value),
                      ),
                    );
            }),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxTileWidth,
          childAspectRatio: childAspectRatio,
          mainAxisSpacing: MEDIUM_SPACE,
          crossAxisSpacing: MEDIUM_SPACE,
        ),
      ),
    );
  }

  Widget _buildShimmer() => Shimmer.fromColors(
        baseColor: WHITE_COLOR,
        highlightColor: GREY_COLOR,
        child: const SmoothImage(
          width: VERY_LARGE_SPACE * 5,
          height: MEDIUM_SPACE * 5,
          color: WHITE_COLOR,
        ),
      );
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({
    required this.image,
    this.onTap,
  });

  final ImageProvider image;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) => Ink(
        decoration: BoxDecoration(
            borderRadius: ROUNDED_BORDER_RADIUS,
            image: DecorationImage(
              image: image,
              fit: BoxFit.cover,
            )),
        child: InkWell(
          borderRadius: ROUNDED_BORDER_RADIUS,
          onTap: onTap,
        ),
      );
}
