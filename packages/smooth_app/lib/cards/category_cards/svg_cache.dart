import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';

class SvgCache extends StatelessWidget {
  const SvgCache(
    this.iconUrl, {
    this.width,
    this.height,
    this.displayAssetWhileWaiting = true,
  });

  final String iconUrl;
  final double width;
  final double height;
  final bool displayAssetWhileWaiting;

  @override
  Widget build(BuildContext context) {
    if (iconUrl == null) {
      return _getDefaultUnknown();
    }
    final int position = iconUrl.lastIndexOf('/');
    if (position == -1) {
      return _getDefaultUnknown();
    }
    final String filename = iconUrl.substring(position + 1);
    final String fullFilename = 'assets/cache/$filename';
    return _getCachedAsset(fullFilename);
    return SvgPicture.network(
      iconUrl,
      width: width,
      height: height,
      fit: BoxFit.contain,
      placeholderBuilder: (BuildContext context) => displayAssetWhileWaiting
          ? _getCachedAsset(fullFilename)
          : _getCircularProgressIndicator(),
    );
  }

  Widget _getCachedAsset(final String fullFilename) => FutureBuilder<String>(
        future: rootBundle.loadString(fullFilename),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              return SvgPicture.string(snapshot.data,
                  width: width,
                  height: height,
                  fit: BoxFit.contain,
                  placeholderBuilder: (BuildContext context) => Container(
                        width: width ?? height,
                        height: height ?? width,
                      ));
            } else {
              print('rare case: not cached svg $iconUrl');
            }
          }
          return Container(
            width: width ?? height,
            height: height ?? width,
          );
        },
      );

  Widget _getDefaultUnknown() => Icon(
        CupertinoIcons.question,
        size: width ?? height,
        color: Colors.red,
      );

  Widget _getCircularProgressIndicator() => Container(
        width: width ?? height,
        height: height ?? width,
        child: const CircularProgressIndicator(),
      );
}
