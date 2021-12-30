import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/cards/category_cards/abstract_async_asset.dart';

/// Widget with async load of SVG asset file
///
/// SVG files may need to be optimized before being stored in the cache folder.
/// E.g. with https://jakearchibald.github.io/svgomg/
/// C.f. https://github.com/openfoodfacts/smooth-app/issues/52
class SvgAsyncAsset extends AbstractAsyncAsset {
  const SvgAsyncAsset(
    final String fullFilename,
    final String url, {
    final double? width,
    final double? height,
    this.color,
  }) : super(
          fullFilename,
          url,
          width: width,
          height: height,
        );

  final Color? color;

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
        future: rootBundle.loadString(fullFilename),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              return SvgPicture.string(
                snapshot.data!,
                width: width,
                height: height,
                color: color,
                fit: BoxFit.contain,
                placeholderBuilder: (BuildContext context) => getEmptySpace(),
              );
            } else {
              notFound();
            }
          }
          return getEmptySpace();
        },
      );
}
