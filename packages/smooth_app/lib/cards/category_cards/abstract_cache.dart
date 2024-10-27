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

  /// Returns a list of possible related cached filenames.
  @protected
  List<String> getCachedFilenames() {
    final List<String> result = <String>[];
    for (int i = 0; i <= 1; i++) {
      final String? filename = getFilename(withFolder: i == 0);
      if (filename == null) {
        continue;
      }
      result.add(getCacheFilename(filename));
    }
    return result;
  }

  /// Returns the path to the asset cached file (not tintable version).
  @protected
  String getCacheFilename(final String filename) => 'assets/cache/$filename';

  /// Returns the path to the asset cached tintable file.
  @protected
  String getCacheTintableFilename(final String filename) =>
      'assets/cacheTintable/$filename';

  /// Returns the simple filename of the icon url, possibly with its folder.
  @protected
  String? getFilename({required final bool withFolder}) {
    const String folderSeparator = '__';
    if (iconUrl == null) {
      return null;
    }
    final List<String> bits = iconUrl!.split('/');
    if (bits.length <= 1) {
      return null;
    }
    if (!withFolder) {
      return bits.last;
    }
    return '${bits[bits.length - 2]}$folderSeparator${bits[bits.length - 1]}';
  }

  @protected
  Widget getDefaultUnknown() => Icon(
        CupertinoIcons.question,
        size: width ?? height,
        color: Colors.red,
      );
}
