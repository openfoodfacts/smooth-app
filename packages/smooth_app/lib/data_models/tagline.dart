import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:smooth_app/helpers/collections_helper.dart';

/// A tagline is the text displayed on the homepage
/// It may contain a link to an external resource
/// No cache is expected here
/// API URL: [https://world.openfoodfacts.org/files/tagline-off-ios-v2.json] or
/// [https://world.openfoodfacts.org/files/tagline-off-android-v2.json]
Future<TagLineItem?> fetchTagLine(String locale) {
  assert(locale.isNotEmpty);

  return http
      .get(
        Uri.https(
          'world.openfoodfacts.org',
          _tagLineUrl,
        ),
      )
      .then(
          (http.Response value) => const Utf8Decoder().convert(value.bodyBytes))
      .then((String value) =>
          _TagLine.fromJSON(jsonDecode(value) as List<dynamic>))
      .then((_TagLine tagLine) => tagLine[locale] ?? tagLine['en'])
      .catchError((dynamic err) => null);
}

/// Based on the platform, the URL may differ
String get _tagLineUrl {
  if (Platform.isIOS || Platform.isMacOS) {
    return '/files/tagline-off-ios-v2.json';
  } else {
    return '/files/tagline-off-android-v2.json';
  }
}

class _TagLine {
  _TagLine.fromJSON(List<dynamic> json)
      : _items = Map<String, TagLineItem>.fromEntries(
          json.map(
            (dynamic element) {
              return MapEntry<String, TagLineItem>(
                ((element as Map<dynamic, dynamic>)['language'] as String)
                    .toLowerCase(),
                TagLineItem._fromJSON(element['data'] as Map<dynamic, dynamic>),
              );
            },
          ),
        );

  /// Taglines by their locale
  final Map<String, TagLineItem> _items;

  /// Finds a tagline with its locale
  TagLineItem? operator [](String key) {
    final String locale = key.toLowerCase();

    // Let's try with the full locale
    if (_items.containsKey(locale)) {
      return _items[locale];
    }

    // Let's try with the language only (eg => fr_FR to fr)
    final String languageCode = locale.substring(0, 2);

    if (_items.containsKey(languageCode)) {
      return _items[languageCode];
    } else {
      // Finally let's try with a subset (eg => no fr_BE but fr_FR)
      return _items.getValueByKeyStartWith(languageCode, ignoreCase: true);
    }
  }
}

class TagLineItem {
  TagLineItem._fromJSON(Map<dynamic, dynamic> json)
      : url = json['url'] as String,
        message = json['message'] as String;

  final String url;
  final String message;

  bool get hasLink => url.startsWith('http');
}
