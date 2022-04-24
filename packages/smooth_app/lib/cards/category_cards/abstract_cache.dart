import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/cards/category_cards/null_cache.dart';
import 'package:smooth_app/cards/category_cards/raster_cache.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';

/// Widget that displays an image from network (and cache while waiting).
abstract class AbstractCache extends StatelessWidget {
  @protected
  const AbstractCache(
    this.iconUrl, {
    this.width,
    this.height,
    this.displayAssetWhileWaiting = true,
  });

  /// Returns the best cache possibility: none, svg or png/jpeg
  factory AbstractCache.best({
    final String? iconUrl,
    final double? width,
    final double? height,
    final Color? color,
  }) {
    if (iconUrl == null) {
      return NullCache(width: width, height: height);
    }
    if (iconUrl.endsWith('.svg')) {
      return SvgCache(iconUrl, color: color, width: width, height: height);
    }
    return RasterCache(iconUrl, width: width, height: height);
  }

  final String? iconUrl;
  final double? width;
  final double? height;
  final bool displayAssetWhileWaiting;

  /// Returns a list of possible related cached filenames.
  @protected
  List<String> getCachedFilenames() {
    final List<String> result = <String>[];
    final String? filename = getFilename();
    if (filename == null) {
      return result;
    }
    result.add(getCacheFilename(filename));
    return result;
  }

  /// Returns the path to the asset cached file (not tintable version).
  @protected
  String getCacheFilename(final String filename) => 'assets/cache/$filename';

  /// Returns the path to the asset cached tintable file.
  @protected
  String getCacheTintableFilename(final String filename) =>
      'assets/cacheTintable/$filename';

  /// Returns the simple filename of the icon url (without the full path).
  @protected
  String? getFilename() {
    if (iconUrl == null) {
      return null;
    }
    final int position = iconUrl!.lastIndexOf('/');
    if (position == -1) {
      return null;
    }
    return iconUrl!.substring(position + 1);
  }

  @protected
  Widget getDefaultUnknown() => Icon(
        CupertinoIcons.question,
        size: width ?? height,
        color: Colors.red,
      );

  @protected
  Widget getCircularProgressIndicator() => SizedBox(
        width: width ?? height,
        height: height ?? width,
        child: const CircularProgressIndicator(),
      );
}
