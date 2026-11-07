import 'package:flutter/material.dart';
import 'package:smooth_app/cards/category_cards/abstract_cache.dart';
import 'package:smooth_app/cards/category_cards/asset_cache_helper.dart';
import 'package:smooth_app/cards/category_cards/raster_async_asset.dart';

/// Widget that displays a png/jpeg from network (and cache while waiting).
class RasterCache extends AbstractCache {
  const RasterCache(super.iconUrl, {super.width, super.height});

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
      loadingBuilder:
          (
            BuildContext context,
            Widget child,
            ImageChunkEvent? loadingProgress,
          ) {
            if (loadingProgress == null) {
              return child;
            }
            return _localAssetWidget(fullFilenames);
          },
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) => _localAssetWidget(fullFilenames),
    );
  }

  RasterAsyncAsset _localAssetWidget(List<String> fullFilenames) {
    return RasterAsyncAsset(
      AssetCacheHelper(fullFilenames, iconUrl!, width: width, height: height),
    );
  }
}
