import 'package:flutter/material.dart';
import 'package:smooth_app/services/smooth_services.dart';

/// Asset cache helper class
class AssetCacheHelper {
  const AssetCacheHelper(
    this.cachedFilenames,
    this.url, {
    this.width,
    this.height,
    this.color,
    this.semanticsLabel,
  });

  /// Full asset names, e.g. 'assets/cache/ab-agriculture-biologique.74x90.svg'
  final List<String> cachedFilenames;

  /// URL (for debug purpose), e.g. https://static.openfoodfacts.org/images/lang/fr/labels/ab-agriculture-biologique.74x90.svg
  final String url;

  final double? width;
  final double? height;
  final Color? color;

  final String? semanticsLabel;

  Widget getEmptySpace() => Semantics(
    label: semanticsLabel,
    image: true,
    child: SizedBox(width: width ?? height, height: height ?? width),
  );

  void notFound() => Logs.d(
    'please download $url and put it in asset somewhere like $cachedFilenames',
  );

  Exception loadException() =>
      Exception('could not load any cached file ($cachedFilenames)');

  /// Kind of [ObjectKey].
  Key getKey() => Key('$url/$width/$height/$color/$cachedFilenames');
}
