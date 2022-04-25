import 'package:flutter/material.dart';

/// Asset cache helper class
class AssetCacheHelper {
  const AssetCacheHelper(
    this.cachedFilenames,
    this.url, {
    this.width,
    this.height,
    this.color,
  });

  /// Full asset names, e.g. 'assets/cache/ab-agriculture-biologique.74x90.svg'
  final List<String> cachedFilenames;

  /// URL (for debug purpose), e.g. https://static.openfoodfacts.org/images/lang/fr/labels/ab-agriculture-biologique.74x90.svg
  final String url;

  final double? width;
  final double? height;
  final Color? color;

  Widget getEmptySpace() => SizedBox(
        width: width ?? height,
        height: height ?? width,
      );

  void notFound() =>
      debugPrint('unexpected case: asset not found $cachedFilenames ($url)');

  Exception loadException() =>
      Exception('could not load any cached file ($cachedFilenames)');
}
