import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:matomo_forever/matomo_forever.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';

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

Future<void> initMatomo(final LocalDatabase _localDatabase) async {
  MatomoForever.init(
    'https://analytics.openfoodfacts.org/',
    2,
    // Personal identifyer
    id: OpenFoodAPIConfiguration.uuid,
    // If we track or not, should be decidable later
    rec: true,
    method: MatomoForeverMethod.post,
    sendImage: false,
    // 32 character authorization key used to authenticate the API request
    tokenAuth: 'tokenAuth',
  );
}

enum TrackingAction {
  START,
  SCAN,
  PRODUCT_PAGE,
  KNOWLEDGE_PANEL,
  RANKING,
  SEARCH,
  PERSONAL_SEARCH,
  LINK,
}

enum SearchAction {
  STARTED,
  CANCELED,
  //How long it took to recieve
  TIME,
}

// TODO(m123): Check for user consent
// TODO(m123): handle debug mode

class AnalyticsHelper {
  AnalyticsHelper(this.context);

  final BuildContext context;

  Future<bool> trackStart() => _trackAction(action: TrackingAction.START);

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
  Future<bool> trackOpenLink({required String url}) =>
      _trackAction(action: TrackingAction.LINK, url: url);

  Future<bool> _trackAction({
    required TrackingAction action,
    String? barcode,
    String? knowledgePanelName,
    String? url,
  }) async {
    print('Tracking ${action.name}');
    final DateTime time = DateTime.now();
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final bool result = await MatomoForever.track(
      action.name,
      rand: Random().toString(),
      //Possibly interesting later
      //idVc: idVc,
      //viewTs: viewTs,
      //idTs: idTs,

      res: mediaQuery.size.toString(),
      h: time.hour,
      m: time.minute,
      s: time.second,
      lang: ProductQuery.getLanguage()?.toString() ??
          Localizations.localeOf(context).languageCode,
      uid: OpenFoodAPIConfiguration.uuid,

      link: action == TrackingAction.LINK ? url : null,
      url: action == TrackingAction.LINK ? url : null,
      search: action == TrackingAction.SEARCH ? null : null,
      //searchCat: searchCat,
      //searchCount: searchCount,
      //pvId: pvId,
      //idGoal: idGoal,
      //gtMs: gtMs,
      //ca: ca,
      eC: 'Scanner',
      eA: 'Scanned',
      eV: 0.0,
      //cN: cN,
      //cP: cP,
      //cT: cT,
      //cId: cId,
      //ecId: ecId,
      //ecItems: ecItems,
      country: Localizations.localeOf(context).countryCode,
      //customData: customData,
    );

    await MatomoForever.sendQueue();

    return result;
  }
}
