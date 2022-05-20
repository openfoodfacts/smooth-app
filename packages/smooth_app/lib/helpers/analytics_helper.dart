import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:matomo_tracker/src/visitor.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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

  static const String _scanAction = 'scanned product';
  static const String _productPageAction = 'opened product page';
  static const String _knowledgePanelAction = 'opened knowledge panel page';
  static const String _personalizedRankingAction = 'personalized ranking';

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

  static void setAnalyticsReports(final bool allow) {
    MatomoTracker.instance.setOptOut(optout: !allow);
  }

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
    MatomoTracker.instance.initialize(
      url: 'https://analytics.openfoodfacts.org/matomo.php',
      siteId: 2,
      visitorId: uuid,
    );
    MatomoTracker.instance.visitor = Visitor(
      id: uuid,
      userId: OpenFoodAPIConfiguration.globalUser?.userId,
    );
  }

  static String get uuid => kDebugMode ? 'smoothie-debug' : OpenFoodAPIConfiguration.uuid

  // TODO(m123): Matomo removes leading 0 from the barcode
  static void trackScannedProduct({required String barcode}) =>
      MatomoTracker.instance.trackEvent(
        name: _scanAction,
        action: 'Scanned',
        eventValue: int.tryParse(barcode),
      );

  static void trackProductPageOpen({required Product product}) =>
      MatomoTracker.instance.trackEvent(
        name: _productPageAction,
        action: 'opened',
        eventValue: int.tryParse(product.barcode!),
      );

  static void trackKnowledgePanelOpen() => MatomoTracker.instance.trackEvent(
        name: _knowledgePanelAction,
        action: 'opened',
      );

  static void trackPersonalizedRanking() => MatomoTracker.instance.trackEvent(
        name: _personalizedRankingAction,
        action: 'opened',
      );

  static void trackSearch({
    required String search,
    String? searchCategory,
    int? searchCount,
  }) {
    final String searchString = '$search,$searchCategory,$searchCount';

    if (searchString == latestSearch) {
      return;
    }

    latestSearch = searchString;
    MatomoTracker.instance.trackSearch(
      searchKeyword: search,
      searchCount: searchCount,
      searchCategory: searchCategory,
    );
  }

  static void trackOpenLink({required String url}) =>
      MatomoTracker.instance.trackOutlink(url);
}
