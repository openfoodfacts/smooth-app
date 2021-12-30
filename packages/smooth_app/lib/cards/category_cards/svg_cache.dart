import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/cards/category_cards/abstract_cache.dart';
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
  Widget build(BuildContext context) {
    final String? fullFilename = getFullFilename();
    if (fullFilename == null) {
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
              fullFilename,
              iconUrl!,
              width: width,
              height: height,
              color: color,
            )
          : getCircularProgressIndicator(),
    );
  }
}
