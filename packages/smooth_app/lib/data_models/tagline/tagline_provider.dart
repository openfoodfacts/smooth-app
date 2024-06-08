import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smooth_app/data_models/tagline/tagline_model.dart';
import 'package:smooth_app/query/product_query.dart';

part 'tagline_json.dart';

/// The TagLine provides one one side a list of news and on the other a feed
/// containing the some of the news
///
/// The TagLine is fetched on the server and cached locally (1 day).
/// To be notified of changes, listen to this [ChangeNotifier] and more
/// particularly to the [state] property
class TagLineProvider extends ChangeNotifier {
  TagLineProvider() : _state = const TagLineLoading() {
    loadTagLine();
  }

  TagLineState _state;

  bool get hasContent => _state is TagLineLoaded;

  Future<void> loadTagLine({bool forceUpdate = false}) async {
    _state = const TagLineLoading();

    final String locale = ProductQuery.getLocaleString();

    final File cacheFile = await _tagLineCacheFile;
    String? jsonString;
    if (!forceUpdate && _isTagLineCacheValid(cacheFile)) {
      jsonString = cacheFile.readAsStringSync();
    } else {
      jsonString = await _fetchTagLine();
    }

    if (jsonString?.isNotEmpty != true) {
      _state = const TagLineError('JSON file is empty');
      return;
    }

    final TagLine? tagLine = await Isolate.run(
        () => _parseJSONAndGetLocalizedContent(jsonString!, locale));
    if (tagLine == null) {
      _state = const TagLineError('Unable to parse the JSON file');
    } else {
      _state = TagLineLoaded(tagLine);
    }
  }

  TagLineState get state => _state;

  static Future<TagLine?> _parseJSONAndGetLocalizedContent(
    String json,
    String locale,
  ) async {
    try {
      final _TagLineJSON tagLineJSON =
          _TagLineJSON.fromJson(jsonDecode(json) as Map<dynamic, dynamic>);
      return tagLineJSON.toTagLine(locale);
    } catch (_) {
      return null;
    }
  }

  /// API URL: [https://world.openfoodfacts.org/files/tagline-off-ios-v3.json]
  /// or [https://world.openfoodfacts.org/files/tagline-off-android-v3.json]
  Future<String?> _fetchTagLine() async {
    try {
      final http.Response response = await http.get(Uri.https(
          'mock_18ef88079f344225853f73970c3fa2b2.mock.insomnia.rest',
          _tagLineUrl));

      final String json = const Utf8Decoder().convert(response.bodyBytes);
      if (!json.startsWith('[') && !json.startsWith('{')) {
        throw Exception('Invalid JSON');
      }
      await _saveTagLineToCache(json);
      return json;
    } catch (_) {
      return null;
    }
  }

  /// Based on the platform, the URL may differ
  String get _tagLineUrl {
    if (Platform.isIOS || Platform.isMacOS) {
      return '/files/tagline-off-ios-v3.json';
    } else {
      return '/files/tagline-off-android-v3.json';
    }
  }

  Future<File> get _tagLineCacheFile => getApplicationCacheDirectory()
      .then((Directory dir) => File(join(dir.path, 'tagline.json')));

  Future<File> _saveTagLineToCache(final String json) async {
    final File file = await _tagLineCacheFile;
    return file.writeAsString(json);
  }

  bool _isTagLineCacheValid(File file) =>
      file.existsSync() &&
      file.lengthSync() > 0 &&
      file
          .lastModifiedSync()
          .isAfter(DateTime.now().add(const Duration(days: -1)));
}

sealed class TagLineState {
  const TagLineState();
}

final class TagLineLoading extends TagLineState {
  const TagLineLoading();
}

class TagLineLoaded extends TagLineState {
  const TagLineLoaded(this.tagLineContent);

  final TagLine tagLineContent;
}

class TagLineError extends TagLineState {
  const TagLineError(this.exception);

  final dynamic exception;
}
