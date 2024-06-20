import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_model.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/services/smooth_services.dart';

part 'newsfeed_json.dart';

/// This provides one one side a list of news and on the other a feed of news.
/// A feed contains some of the news?
///
/// The content is fetched on the server and cached locally (1 day).
/// To be notified of changes, listen to this [ChangeNotifier] and more
/// particularly to the [state] property.
class AppNewsProvider extends ChangeNotifier {
  AppNewsProvider(UserPreferences preferences)
      : _state = const AppNewsStateLoading(),
        _preferences = preferences,
        _uriOverride = preferences.getDevModeString(
            UserPreferencesDevMode.userPreferencesCustomNewsJSONURI),
        _domain = preferences.getDevModeString(
            UserPreferencesDevMode.userPreferencesTestEnvDomain),
        _prodEnv = preferences
            .getFlag(UserPreferencesDevMode.userPreferencesFlagProd) {
    _preferences.addListener(_onPreferencesChanged);
    loadLatestNews();
  }

  final UserPreferences _preferences;

  AppNewsState _state;

  bool get hasContent =>
      _state is AppNewsStateLoaded &&
      (_state as AppNewsStateLoaded).content.hasContent;

  Future<void> loadLatestNews({bool forceUpdate = false}) async {
    _emit(const AppNewsStateLoading());

    final String locale = ProductQuery.getLocaleString();
    if (locale.startsWith('-')) {
      // ProductQuery not ready
      return;
    }

    final File cacheFile = await _newsCacheFile;
    String? jsonString;
    // Try from the cache first
    if (!forceUpdate && _isNewsCacheValid(cacheFile)) {
      jsonString = cacheFile.readAsStringSync();
    }

    if (jsonString == null || jsonString.isEmpty == true) {
      jsonString = await _fetchJSON();
    }

    if (jsonString?.isNotEmpty != true) {
      _emit(const AppNewsStateError('JSON news file is empty'));
      return;
    }

    final AppNews? appNews = await Isolate.run(
        () => _parseJSONAndGetLocalizedContent(jsonString!, locale));
    if (appNews == null) {
      _emit(const AppNewsStateError('Unable to parse the JSON news file'));
      Logs.e('Unable to parse the JSON news file');
    } else {
      _emit(AppNewsStateLoaded(appNews, cacheFile.lastModifiedSync()));
      Logs.i('News ${forceUpdate ? 're' : ''}loaded');
    }
  }

  void _emit(AppNewsState state) {
    _state = state;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  AppNewsState get state => _state;

  static Future<AppNews?> _parseJSONAndGetLocalizedContent(
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
  Future<String?> _fetchJSON() async {
    try {
      final UriProductHelper uriProductHelper = ProductQuery.uriProductHelper;
      final Map<String, String> headers = <String, String>{};
      final Uri uri;

      if (_uriOverride?.isNotEmpty == true) {
        uri = Uri.parse(_uriOverride!);
      } else {
        uri = uriProductHelper.getUri(path: _newsUrl);
      }

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
      await _saveNewsToCache(json);
      return json;
    } catch (_) {
      return null;
    }
  }

  /// Based on the platform, the URL may differ
  String get _newsUrl {
    if (Platform.isIOS || Platform.isMacOS) {
      return '/resources/files/tagline-off-ios-v3.json';
    } else {
      return '/resources/files/tagline-off-android-v3.json';
    }
  }

  Future<File> get _newsCacheFile => getApplicationCacheDirectory()
      .then((Directory dir) => File(join(dir.path, 'tagline.json')));

  Future<File> _saveNewsToCache(final String json) async {
    final File file = await _newsCacheFile;
    return file.writeAsString(json);
  }

  bool _isNewsCacheValid(File file) =>
      file.existsSync() &&
      file.lengthSync() > 0 &&
      file
          .lastModifiedSync()
          .isAfter(DateTime.now().add(const Duration(days: -1)));

  bool? _prodEnv;
  String? _domain;
  String? _uriOverride;

  /// [ProductQuery.uriProductHelper] is not synced yet,
  /// so we have to check it manually
  Future<void> _onPreferencesChanged() async {
    final String jsonURI = _preferences.getDevModeString(
            UserPreferencesDevMode.userPreferencesCustomNewsJSONURI) ??
        '';
    final String domain = _preferences.getDevModeString(
            UserPreferencesDevMode.userPreferencesTestEnvDomain) ??
        '';
    final bool prodEnv =
        _preferences.getFlag(UserPreferencesDevMode.userPreferencesFlagProd) ??
            true;

    if (domain != _domain || prodEnv != _prodEnv || jsonURI != _uriOverride) {
      _domain = domain;
      _prodEnv = prodEnv;
      _uriOverride = jsonURI;
      loadLatestNews(forceUpdate: true);
    }
  }

  @override
  void dispose() {
    _preferences.removeListener(_onPreferencesChanged);
    super.dispose();
  }
}

sealed class AppNewsState {
  const AppNewsState();
}

final class AppNewsStateLoading extends AppNewsState {
  const AppNewsStateLoading();
}

class AppNewsStateLoaded extends AppNewsState {
  const AppNewsStateLoaded(this.content, this.lastUpdate);

  final AppNews content;
  final DateTime lastUpdate;
}

class AppNewsStateError extends AppNewsState {
  const AppNewsStateError(this.exception);

  final dynamic exception;
}
