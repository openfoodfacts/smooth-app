import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/cards/category_cards/svg_async_asset.dart';

/// Creates a widget that displays a [PictureStream] obtained from the network using iconUrl.
/// if only 1 of [height] or [width] is provided the resulting image will be of the size:
/// [height] * [height] or [width] * [width].
class SvgCache extends StatelessWidget {
  const SvgCache(
    this.iconUrl, {
    this.width,
    this.height,
    this.color,
    this.displayAssetWhileWaiting = true,
  });

  final String? iconUrl;
  final double? width;
  final double? height;
  final Color? color;
  final bool displayAssetWhileWaiting;

  @override
  Widget build(BuildContext context) {
    if (iconUrl == null) {
      return _getDefaultUnknown();
    }
    final int position = iconUrl!.lastIndexOf('/');
    if (position == -1) {
      return _getDefaultUnknown();
    }
    final String filename = iconUrl!.substring(position + 1);
    final String fullFilename = 'assets/cache/$filename';
    return SvgPicture.network(
      iconUrl!,
      color: color,
      width: width,
      height: height,
      fit: BoxFit.contain,
      placeholderBuilder: (BuildContext context) => displayAssetWhileWaiting
          ? SvgAsyncAsset(fullFilename, width: width, height: height)
          : SizedBox(
              width: width ?? height,
              height: height ?? width,
              child: const CircularProgressIndicator(),
            ),
    );
  }

  Widget _getDefaultUnknown() => Icon(
        CupertinoIcons.question,
        size: width ?? height,
        color: Colors.red,
      );
}
