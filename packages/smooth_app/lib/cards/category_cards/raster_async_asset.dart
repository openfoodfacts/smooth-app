import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_app/cards/category_cards/asset_cache_helper.dart';

/// Widget with async load of raster asset file (png, jpeg).
class RasterAsyncAsset extends StatefulWidget {
  const RasterAsyncAsset(this.assetCacheHelper);

  final AssetCacheHelper assetCacheHelper;

  @override
  State<RasterAsyncAsset> createState() => _RasterAsyncAssetState();
}

class _RasterAsyncAssetState extends State<RasterAsyncAsset> {
  late final Future<ByteData> _loading = _load();

  Future<ByteData> _load() {
    for (final String cachedFilename
        in widget.assetCacheHelper.cachedFilenames) {
      try {
        return rootBundle.load(cachedFilename);
      } catch (e) {
        //
      }
    }
    throw widget.assetCacheHelper.loadException();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<ByteData>(
        future: _loading,
        builder: (BuildContext context, AsyncSnapshot<ByteData> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              return Image.memory(
                snapshot.data!.buffer.asUint8List(),
                width: widget.assetCacheHelper.width,
                height: widget.assetCacheHelper.height,
                fit: BoxFit.contain,
              );
            } else {
              widget.assetCacheHelper.notFound();
            }
          }
          return widget.assetCacheHelper.getEmptySpace();
        },
      );
}
