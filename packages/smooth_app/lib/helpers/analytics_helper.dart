import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:matomo_forever/matomo_forever.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/tracking_database_helper.dart';

/// Helper for logging usage of core features and exceptions
/// Logging:
/// - Errors and Problems (sentry)
/// - App start
/// - Product scan
/// - Product page open
/// - Knowledge panel open
/// - personalized ranking (without sharing the preferences)
/// - search
/// - external links
class AnalyticsHelper {
  AnalyticsHelper._();

  static bool _crashReports = false;
  static bool _analyticsReports = false;

  static const String _initAction = 'started app';
  static const String _scanAction = 'scanned product';
  static const String _productPageAction = 'opened product page';
  static const String _knowledgePanelAction = 'opened knowledge panel page';
  static const String _personalizedRankingAction = 'personalized ranking';
  static const String _searchAction = 'search';
  static const String _linkAction = 'opened link';

  /// The event category. Must not be empty. (eg. Videos, Music, Games...)
  static const String _eventCategory = 'e_c';

  /// Must not be empty. (eg. Play, Pause, Duration, Add
  /// Playlist, Downloaded, Clicked...)
  static const String _eventAction = 'e_a';

  /// The event name. (eg. a Movie name, or Song name, or File name...)
  static const String _eventName = 'e_n';

  /// Must be a float or integer value (numeric), not a string.
  static const String _eventValue = 'e_v';

  static String latestSearch = '';

  static Future<void> initSentry({Function()? appRunner}) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    await SentryFlutter.init(
      (SentryOptions options) {
        options.dsn =
            'https://22ec5d0489534b91ba455462d3736680@o241488.ingest.sentry.io/5376745';
        options.sentryClientName =
            'sentry.dart.smoothie/${packageInfo.version}';
        // To set a uniform sample rate
        options.tracesSampleRate = 1.0;
        options.beforeSend = _beforeSend;
      },
      appRunner: appRunner,
    );
  }

  static void setCrashReports(final bool crashReports) =>
      _crashReports = crashReports;

  static void setAnalyticsReports(final bool analyticsReports) =>
      _analyticsReports = analyticsReports;

  static FutureOr<SentryEvent?> _beforeSend(SentryEvent event,
      {dynamic hint}) async {
    if (!_crashReports) {
      return null;
    }
    return event;
  }

  static void initMatomo(
    final BuildContext context,
    final bool screenshotMode,
  ) {
    if (screenshotMode) {
      setCrashReports(false);
      setAnalyticsReports(false);
      return;
    }
    MatomoForever.init(
      'https://analytics.openfoodfacts.org/matomo.php',
      2,
      id: _getId(),
      // If we track or not, should be decidable later
      rec: true,
      method: MatomoForeverMethod.post,
      sendImage: false,
      // 32 character authorization key used to authenticate the API request
      // only needed for request which are more then 24h old
      // tokenAuth: 'xxx',
    );
  }

  static Future<bool> trackStart(
      LocalDatabase _localDatabase, BuildContext context) async {
    final TrackingDatabaseHelper trackingDatabaseHelper =
        TrackingDatabaseHelper(_localDatabase);
    final Size size = MediaQuery.of(context).size;
    final Map<String, String> data = <String, String>{};

    // The current count of visits for this visitor
    data.addIfVAndNew(
      '_idvc',
      trackingDatabaseHelper.getAppVisits().toString(),
    );
    // The UNIX timestamp of this visitor's previous visit
    data.addIfVAndNew(
      '_viewts',
      trackingDatabaseHelper.getPreviousVisitUnix().toString(),
    );
    // The UNIX timestamp of this visitor's first visit
    data.addIfVAndNew(
      '_idts',
      trackingDatabaseHelper.getFirstVisitUnix().toString(),
    );
    // Device resolution
    data.addIfVAndNew('res', '${size.width}x${size.height}');
    data.addIfVAndNew('lang', Localizations.localeOf(context).languageCode);
    data.addIfVAndNew('country', Localizations.localeOf(context).countryCode);

    return _track(
      _initAction,
      data,
    );
  }

  // TODO(m123): Matomo removes leading 0 from the barcode
  static Future<bool> trackScannedProduct({required String barcode}) => _track(
        _scanAction,
        <String, String>{
          _eventCategory: 'Scanner',
          _eventAction: 'Scanned',
          _eventValue: barcode,
        },
      );

  static Future<bool> trackProductPageOpen({
    required Product product,
  }) {
    final Map<String, String> data = <String, String>{
      _eventCategory: 'Product page',
      _eventAction: 'opened',
    };
    data.addIfVAndNew(_eventValue, product.productName);
    data.addIfVAndNew(_eventName, product.productName);

    return _track(
      _productPageAction,
      data,
    );
  }

  static Future<bool> trackKnowledgePanelOpen({
    String? knowledgePanelName,
  }) {
    final Map<String, String> data = <String, String>{
      _eventCategory: 'Knowledge panel',
      _eventAction: 'opened',
    };
    data.addIfVAndNew(_eventName, knowledgePanelName);

    return _track(
      _knowledgePanelAction,
      data,
    );
  }

  static Future<bool> trackPersonalizedRanking({
    required String title,
    required int products,
    required int goodProducts,
    required int badProducts,
    required int unknownProducts,
  }) =>
      _track(
        _personalizedRankingAction,
        <String, String>{
          'title': title,
          'productsCount': '$products',
          'goodProducts': '$goodProducts',
          'badProducts': '$badProducts',
          'unkownProducts': '$unknownProducts',
        },
      );

  static void trackSearch({
    required String search,
    String? searchCategory,
    int? searchCount,
  }) {
    final Map<String, String> data = <String, String>{
      'search': search,
    };
    data.addIfVAndNew('search_cat', searchCategory);
    data.addIfVAndNew('search_count', searchCount);

    if (data.toString() == latestSearch) {
      return;
    }
    latestSearch = data.toString();

    _track(
      _searchAction,
      data,
    );
  }

  static Future<bool> trackOpenLink({required String url}) => _track(
        _linkAction,
        <String, String>{
          'url': url,
          'link': url,
        },
      );

  static Future<bool> _track(
      String actionName, Map<String, String> data) async {
    if (!_analyticsReports) {
      return false;
    }
    final DateTime date = DateTime.now();
    final Map<String, String> addedData = <String, String>{
      'action_name': actionName,
      //Random number to avoid the tracking request being cached by the browser or a proxy.
      'rand': Random().nextInt(1000).toString(),
      //Adding the tracking time
      'h': date.hour.toString(),
      'm': date.minute.toString(),
      's': date.second.toString(),
    };
    // User identifier
    addedData.addIfVAndNew('uid', _getId());
    addedData.addAll(data);

    return MatomoForever.sendDataOrBulk(addedData);
  }

  static String? _getId() {
    return kDebugMode ? 'smoothie-debug' : OpenFoodAPIConfiguration.uuid;
  }
}
