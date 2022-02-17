import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:matomo_forever/matomo_forever.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/local_database.dart';

// TODO(m123): Check for user consent
// TODO(m123): handle debug mode

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

const String _initAction = 'started app';
const String _scanAction = 'scanned product';
const String _productPageAction = 'opened product page';
const String _knowledgePanelAction = 'opened knowledge panel page';
const String _personalizedRankingAction = 'personalized ranking';
const String _searchAction = 'search';
const String _linkAction = 'opened link';

/// The event category. Must not be empty. (eg. Videos, Music, Games...)
const String eventCategory = 'e_c';

/// Must not be empty. (eg. Play, Pause, Duration, Add
/// Playlist, Downloaded, Clicked...)
const String eventAction = 'e_a';

/// The event name. (eg. a Movie name, or Song name, or File name...)
const String eventName = 'e_n';

/// Must be a float or integer value (numeric), not a string.
const String eventValue = 'e_v';

String latestSearch = '';

Future<void> initSentry({Function()? appRunner}) async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();

  await SentryFlutter.init(
    (SentryOptions options) {
      options.dsn =
          'https://22ec5d0489534b91ba455462d3736680@o241488.ingest.sentry.io/5376745';
      options.sentryClientName = 'sentry.dart.smoothie/${packageInfo.version}';
    },
    appRunner: appRunner,
  );
}

Future<void> initMatomo(
  final BuildContext context,
  final LocalDatabase _localDatabase,
) async {
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

Future<bool> trackStart(
    LocalDatabase _localDatabase, BuildContext context) async {
  final TrackingHelper trackingHelper = TrackingHelper(_localDatabase);
  final Map<String, String> data = <String, String>{};

  data.addIfVAndNew('_idvc', trackingHelper.getAppVisits().toString());
  data.addIfVAndNew(
    '_viewts',
    trackingHelper.getPreviousVisitUnix().toString(),
  );
  data.addIfVAndNew(
    '_idts',
    trackingHelper.getFirstVisitUnix().toString(),
  );
  data.addIfVAndNew('res', MediaQuery.of(context).size.toString());
  data.addIfVAndNew('lang', Localizations.localeOf(context).languageCode);
  data.addIfVAndNew('country', Localizations.localeOf(context).countryCode);

  return _track(
    _initAction,
    data,
  );
}

// TODO(m123): Matomo removes leading 0 from the barcode
Future<bool> trackScannedProduct({required String barcode}) => _track(
      _scanAction,
      <String, String>{
        eventCategory: 'Scanner',
        eventAction: 'Scanned',
        eventValue: barcode,
      },
    );

Future<bool> trackProductPageOpen({
  required Product product,
}) {
  final Map<String, String> data = <String, String>{
    eventCategory: 'Product page',
    eventAction: 'opened',
  };
  data.addIfVAndNew(eventValue, product.productName);
  data.addIfVAndNew(eventName, product.productName);

  return _track(
    _productPageAction,
    data,
  );
}

// TODO(m123): Check where to call
Future<bool> trackKnowledgePanelOpen({
  required String barcode,
  String? knowledgePanelName,
}) {
  final Map<String, String> data = <String, String>{
    eventCategory: 'Knowledge panel',
    eventAction: 'opened',
    eventValue: barcode,
  };
  data.addIfVAndNew(eventName, knowledgePanelName);

  return _track(
    _knowledgePanelAction,
    data,
  );
}

Future<bool> trackPersonalizedRanking({
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

void trackSearch({
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

Future<bool> trackOpenLink({required String url}) => _track(
      _linkAction,
      <String, String>{
        'url': url,
        'link': url,
      },
    );

Future<bool> _track(String actionName, Map<String, String> data) {
  final DateTime date = DateTime.now();
  final Map<String, String> addedData = <String, String>{
    'action_name': actionName,
    'rand': Random().toString(),
    'h': date.hour.toString(),
    'm': date.minute.toString(),
    's': date.second.toString(),
  };
  addedData.addIfVAndNew('uid', _getId());
  addedData.addAll(data);

  return MatomoForever.sendDataOrBulk(addedData);
}

String? _getId() {
  return kDebugMode ? 'smoothie-debug' : OpenFoodAPIConfiguration.uuid;
}

class TrackingHelper {
  const TrackingHelper(this._localDatabase);
  final LocalDatabase _localDatabase;

  /// Returns the amount the user has opened the app
  int getAppVisits() {
    const String _userVisits = 'appVisits';

    final DaoInt daoInt = DaoInt(_localDatabase);

    int visits = daoInt.get(_userVisits) ?? 0;
    visits++;
    daoInt.put(_userVisits, visits);

    return visits;
  }

  int? getPreviousVisitUnix() {
    const String _latestVisit = 'previousVisitUnix';

    final DaoInt daoInt = DaoInt(_localDatabase);

    final int? latestVisit = daoInt.get(_latestVisit);

    daoInt.put(
      _latestVisit,
      DateTime.now().millisecondsSinceEpoch,
    );

    return latestVisit;
  }

  int? getFirstVisitUnix() {
    const String _firstVisit = 'firstVisitUnix';

    final DaoInt daoInt = DaoInt(_localDatabase);

    final int? firstVisit = daoInt.get(_firstVisit);

    if (firstVisit == null) {
      daoInt.put(
        _firstVisit,
        DateTime.now().millisecondsSinceEpoch,
      );
    }

    return firstVisit;
  }
}
