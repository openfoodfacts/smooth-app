import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:matomo_forever/matomo_forever.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/database/local_database.dart';

import '../database/product_query.dart';

enum SearchAction {
  STARTED,
  CANCELED,
  //How long it took to recieve
  TIME,
}

class AnalyticsHelper {
  AnalyticsHelper(this.context);

  final BuildContext context;

  Future<void> initSentry({Function()? appRunner}) async {
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

  Future<bool> trackStart() {}

  Future<bool> trackScannedProduct({required int barcode}) {}

  Future<bool> trackProductPageOpen({required int barcode}) {}

  Future<bool> trackKnowledgePanelOpen(
      {required int barcode, required String knowledgePanel}) {}

  Future<bool> trackCompare({
    required int products,
    required int goodProducts,
    required int badProducts,
    required int unkownProducts,
  }) {}

  Future<bool> trackSearch({
    required String parameter,
    required SearchAction action,
    String? data,
  }) {}

  Future<bool> trackPersonalSearch() {
    required String parameter,
    required int products,
    required int goodProducts,
    required int badProducts,
    required int unkownProducts,
  }

  Future<bool> trackOpenLink({required String url}) {}

  Future<bool> _trackAction({
    required TrackingAction action,
    required String data,
  }) async {
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

      link: action == TrackingAction.LINK ? data : null,
      url: action == TrackingAction.LINK ? data : null,
      search: action == TrackingAction.SEARCH ? data : null,
      //searchCat: searchCat,
      //searchCount: searchCount,
      //pvId: pvId,
      //idGoal: idGoal,
      //gtMs: gtMs,
      //ca: ca,
      eC: "Scanner",
      eA: "Scanned",
      eV: "barcode",
    //cN: cN,
    //cP: cP,
    //cT: cT,
    //cId: cId,
    //ecId: ecId,
    //ecItems: ecItems,
      country: Localizations.localeOf(context).countryCode,
      customData: customData,
    );

    return result;
  }
}
