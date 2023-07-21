import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/helpers/global_vars.dart';

/// Category for Matomo Events
enum AnalyticsCategory {
  userManagement(tag: 'user management'),
  scanning(tag: 'scanning'),
  share(tag: 'share'),
  couldNotFindProduct(tag: 'could not find product'),
  productEdit(tag: 'product edit'),
  productFastTrackEdit(tag: 'product fast track edit'),
  newProduct(tag: 'new product'),
  list(tag: 'list'),
  deepLink(tag: 'deep link');

  const AnalyticsCategory({required this.tag});

  final String tag;
}

/// Event types for Matomo analytics
enum AnalyticsEvent {
  scanAction(tag: 'scanned product', category: AnalyticsCategory.scanning),
  shareProduct(tag: 'shared product', category: AnalyticsCategory.share),
  loginAction(tag: 'logged in', category: AnalyticsCategory.userManagement),
  registerAction(tag: 'register', category: AnalyticsCategory.userManagement),
  logoutAction(tag: 'logged out', category: AnalyticsCategory.userManagement),
  couldNotScanProduct(
    tag: 'could not scan product',
    category: AnalyticsCategory.couldNotFindProduct,
  ),
  couldNotFindProduct(
    tag: 'could not find product',
    category: AnalyticsCategory.couldNotFindProduct,
  ),
  ignoreProductNotFound(
    tag: 'ignore product',
    category: AnalyticsCategory.couldNotFindProduct,
  ),
  openProductEditPage(
    tag: 'opened product edit page',
    category: AnalyticsCategory.productEdit,
  ),
  openFastTrackProductEditPage(
    tag: 'opened fast-track product edit page',
    category: AnalyticsCategory.productFastTrackEdit,
  ),
  showFastTrackProductEditCard(
    tag: 'showed fast-track product edit card',
    category: AnalyticsCategory.productFastTrackEdit,
  ),
  categoriesFastTrackProductPage(
    tag: 'set categories on fast track product page',
    category: AnalyticsCategory.productFastTrackEdit,
  ),
  nutritionFastTrackProductPage(
    tag: 'set nutrition facts on fast track product page',
    category: AnalyticsCategory.productFastTrackEdit,
  ),
  ingredientsFastTrackProductPage(
    tag: 'set ingredients on fast track product page',
    category: AnalyticsCategory.productFastTrackEdit,
  ),
  closeEmptyFastTrackProductPage(
    tag: 'closed new product page without any input',
    category: AnalyticsCategory.productFastTrackEdit,
  ),
  openNewProductPage(
    tag: 'opened new product page',
    category: AnalyticsCategory.newProduct,
  ),
  categoriesNewProductPage(
    tag: 'set categories on new product page',
    category: AnalyticsCategory.newProduct,
  ),
  nutritionNewProductPage(
    tag: 'set nutrition facts on new product page',
    category: AnalyticsCategory.newProduct,
  ),
  ingredientsNewProductPage(
    tag: 'set ingredients on new product page',
    category: AnalyticsCategory.newProduct,
  ),
  imagesNewProductPage(
    tag: 'set at least one image on new product page',
    category: AnalyticsCategory.newProduct,
  ),
  closeEmptyNewProductPage(
    tag: 'closed new product page without any input',
    category: AnalyticsCategory.newProduct,
  ),
  shareList(tag: 'shared a list', category: AnalyticsCategory.list),
  openListWeb(tag: 'open a list in wbe', category: AnalyticsCategory.list),
  productDeepLink(
      tag: 'open a product from an URL', category: AnalyticsCategory.deepLink),
  genericDeepLink(
      tag: 'generic deep link', category: AnalyticsCategory.deepLink);

  const AnalyticsEvent({required this.tag, required this.category});

  final String tag;
  final AnalyticsCategory category;
}

enum AnalyticsEditEvents {
  basicDetails(name: 'BasicDetails'),
  photos(name: 'Photos'),
  powerEditScreen(name: 'Power Edit Screen'),
  ingredients_and_Origins(name: 'Ingredient And Origins'),
  categories(name: 'Categories'),
  nutrition_Facts(name: 'Nutrition Facts'),
  labelsAndCertifications(name: 'Labels And Certifications'),
  packagingComponents(name: 'Packaging Components'),
  recyclingInstructionsPhotos(name: 'Recycling Instructions Photos'),
  stores(name: 'Stores'),
  origins(name: 'Origins'),
  traceabilityCodes(name: 'Traceability Codes'),
  country(name: 'Country'),
  otherDetails(name: 'Other Details');

  const AnalyticsEditEvents({required this.name});

