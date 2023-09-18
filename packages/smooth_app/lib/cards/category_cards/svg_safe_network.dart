import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_app/cards/category_cards/asset_cache_helper.dart';
import 'package:smooth_app/cards/category_cards/svg_async_asset.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/services/smooth_services.dart';

/// Widget with async load of SVG network file.
///
/// We could use SvgPicture.network, but it sends tons of errors if there in no
/// internet connection. That's why we download the data ourselves.
class SvgSafeNetwork extends StatefulWidget {
  const SvgSafeNetwork(this.helper);

  final AssetCacheHelper helper;

  @override
  State<SvgSafeNetwork> createState() => _SvgSafeNetworkState();
}

class _SvgSafeNetworkState extends State<SvgSafeNetwork> {
  late final Future<String> _loading = _load();

  String get _url => widget.helper.url;

  Future<String> _load() async {
    String? cached = _networkCache[_url];
    if (cached != null) {
      return cached;
    }
    final http.Response response = await http.get(Uri.parse(_url));
    _networkCache[_url] = cached = response.body;
    return cached;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
        future: _loading,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              return SvgPicture.string(
                snapshot.data!,
                width: widget.helper.width,
                height: widget.helper.height,
                colorFilter: widget.helper.color == null
                    ? null
                    : ui.ColorFilter.mode(
                        widget.helper.color!,
                        ui.BlendMode.srcIn,
                      ),
                fit: BoxFit.contain,
                semanticsLabel: SvgCache.getSemanticsLabel(context, _url),
                placeholderBuilder: (BuildContext context) =>
                    SvgAsyncAsset(widget.helper),
              );
            }
          }
          if (snapshot.error != null) {
            final bool serverOrConnectionIssue = snapshot.error.toString() ==
                "Failed host lookup: 'static.openfoodfacts.org'";
            if (!serverOrConnectionIssue) {
              Logs.e(
                'Could not download "$_url"',
                ex: snapshot.error,
              );
            }
          }
          return SvgAsyncAsset(widget.helper);
        },
      );
}

/// Network cache, with url as key and SVG data as value.
final Map<String, String> _networkCache = <String, String>{};
