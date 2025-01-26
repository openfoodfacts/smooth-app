import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
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

    final PackageInfo app = await PackageInfo.fromPlatform();
    final int appLaunches = _preferences.appLaunches;

    final AppNews? appNews = await Isolate.run(
      () => _parseJSONAndGetLocalizedContent(
        jsonString!,
        locale,
        app.version,
        appLaunches,
      ),
    );
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
    WidgetsBinding.instance
      ..addPostFrameCallback((_) => notifyListeners())
      ..ensureVisualUpdate();
  }

  AppNewsState get state => _state;

  static Future<AppNews?> _parseJSONAndGetLocalizedContent(
    String json,
    String locale,
    String appVersion,
    int appLaunches,
  ) async {
    try {
      final _TagLineJSON tagLineJSON = _TagLineJSON.fromJson(
        jsonDecode(json) as Map<dynamic, dynamic>,
      );
      return tagLineJSON.toTagLine(locale, appVersion, appLaunches);
    } catch (_) {
      return null;
    }
  }

  /// The content is stored on GitHub with two static files: one for Android,
  /// and the other for iOS.
  /// [https://github.com/openfoodfacts/smooth-app_assets/tree/main/prod/tagline]
  Future<String?> _fetchJSON() async {
    try {
      final Uri uri;

      if (_uriOverride?.isNotEmpty == true) {
        uri = Uri.parse(_uriOverride!);
      } else {
        uri = Uri.parse(_newsUrl);
      }

      final http.Response response = await http.get(uri);

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
    final String env = _prodEnv != false ? 'prod' : 'dev';

    if (Platform.isIOS || Platform.isMacOS) {
      return 'https://raw.githubusercontent.com/openfoodfacts/smooth-app_assets/refs/heads/main/$env/tagline/ios/main.json';
    } else {
      return 'https://raw.githubusercontent.com/openfoodfacts/smooth-app_assets/refs/heads/main/$env/tagline/android/main.json';
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
  String? _uriOverride;

  /// [ProductQuery._uriProductHelper] is not synced yet,
  /// so we have to check it manually
  Future<void> _onPreferencesChanged() async {
    final String jsonURI = _preferences.getDevModeString(
            UserPreferencesDevMode.userPreferencesCustomNewsJSONURI) ??
        '';
    final bool prodEnv =
        _preferences.getFlag(UserPreferencesDevMode.userPreferencesFlagProd) ??
            true;

    if (prodEnv != _prodEnv || jsonURI != _uriOverride) {
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
