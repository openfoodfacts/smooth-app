import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/tagline/tagline_model.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/services/smooth_services.dart';

part 'tagline_json.dart';

/// The TagLine provides one one side a list of news and on the other a feed
/// containing the some of the news
///
/// The TagLine is fetched on the server and cached locally (1 day).
/// To be notified of changes, listen to this [ChangeNotifier] and more
/// particularly to the [state] property
class TagLineProvider extends ChangeNotifier {
  TagLineProvider(UserPreferences preferences)
      : _state = const TagLineLoading(),
        _preferences = preferences,
        _domain = preferences.getDevModeString(
                UserPreferencesDevMode.userPreferencesTestEnvDomain) ??
            '',
        _prodEnv = preferences
                .getFlag(UserPreferencesDevMode.userPreferencesFlagProd) ??
            true {
    _preferences.addListener(_onPreferencesChanged);
    loadTagLine();
  }

  final UserPreferences _preferences;

  TagLineState _state;

  bool get hasContent => _state is TagLineLoaded;

  Future<void> loadTagLine({bool forceUpdate = false}) async {
    _emit(const TagLineLoading());

    final String locale = ProductQuery.getLocaleString();
    if (locale.startsWith('-')) {
      // ProductQuery not ready
      return;
    }

    final File cacheFile = await _tagLineCacheFile;
    String? jsonString;
    // Try from the cache first
    if (!forceUpdate && _isTagLineCacheValid(cacheFile)) {
      jsonString = cacheFile.readAsStringSync();
    }

    if (jsonString == null || jsonString.isEmpty == true) {
      jsonString = await _fetchTagLine();
    }

    if (jsonString?.isNotEmpty != true) {
      _emit(const TagLineError('JSON file is empty'));
      return;
    }

    final TagLine? tagLine = await Isolate.run(
        () => _parseJSONAndGetLocalizedContent(jsonString!, locale));
    if (tagLine == null) {
      _emit(const TagLineError('Unable to parse the JSON file'));
      Logs.e('Unable to parse the Tagline file');
    } else {
      _emit(TagLineLoaded(tagLine));
      Logs.i('TagLine reloaded');
    }
  }

  void _emit(TagLineState state) {
    _state = state;
    try {
      notifyListeners();
    } catch (_) {}
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

  /// API URL: [https://world.openfoodfacts.[org/net]/resources/files/tagline-off-ios-v3.json]
  /// or [https://world.openfoodfacts.[org/net]/resources/files/tagline-off-android-v3.json]
  Future<String?> _fetchTagLine() async {
    try {
      final UriProductHelper uriProductHelper = ProductQuery.uriProductHelper;
      final Map<String, String> headers = <String, String>{};
      final Uri uri = uriProductHelper.getUri(path: _tagLineUrl);

      if (uriProductHelper.userInfoForPatch != null) {
        headers['Authorization'] =
            'Basic ${base64Encode(utf8.encode(uriProductHelper.userInfoForPatch!))}';
      }

      final http.Response response = await http.get(uri, headers: headers);

      if (response.statusCode == 404) {
        Logs.e("Remote file $uri doesn't exist!");
        throw Exception('Incorrect URL= $uri');
      }

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
      return '/resources/files/tagline-off-ios-v3.json';
    } else {
      return '/resources/files/tagline-off-android-v3.json';
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

  bool? _prodEnv;
  String? _domain;

  /// [ProductQuery.uriProductHelper] is not synced yet,
  /// so we have to check it manually
  Future<void> _onPreferencesChanged() async {
    final String domain = _preferences.getDevModeString(
            UserPreferencesDevMode.userPreferencesTestEnvDomain) ??
        '';
    final bool prodEnv =
        _preferences.getFlag(UserPreferencesDevMode.userPreferencesFlagProd) ??
            true;

    if (domain != _domain || prodEnv != _prodEnv) {
      _domain = domain;
      _prodEnv = prodEnv;
      loadTagLine(forceUpdate: true);
    }
  }

  @override
  void dispose() {
    _preferences.removeListener(_onPreferencesChanged);
    super.dispose();
  }
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
