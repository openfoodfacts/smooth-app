import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/cards/category_cards/abstract_cache.dart';
import 'package:smooth_app/cards/category_cards/asset_cache_helper.dart';
import 'package:smooth_app/cards/category_cards/svg_async_asset.dart';

/// Widget that displays a svg from network (and cache while waiting).
class SvgCache extends AbstractCache {
  const SvgCache(
    final String? iconUrl, {
    final double? width,
    final double? height,
    this.color,
    final bool displayAssetWhileWaiting = true,
  }) : super(
          iconUrl,
          width: width,
          height: height,
          displayAssetWhileWaiting: displayAssetWhileWaiting,
        );

  final Color? color;

  @override
  List<String> getCachedFilenames() {
    final List<String> result = <String>[];
    final String? filename = getFilename();
    if (filename == null) {
      return result;
    }
    final String cacheFilename = getCacheFilename(filename);
    final String cacheTintableFilename = getCacheTintableFilename(filename);
    if (color == null) {
      result.add(cacheFilename);
      result.add(cacheTintableFilename);
    } else {
      result.add(cacheTintableFilename);
      result.add(cacheFilename);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> cachedFilenames = getCachedFilenames();
    if (cachedFilenames.isEmpty) {
      return getDefaultUnknown();
    }
    return SvgPicture.network(
      iconUrl!,
      color: color,
      width: width,
      height: height,
      fit: BoxFit.contain,
      placeholderBuilder: (BuildContext context) => displayAssetWhileWaiting
          ? SvgAsyncAsset(
              AssetCacheHelper(
                cachedFilenames,
                iconUrl!,
                width: width,
                height: height,
                color: color,
              ),
            )
          : getCircularProgressIndicator(),
    );
  }
}
