import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/cards/category_cards/asset_cache_helper.dart';
import 'package:smooth_app/cards/category_cards/svg_safe_network.dart';
import 'package:smooth_app/helpers/app_helper.dart';

/// Widget with async load of SVG asset file
///
/// SVG files may need to be optimized before being stored in the cache folders.
/// There are two cache folders:
/// * assets/cache, where most files should be put
/// * assets/cacheTintable, where only colorless files should be put
/// As an example, vegetarian.svg is in both folders:
/// * the assets/cache version has different colors - no color should be applied
/// * the assets/cacheTintable version works with a color applied to it
/// E.g. with https://jakearchibald.github.io/svgomg/
/// C.f. https://github.com/openfoodfacts/smooth-app/issues/52
class SvgAsyncAsset extends StatefulWidget {
  const SvgAsyncAsset(
    this.assetCacheHelper, {
    this.loadingBuilder,
    this.errorBuilder,
  });

  final AssetCacheHelper assetCacheHelper;
  final WidgetBuilder? loadingBuilder;
  final WidgetErrorBuilder? errorBuilder;

  @override
  State<SvgAsyncAsset> createState() => _SvgAsyncAssetState();
}

class _SvgAsyncAssetState extends State<SvgAsyncAsset> {
  late final Future<String> _loading = _load();

  Future<String> _load() async {
    for (final String cachedFilename
        in widget.assetCacheHelper.cachedFilenames) {
      try {
        return await rootBundle.loadString(
          AppHelper.getAssetPath(cachedFilename),
        );
      } catch (e) {
        //
      }
    }
    throw widget.assetCacheHelper.loadException();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
    future: _loading,
    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.data != null) {
          return SvgPicture.string(
            snapshot.data!,
            width: widget.assetCacheHelper.width,
            height: widget.assetCacheHelper.height,
            colorFilter: widget.assetCacheHelper.color == null
                ? null
                : ui.ColorFilter.mode(
                    widget.assetCacheHelper.color!,
                    ui.BlendMode.srcIn,
                  ),
            fit: BoxFit.contain,
            placeholderBuilder: (BuildContext context) =>
                widget.assetCacheHelper.getEmptySpace(),
          );
        } else {
          widget.assetCacheHelper.notFound();
          if (widget.errorBuilder != null) {
            return widget.errorBuilder!(context, Exception('Not found'));
          }
        }
      }

      if (widget.loadingBuilder != null) {
        return widget.loadingBuilder!(context);
      }
      return widget.assetCacheHelper.getEmptySpace();
    },
  );
}
