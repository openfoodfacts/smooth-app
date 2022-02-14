import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:matomo_forever/matomo_forever.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/database/local_database.dart';

import '../database/product_query.dart';

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
    final BuildContext context, final LocalDatabase _localDatabase) async {
  MatomoForever.init(
    'https://analytics.openfoodfacts.org/matomo.php',
    2,
    // Personal identifyer
    id: kDebugMode ? 'smoothie-debug' : OpenFoodAPIConfiguration.uuid,
    // If we track or not, should be decidable later
    rec: true,
    method: MatomoForeverMethod.post,
    sendImage: false,
    // 32 character authorization key used to authenticate the API request
    tokenAuth: '',
  );
  AnalyticsHelper(context).trackStart();
}

// TODO(m123): Check for user consent
// TODO(m123): handle debug mode

class AnalyticsHelper {
  AnalyticsHelper(this.context);

  final BuildContext context;

  static const String initAction = 'started app';
  static const String scanAction = 'scanned product';
  static const String productPageAction = 'opened product page';
  static const String knowledgePanelAction = 'opened knowledge panel page';

  Future<bool> trackStart() => _trackConstructor(initAction);

  /*
  Future<bool> trackScannedProduct({required String barcode}) =>
      _trackAction(action: TrackingAction.SCAN, barcode: barcode);

  Future<bool> trackProductPageOpen({required String barcode}) =>
      _trackAction(action: TrackingAction.PRODUCT_PAGE, barcode: barcode);

  Future<bool> trackKnowledgePanelOpen({
    required String barcode,
    required String knowledgePanelName,
  }) =>
      _trackAction(
        action: TrackingAction.KNOWLEDGE_PANEL,
        barcode: barcode,
        knowledgePanelName: knowledgePanelName,
      );
*/
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

