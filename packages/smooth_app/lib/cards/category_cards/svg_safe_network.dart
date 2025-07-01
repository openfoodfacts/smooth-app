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
/// We do need the [key] for cases like "We updated the categories and then the
/// ecoscore changed, as an impact". Without a key, flutter may not refresh the
/// ecoscore svg widget when the URL changes.
/// cf. https://api.flutter.dev/flutter/foundation/Key-class.html
class SvgSafeNetwork extends StatefulWidget {
  const SvgSafeNetwork(
    this.helper, {
    this.loadingBuilder,
    this.errorBuilder,
    required super.key,
  });

  final AssetCacheHelper helper;
  final WidgetBuilder? loadingBuilder;
  final WidgetErrorBuilder? errorBuilder;

  @override
  State<SvgSafeNetwork> createState() => _SvgSafeNetworkState();
}

class _SvgSafeNetworkState extends State<SvgSafeNetwork> {
  late final Future<String> _loading = _load();

  String get _url => widget.helper.url;

  // TODO(monsieurtanuki): Change /dist/ url to be the first try when the majority of products have been updated
  /// Loads the SVG file from url or from alternate url.
  ///
  /// In Autumn 2023, the web image folders were moved to a /dist/ subfolder.
  /// Before:
  /// https://static.openfoodfacts.org/images/attributes/nova-group-3.svg
  /// After:
  /// https://static.openfoodfacts.org/images/attributes/dist/nova-group-3.svg
  /// Products that haven't been refreshed still reference the previous web
  /// folder. If we cannot find the URL, we try with the alternate /dist/ URL.
  Future<String> _load() async {
    const int statusOk = 200;
    const int statusNotFound = 404;

    final String? alternateUrl = _getAlternateUrl();

    // is the url already cached?
    String? cached = _networkCache[_url];
    if (cached != null) {
      return cached;
    }
    // is the alternate url already cached?
    if (alternateUrl != null) {
      cached = _networkCache[alternateUrl];
      if (cached != null) {
        return cached;
      }
    }

    // try with the url
    final http.Response response1 = await http.get(Uri.parse(_url));
    if (response1.statusCode == statusOk) {
      _networkCache[_url] = cached = response1.body;
      return cached;
    }
    if (response1.statusCode == statusNotFound) {
      if (alternateUrl != null) {
        // try with the alternate url
        final http.Response response2 = await http.get(Uri.parse(alternateUrl));
        if (response2.statusCode == statusOk) {
          _networkCache[alternateUrl] = cached = response2.body;
          return cached;
        }
        throw Exception(
          'Failed to load SVG: $_url ${response1.statusCode} $alternateUrl ${response2.statusCode}',
        );
      }
    }

    throw Exception('Failed to load SVG: $_url ${response1.statusCode}');
  }

  /// Returns the alternate /dist/ url or null if irrelevant.
  String? _getAlternateUrl() {
    const String lastPathSegment = '/dist/';
    if (_url.contains(lastPathSegment)) {
      return null;
    }
    final int lastSlashPos = _url.lastIndexOf('/');
    if (lastSlashPos == -1 ||
        lastSlashPos == 0 ||
        lastSlashPos == _url.length - 1) {
      // very unlikely
      return null;
    }
    return '${_url.substring(0, lastSlashPos)}'
        '$lastPathSegment'
        '${_url.substring(lastSlashPos + 1)}';
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
                : ui.ColorFilter.mode(widget.helper.color!, ui.BlendMode.srcIn),
            fit: BoxFit.contain,
            semanticsLabel:
                widget.helper.semanticsLabel ??
                SvgCache.getSemanticsLabel(context, _url),
            placeholderBuilder: (BuildContext context) => SvgAsyncAsset(
              widget.helper,
              loadingBuilder: widget.loadingBuilder,
              errorBuilder: widget.errorBuilder,
            ),
          );
        }
      }
      if (snapshot.error != null) {
        String? findWarningLabel() {
          const List<String> warningLabels = <String>[
            'Failed host lookup',
            'Connection timed out',
            'Connection reset by peer',
          ];
          final String error = snapshot.error.toString();
          for (final String warningLabel in warningLabels) {
            if (error.contains(warningLabel)) {
              return warningLabel;
            }
          }
          return null;
        }

        final String? warningLabel = findWarningLabel();
        if (warningLabel != null) {
          Logs.w('$warningLabel for "$_url"', ex: snapshot.error);
        } else {
          Logs.e('Could really not download "$_url"', ex: snapshot.error);
        }
      }
      return SvgAsyncAsset(widget.helper);
    },
  );
}

/// Network cache, with url as key and SVG data as value.
Map<String, String> _networkCache = <String, String>{};

typedef WidgetErrorBuilder =
    Widget Function(BuildContext context, dynamic exception);
