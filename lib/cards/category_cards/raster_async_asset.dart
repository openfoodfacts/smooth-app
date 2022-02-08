import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_app/cards/category_cards/abstract_async_asset.dart';

/// Widget with async load of raster asset file (png, jpeg).
class RasterAsyncAsset extends AbstractAsyncAsset {
  const RasterAsyncAsset(
    final String fullFilename,
    final String url, {
    final double? width,
    final double? height,
  }) : super(
          fullFilename,
          url,
          width: width,
          height: height,
        );

  @override
  Widget build(BuildContext context) => FutureBuilder<ByteData>(
        future: rootBundle.load(fullFilename),
        builder: (BuildContext context, AsyncSnapshot<ByteData> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              return Image.memory(
                snapshot.data!.buffer.asUint8List(),
                width: width,
                height: height,
                fit: BoxFit.contain,
              );
            } else {
              notFound();
            }
          }
          return getEmptySpace();
        },
      );
}