  Future<bool> _trackConstructor(
    String actionName, {
    String? url,
    String? urlRef,
    String? cvar,
    int? idVc,
    DateTime? viewTs,
    DateTime? idTs,
    String? rcn,
    String? rck,
    bool? fla,
    bool? java,
    bool? dir,
    bool? qt,
    bool? realp,
    bool? pdf,
    bool? wma,
    bool? gears,
    bool? ag,
    bool? cookie,
    String? ua,
    String? cid,
    bool? newVisit,
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
    String? link,
    String? download,
    String? search,
    String? searchCat,
    int? searchCount,
    String? pvId,
    String? idGoal,
    String? revenue,
    int? gtMs,
    String? cs,
    bool? ca,
    int? pfNet,
    int? pfSrv,
    int? pfTfr,
    int? pfDm1,
    int? pfDm2,
    int? pfOnl,
    String? eC,
    String? eA,
    String? eN,
    double? eV,
    String? cN,
    String? cP,
    String? cT,
    String? cId,
    String? ecId,
    String? ecItems,
    String? ecSt,
    String? ecTx,
    String? ecSh,
    String? ecDt,
    DateTime? ects,
    String? cip,
    DateTime? cdt,
    String? region,
    String? city,
    String? lat,
    String? long,
    String? maId,
    String? maRe,
    String? maMt,
    String? maTi,
    String? maPn,
    int? maSt,
    int? maLe,
    int? maPs,
    int? maTtp,
    int? maW,
    int? maH,
    bool? maFs,
    String? maSe,
    Map<String, String>? customData,
  }) async {
    final DateTime date = DateTime.now();
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final Map<String, String> addedData = <String, String>{
      'action_name': actionName
    };

    addedData.addIfVAndNew('url', url);
    addedData.addIfVAndNew('rand', Random().toString());
    addedData.addIfVAndNew('urlref', urlRef);
    addedData.addIfVAndNew('_cvar', cvar);
    addedData.addIfVAndNew('_idvc', idVc?.toString());
    addedData.addIfVAndNew(
        '_viewts', viewTs?.millisecondsSinceEpoch.toString());
    addedData.addIfVAndNew('_idts', idTs?.millisecondsSinceEpoch.toString());
    addedData.addIfVAndNew('_rcn', rcn);
    addedData.addIfVAndNew('_rck', rck);
    addedData.addIfVAndNew('res', mediaQuery.size.toString());
    addedData.addIfVAndNew('h', date.hour.toString());
    addedData.addIfVAndNew('m', date.minute.toString());
    addedData.addIfVAndNew('s', date.second.toString());
    addedData.addIfVAndNew(
        'fla',
        fla != null
            ? fla
                ? '1'
                : '0'
            : null);
    addedData.addIfVAndNew(
        'java',
        java != null
            ? java
                ? '1'
                : '0'
            : null);
    addedData.addIfVAndNew(
        'dir',
        dir != null
            ? dir
                ? '1'
                : '0'
            : null);
    addedData.addIfVAndNew(
        'qt',
        qt != null
            ? qt
                ? '1'
                : '0'
            : null);
    addedData.addIfVAndNew(
        'realp',
        realp != null
            ? realp
                ? '1'
                : '0'
            : null);
    addedData.addIfVAndNew(
        'pdf',
        pdf != null
            ? pdf
                ? '1'
                : '0'
            : null);
    addedData.addIfVAndNew(
        'wma',
        wma != null
            ? wma
                ? '1'
                : '0'
            : null);
    addedData.addIfVAndNew(
        'gears',
        gears != null
            ? gears
                ? '1'
                : '0'
            : null);
    addedData.addIfVAndNew(
        'ag',
        ag != null
            ? ag
                ? '1'
                : '0'
            : null);
    addedData.addIfVAndNew(
        'cookie',
        cookie != null
            ? cookie
                ? '1'
                : '0'
            : null);
    addedData.addIfVAndNew('ua', ua);
    addedData.addIfVAndNew(
      'lang',
      ProductQuery.getLanguage()?.toString() ??
          Localizations.localeOf(context).languageCode,
    );
    addedData.addIfVAndNew('uid', OpenFoodAPIConfiguration.uuid);
    addedData.addIfVAndNew('cid', cid);
    addedData.addIfVAndNew(
        'new_visit',
        newVisit != null
            ? newVisit
                ? '1'
                : '0'
            : null);
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
    addedData.addIfVAndNew('link', link);
    addedData.addIfVAndNew('download', download);
    addedData.addIfVAndNew('search', search);
    addedData.addIfVAndNew('search_cat', searchCat);
    addedData.addIfVAndNew('search_count', searchCount?.toString());
    addedData.addIfVAndNew('pv_id', pvId);
    addedData.addIfVAndNew('idgoal', idGoal);
    addedData.addIfVAndNew('revenue', revenue);
    addedData.addIfVAndNew('gt_ms', gtMs?.toString());
    addedData.addIfVAndNew('cs', cs);
    addedData.addIfVAndNew(
        'ca',
        ca != null
            ? ca
                ? '1'
                : '0'
            : null);
    addedData.addIfVAndNew('pf_net', pfNet?.toString());
    addedData.addIfVAndNew('pf_srv', pfSrv?.toString());
    addedData.addIfVAndNew('pf_tfr', pfTfr?.toString());
    addedData.addIfVAndNew('pf_dm1', pfDm1?.toString());
    addedData.addIfVAndNew('pf_dm2', pfDm2?.toString());
    addedData.addIfVAndNew('pf_onl', pfOnl?.toString());
    addedData.addIfVAndNew('e_c', eC);
    addedData.addIfVAndNew('e_a', eA);
    addedData.addIfVAndNew('e_n', eN);
    addedData.addIfVAndNew('e_v', eV?.toString());
    addedData.addIfVAndNew('c_n', cN);
    addedData.addIfVAndNew('c_p', cP);
    addedData.addIfVAndNew('c_t', cT);
    addedData.addIfVAndNew('c_i', cId);
    addedData.addIfVAndNew('ec_id', ecId);
    addedData.addIfVAndNew('ec_items', ecItems);
    addedData.addIfVAndNew('ec_st', ecSt);
    addedData.addIfVAndNew('ec_tx', ecTx);
    addedData.addIfVAndNew('ec_sh', ecSh);
    addedData.addIfVAndNew('ec_dt', ecDt);
    addedData.addIfVAndNew('_ects', ects?.millisecondsSinceEpoch.toString());
    addedData.addIfVAndNew('cip', cip);
    addedData.addIfVAndNew('cdt', cdt?.millisecondsSinceEpoch.toString());
    addedData.addIfVAndNew(
      'country',
      Localizations.localeOf(context).countryCode,
    );
    addedData.addIfVAndNew('region', region);
    addedData.addIfVAndNew('city', city);
    addedData.addIfVAndNew('lat', lat);
    addedData.addIfVAndNew('long', long);
    addedData.addIfVAndNew('ma_id', maId);
    addedData.addIfVAndNew('ma_re', maRe);
    addedData.addIfVAndNew('ma_mt', maMt);
    addedData.addIfVAndNew('ma_ti', maTi);
    addedData.addIfVAndNew('ma_pn', maPn);
    addedData.addIfVAndNew('ma_st', maSt?.toString());
    addedData.addIfVAndNew('ma_le', maLe?.toString());
    addedData.addIfVAndNew('ma_ps', maPs?.toString());
    addedData.addIfVAndNew('ma_ttp', maTtp?.toString());
    addedData.addIfVAndNew('ma_w', maW?.toString());
    addedData.addIfVAndNew('ma_h', maH?.toString());
    addedData.addIfVAndNew(
        'ma_fs',
        maFs != null
            ? maFs
                ? '1'
                : '0'
            : null);
    addedData.addIfVAndNew('ma_se', maSe);
    if (customData != null) {
      addedData.addAll(customData);
    }
    return MatomoForever.sendDataOrBulk(addedData);
  }
}
