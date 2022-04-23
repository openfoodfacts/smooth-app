import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/cards/category_cards/asset_cache_helper.dart';

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
  const SvgAsyncAsset(this.assetCacheHelper);

  final AssetCacheHelper assetCacheHelper;

  @override
  State<SvgAsyncAsset> createState() => _SvgAsyncAssetState();
}

class _SvgAsyncAssetState extends State<SvgAsyncAsset> {
  late final Future<String> _loading = _load();

  Future<String> _load() async {
    for (final String cachedFilename
        in widget.assetCacheHelper.cachedFilenames) {
      try {
        return await rootBundle.loadString(cachedFilename);
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
                color: widget.assetCacheHelper.color,
                fit: BoxFit.contain,
                placeholderBuilder: (BuildContext context) =>
                    widget.assetCacheHelper.getEmptySpace(),
              );
            } else {
              widget.assetCacheHelper.notFound();
            }
          }
          return widget.assetCacheHelper.getEmptySpace();
        },
      );
}