  final String name;
}

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
  static _AnalyticsTrackingMode _analyticsReporting =
      _AnalyticsTrackingMode.disabled;

  static String latestSearch = '';

  static void linkPreferences(UserPreferences userPreferences) {
    // Init the value
    _setAnalyticsReports(userPreferences.onAnalyticsChanged.value);
    _setCrashReports(userPreferences.onCrashReportingChanged.value);

    // Listen to changes
    userPreferences.onAnalyticsChanged.addListener(() {
      _setAnalyticsReports(userPreferences.onAnalyticsChanged.value);
    });

    userPreferences.onCrashReportingChanged.addListener(() {
      _setCrashReports(userPreferences.onCrashReportingChanged.value);
    });
  }

  static Future<void> initSentry({
    required Function()? appRunner,
  }) async {
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
        options.environment =
            '${GlobalVars.storeLabel.name}-${GlobalVars.scannerLabel.name}';
      },
      appRunner: appRunner,
    );
  }

  /// Don't call this method directly, it is automatically updated via the
  /// [UserPreferences]
  static void _setCrashReports(final bool crashReports) =>
      _crashReports = crashReports;

  /// Don't call this method directly, it is automatically updated via the
  /// [UserPreferences]
  static Future<void> _setAnalyticsReports(final bool allow) async {
    if (allow) {
      _analyticsReporting = _AnalyticsTrackingMode.enabled;
    } else {
      _analyticsReporting = _AnalyticsTrackingMode.anonymous;
    }

    if (MatomoTracker.instance.initialized) {
      MatomoTracker.instance.setVisitorUserId(_uuid);
    }
  }

  static FutureOr<SentryEvent?> _beforeSend(SentryEvent event,
      {dynamic hint}) async {
    if (!_crashReports) {
      return null;
    }
    return event;
  }

  static Future<void> initMatomo(
    final bool screenshotMode,
  ) async {
    if (screenshotMode) {
      _setCrashReports(false);
      _setAnalyticsReports(false);
      return;
    }
    try {
      await MatomoTracker.instance.initialize(
        url: 'https://analytics.openfoodfacts.org/matomo.php',
        siteId: 2,
        visitorId: _uuid,
      );
    } catch (err) {
      // With Hot Reload, this may trigger a late field already initialized
    }
  }

  /// A UUID must be at least one 16 characters
  static String? get _uuid {
    // if user opts out then track anonymously with userId containg zeros
    if (kDebugMode) {
      return 'smoothie_debug--';
    }

    switch (_analyticsReporting) {
      case _AnalyticsTrackingMode.anonymous:
        return '0' * 16;
      case _AnalyticsTrackingMode.disabled:
        return '';
      case _AnalyticsTrackingMode.enabled:
      default:
        return OpenFoodAPIConfiguration.uuid;
    }
  }

  static void trackEvent(
    AnalyticsEvent msg, {
    int? eventValue,
    String? barcode,
  }) =>
      MatomoTracker.instance.trackEvent(
        eventName: msg.name,
        eventCategory: msg.category.tag,
        action: msg.name,
        eventValue: eventValue ?? _formatBarcode(barcode),
      );

  // Used by code which is outside of the core:smooth_app code
  // e.g. the scanner implementation
  static void trackCustomEvent(
    String msg,
    String category, {
    int? eventValue,
    String? barcode,
  }) =>
      MatomoTracker.instance.trackEvent(
        eventName: msg,
        eventCategory: category,
        action: msg,
        eventValue: eventValue ?? _formatBarcode(barcode),
      );

  static void trackProductEdit(
          AnalyticsEditEvents editEventName, String barcode,
          [bool saved = false]) =>
      MatomoTracker.instance.trackEvent(
        eventName: saved ? '${editEventName.name}-saved' : editEventName.name,
        eventCategory: AnalyticsCategory.productEdit.tag,
        action: editEventName.name,
        eventValue: _formatBarcode(barcode),
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

  static void trackOutlink({required String url}) =>
      MatomoTracker.instance.trackOutlink(url);

  static int? _formatBarcode(String? barcode) {
    if (barcode == null) {
      return null;
    }

    const int fallback = 000000000;
    try {
      return int.tryParse(barcode) ?? fallback;
    } on FormatException {
      return fallback;
    }
  }

  static void sendException(dynamic throwable, {dynamic stackTrace}) {
    Sentry.captureException(throwable, stackTrace: stackTrace);
  }

  static String? get matomoVisitorId => MatomoTracker.instance.visitor.id;
}

enum _AnalyticsTrackingMode {
  // With the user consent
  enabled,
  // Without the user consent
  anonymous,
  // On F-Droid builds
  disabled,
}
