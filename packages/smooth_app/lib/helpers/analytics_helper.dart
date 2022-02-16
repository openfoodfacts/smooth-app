import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:matomo_forever/matomo_forever.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/database/dao_string.dart';
import 'package:smooth_app/database/local_database.dart';

import '../database/dao_int.dart';

// TODO(m123): Check for user consent
// TODO(m123): handle debug mode

class AnalyticsHelper {
  const AnalyticsHelper();

  static const String _initAction = 'started app';
  static const String _scanAction = 'scanned product';
  static const String _productPageAction = 'opened product page';
  static const String _knowledgePanelAction = 'opened knowledge panel page';

  static Future<void> initSentry({Function()? appRunner}) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    await SentryFlutter.init(
      (SentryOptions options) {
        options.dsn =
            'https://22ec5d0489534b91ba455462d3736680@o241488.ingest.sentry.io/5376745';
        options.sentryClientName =
            'sentry.dart.smoothie/${packageInfo.version}';
      },
      appRunner: appRunner,
    );
  }

  static Future<void> initMatomo(
    final BuildContext context,
    final LocalDatabase _localDatabase,
  ) async {
    MatomoForever.init(
      'https://analytics.openfoodfacts.org/matomo.php',
      2,
      id: AnalyticsHelper._getId(),
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
          LocalDatabase _localDatabase, BuildContext context) async =>
      _trackConstructor(
        _initAction,
        idVc: await _getAppVisits(_localDatabase),
        viewTs: await _getPreviousVisitUnix(_localDatabase),
        idTs: await _getFirstVisitUnix(_localDatabase),
        res: MediaQuery.of(context).size.toString(),
        lang: Localizations.localeOf(context).languageCode,
        country: Localizations.localeOf(context).countryCode,
      );

  // TODO(m123): Add eN event name, the product name
  // TODO(m123): Matomo removed leading 0 from the barcode
  static Future<bool> trackScannedProduct({required String barcode}) =>
      _trackConstructor(
        _scanAction,
        eC: 'Scanner',
        eA: 'scanned',
        eV: barcode,
      );

  static Future<bool> trackProductPageOpen({
    required String barcode,
    String? productName,
  }) =>
      _trackConstructor(
        _productPageAction,
        eC: 'Product page',
        eA: 'opened',
        eV: barcode,
        eN: productName,
      );

  // TODO(m123): Check where to call
  static Future<bool> trackKnowledgePanelOpen({
    required String barcode,
    String? knowledgePanelName,
  }) =>
      _trackConstructor(
        _productPageAction,
        eC: 'Knowledge panel',
        eA: 'opened',
        eV: barcode,
        eN: knowledgePanelName,
      );

  /*  Future<bool> trackPersonalRanking({
      required int products,
      required int goodProducts,
      required int badProducts,
      required int unkownProducts,
    }) => _trackAction(action: TrackingAction.RANKING, );
  */
  /*
  Future<bool> trackSearch({
    required String parameter,
    required SearchAction action,
    String? data,
  }) {}
*/
  /*
  Future<bool> trackPersonalSearch({
    required String parameter,
    required int products,
    required int goodProducts,
    required int badProducts,
    required int unkownProducts,
  }) {}
*/
  /*
  Future<bool> trackOpenLink({required String url}) =>
      _trackAction(action: TrackingAction.LINK, url: url);
*/

  static Future<bool> _trackConstructor(
    String actionName, {

    ///The full URL for the current action
    String? url,

    /// The current count of visits for this visitor,
    /// needs to be manually stored in local storage
    int? idVc,

    /// The UNIX timestamp of this visitor's previous visit.
    String? viewTs,

    /// The UNIX timestamp of this visitor's first visit.
    String? idTs,

    /// The Campaign name
    String? rcn,

    /// The Campaign Keyword
    String? rck,

    /// The resolution of the device the visitor is using, eg 1280x1024.
    String? res,

    /// An override value for the User-Agent HTTP header field. The user agent
    /// is used to detect the operating system and browser used.
    String? ua,

    /// An override value for the Accept-Language HTTP header field. This
    /// value is used to detect the visitor's country if GeoIP is not enabled.
    String? lang,

    /// will force a new visit to be created for this action
    bool? newVisit,

    /*
    String? dimension0,
    String? dimension1,
    String? dimension2,
    String? dimension3,
    String? dimension4,
    String? dimension5,
    String? dimension6,
    String? dimension7,
    String? dimension8,
    String? dimension9,
    String? dimension10,
         */
    /// An external URL the user has opened. Used for tracking outlink clicks.
    /// We recommend to also set the url parameter to this same value.
    String? link,

    /// URL of a file the user has downloaded.
    String? download,

    /// The Site Search keyword. When specified, the request will not be tracked
    /// as a normal pageview but will instead be tracked as a Site Search request.
    String? search,

    /// optionally specify a search category
    String? searchCat,

    /// the number of search results displayed on the results page
    int? searchCount,

    /// Accepts a six character unique ID that identifies which actions were
    /// performed on a specific page view. When a page was viewed, all following
    /// tracking requests (such as events) during that page view should use the
    /// same pageview ID. Once another page was viewed a new unique ID should be
    /// generated. Use 0-9a-Z as possible characters for the unique ID.
    String? pvId,

    /// If specified, the tracking request will trigger a conversion for the
    /// goal of the website being tracked with this ID.
    String? idGoal,

    /// Stands for custom action. &ca=1 can be optionally sent along any
    /// tracking request that isn't a page view. For example it can be sent
    /// together with an event tracking request e_a=Action&e_c=Category&ca=1.
    /// The advantage being that should you ever disable the event plugin, then
    /// the event tracking requests will be ignored vs if the parameter is not
    /// set, a page view would be tracked even though it isn't a page view.
    /// For more background information check out #16570. Do not use this
    /// parameter together with a ping=1 tracking request.
    bool? ca,

    /// The event category. Must not be empty. (eg. Videos, Music, Games...)
    String? eC,

    /// The event action. Must not be empty. (eg. Play, Pause, Duration,
    /// Add Playlist, Downloaded, Clicked...)
    String? eA,

    /// The event name. (eg. a Movie name, or Song name, or File name...)
    String? eN,

    /// The event value. Must be a float or integer value (numeric)
    String? eV,

    /// The name of the content. For instance 'Ad Foo Bar'.
    /// Required for content tracking.
    String? cN,

    /// The actual content piece. For instance the path to an image,
    /// video, audio, any text
    String? cP,

    /// The name of the interaction with the content. For instance a 'click'
    String? cId,

    ///  Override for the datetime of the request
    ///  (normally the current time is used). This can be used to record visits
    ///  and page views in the past. The expected format is either a datetime
    ///  such as: 2011-04-05 00:11:42 (remember to URL encode the value!),
    ///  or a valid UNIX timestamp such as 1301919102. The datetime must be
    ///  sent in UTC timezone. Note: if you record data in the past, you will
    ///  need to force Matomo to re-process reports for the past dates. If you
    ///  set cdt to a datetime older than 24 hours then token_auth must be set.
    ///  If you set cdt with a datetime in the last 24 hours then you don't need to pass token_auth.
    DateTime? cdt,

    /// An override value for the country. Should be set to the two
    /// letter country code of the visitor (lowercase), eg fr, de, us.
    String? country,

    /// An override value for the region. Should be set to a ISO 3166-2
    /// region code, which are used by MaxMind's and DB-IP's GeoIP2 databases.
    /// See here for a list of them for every country.
    String? region,

    /// The name of the city the visitor is located in, eg, Tokyo.
    String? city,

    /// Additional data to send to the Matomo server.
    Map<String, String>? customData,
  }) async {
    final DateTime date = DateTime.now();

    final Map<String, String> addedData = <String, String>{
      'action_name': actionName
    };

    addedData.addIfVAndNew('url', url);
    addedData.addIfVAndNew('rand', Random().toString());

    addedData.addIfVAndNew('_idvc', idVc?.toString());
    addedData.addIfVAndNew('_viewts', viewTs);
    addedData.addIfVAndNew('_idts', idTs);
    addedData.addIfVAndNew('_rcn', rcn);
    addedData.addIfVAndNew('_rck', rck);
    addedData.addIfVAndNew('res', res);
    addedData.addIfVAndNew('h', date.hour.toString());
    addedData.addIfVAndNew('m', date.minute.toString());
    addedData.addIfVAndNew('s', date.second.toString());

    addedData.addIfVAndNew('ua', ua);
    addedData.addIfVAndNew('lang', addedData.addIfVAndNew('lang', lang));
    addedData.addIfVAndNew('uid', _getId());
    addedData.addIfVAndNew(
      'new_visit',
      newVisit != null
          ? newVisit
              ? '1'
              : '0'
          : null,
    );
    /*
    addedData.addIfVAndNew('dimension0', dimension0);
    addedData.addIfVAndNew('dimension1', dimension1);
    addedData.addIfVAndNew('dimension2', dimension2);
    addedData.addIfVAndNew('dimension3', dimension3);
    addedData.addIfVAndNew('dimension4', dimension4);
    addedData.addIfVAndNew('dimension5', dimension5);
    addedData.addIfVAndNew('dimension6', dimension6);
    addedData.addIfVAndNew('dimension7', dimension7);
    addedData.addIfVAndNew('dimension8', dimension8);
    addedData.addIfVAndNew('dimension9', dimension9);
    addedData.addIfVAndNew('dimension10', dimension10);
    */
    addedData.addIfVAndNew('link', link);
    addedData.addIfVAndNew('download', download);
    addedData.addIfVAndNew('search', search);
    addedData.addIfVAndNew('search_cat', searchCat);
    addedData.addIfVAndNew('search_count', searchCount?.toString());
    addedData.addIfVAndNew('pv_id', pvId);
    addedData.addIfVAndNew('idgoal', idGoal);
    addedData.addIfVAndNew(
        'ca',
        ca != null
            ? ca
                ? '1'
                : '0'
            : null);
    addedData.addIfVAndNew('e_c', eC);
    addedData.addIfVAndNew('e_a', eA);
    addedData.addIfVAndNew('e_n', eN);
    addedData.addIfVAndNew('e_v', eV);
    addedData.addIfVAndNew('c_n', cN);
    addedData.addIfVAndNew('c_p', cP);

    addedData.addIfVAndNew('c_i', cId);
    addedData.addIfVAndNew('cdt', cdt?.millisecondsSinceEpoch.toString());
    addedData.addIfVAndNew('country', country);
    addedData.addIfVAndNew('region', region);
    addedData.addIfVAndNew('city', city);
    if (customData != null) {
      addedData.addAll(customData);
    }

    return MatomoForever.sendDataOrBulk(addedData);
  }

  static String? _getId() {
    return kDebugMode ? 'smoothie-debug' : OpenFoodAPIConfiguration.uuid;
  }

  /// Returns the amount the user has opened the app
  static Future<int> _getAppVisits(LocalDatabase _localDatabase) async {
    const String _userVisits = 'appVisits';

    final DaoInt daoInt = DaoInt(_localDatabase);

    int visits = await daoInt.get(_userVisits) ?? 0;
    visits++;
    daoInt.put(_userVisits, visits);

    return visits;
  }

  static Future<String?> _getPreviousVisitUnix(
      LocalDatabase _localDatabase) async {
    const String _latestVisit = 'previousVisitUnix';

    final DaoString daoString = DaoString(_localDatabase);

    final String? latestVisit = await daoString.get(_latestVisit);

    daoString.put(
      _latestVisit,
      DateTime.now().millisecondsSinceEpoch.toString(),
    );

    return latestVisit;
  }

  static Future<String?> _getFirstVisitUnix(
      LocalDatabase _localDatabase) async {
    const String _firstVisit = 'firstVisitUnix';

    final DaoString daoString = DaoString(_localDatabase);

    final String? latestVisit = await daoString.get(_firstVisit);

    if (latestVisit == null) {
      daoString.put(
        _firstVisit,
        DateTime.now().millisecondsSinceEpoch.toString(),
      );
    }

    return latestVisit;
  }
}
