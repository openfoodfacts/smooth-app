import 'dart:convert';

import 'package:http/http.dart' as http;

/// A tagline is the text displayed on the homepage
/// It may contain a link to an external resource
/// No cache is expected here
/// API URL: [https://world.openfoodfacts.org/files/tagline/tagline-off.json]
Future<TagLineItem?> fetchTagLine(String locale) {
  assert(locale.isNotEmpty);

  return http
      .get(
        Uri.https(
          'world.openfoodfacts.org',
          '/files/tagline/tagline-off.json',
        ),
      )
      .then((http.Response value) =>
          _TagLine.fromJSON(jsonDecode(value.body) as List<dynamic>))
      .then(
          (_TagLine tagLine) => tagLine._items[locale] ?? tagLine._items['en'])
      .catchError((dynamic err) => null);
}

class _TagLine {
  _TagLine.fromJSON(List<dynamic> json)
      : _items = Map<String, TagLineItem>.fromEntries(
          json.map(
            (dynamic element) {
              return MapEntry<String, TagLineItem>(
                (element as Map<dynamic, dynamic>)['language'] as String,
                TagLineItem._fromJSON(element['data'] as Map<dynamic, dynamic>),
              );
            },
          ),
        );

  /// Taglines by their locale
  final Map<String, TagLineItem> _items;

  /// Finds a tagline with its locale
  TagLineItem? operator [](String key) =>
      _items[key] ?? _items[key.substring(0, 2)];
}

class TagLineItem {
  TagLineItem._fromJSON(Map<dynamic, dynamic> json)
      : url = json['url'] as String,
        message = json['message'] as String;

  final String url;
  final String message;

  bool get hasLink => url.startsWith('http');
}
