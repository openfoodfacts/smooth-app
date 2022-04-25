import 'package:flutter/material.dart';
import 'package:smooth_app/cards/category_cards/abstract_cache.dart';
import 'package:smooth_app/cards/category_cards/asset_cache_helper.dart';
import 'package:smooth_app/cards/category_cards/raster_async_asset.dart';

/// Widget that displays a png/jpeg from network (and cache while waiting).
class RasterCache extends AbstractCache {
  const RasterCache(
    final String iconUrl, {
    final double? width,
    final double? height,
    final bool displayAssetWhileWaiting = true,
  }) : super(
          iconUrl,
          width: width,
          height: height,
          displayAssetWhileWaiting: displayAssetWhileWaiting,
        );

  @override
  Widget build(BuildContext context) {
    final List<String> fullFilenames = getCachedFilenames();
    if (fullFilenames.isEmpty) {
      return getDefaultUnknown();
    }
    return Image.network(
      iconUrl!,
      width: width,
      height: height,
      fit: BoxFit.contain,
      loadingBuilder: (
        final BuildContext context,
        final Widget child,
        final ImageChunkEvent? loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }
        return displayAssetWhileWaiting
            ? RasterAsyncAsset(
                AssetCacheHelper(
                  fullFilenames,
                  iconUrl!,
                  width: width,
                  height: height,
                ),
              )
            : getCircularProgressIndicator();
      },
    );
  }
}
