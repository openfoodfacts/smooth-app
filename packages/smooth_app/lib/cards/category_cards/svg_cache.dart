import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/cards/category_cards/svg_async_asset.dart';

class SvgCache extends StatelessWidget {
  const SvgCache(
    this.iconUrl, {
    this.width,
    this.height,
    this.displayAssetWhileWaiting = true,
    Key? key,
  }) : super(key: key);

  final String? iconUrl;
  final double? width;
  final double? height;
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
