import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/helpers/global_vars.dart';

/// Category for Matomo Events
enum AnalyticsCategory {
  userManagement(tag: 'user management'),
  scanning(tag: 'scanning'),
  share(tag: 'share'),
  loadingProduct(tag: 'loading product'),
  couldNotFindProduct(tag: 'could not find product'),
  productEdit(tag: 'product edit'),
  productFastTrackEdit(tag: 'product fast track edit'),
  newProduct(tag: 'new product'),
  robotoff(tag: 'robotoff'),
  list(tag: 'list'),
  deepLink(tag: 'deep link'),
  hungerGame(tag: 'hunger game');

  const AnalyticsCategory({required this.tag});

  final String tag;
}

/// Event types for Matomo analytics
enum AnalyticsEvent {
  scanAction(tag: 'scanned product', category: AnalyticsCategory.scanning),
  obsoleteProduct(
    tag: 'obsolete product',
    category: AnalyticsCategory.scanning,
  ),
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
  ignoreProductLoading(
    tag: 'ignore product',
    category: AnalyticsCategory.loadingProduct,
  ),
  restartProductLoading(
    tag: 'restart request',
    category: AnalyticsCategory.loadingProduct,
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
  notShowFastTrackProductEditCardNutriscore(
    tag: 'nutriscore not applicable - no fast-track product edit card',
    category: AnalyticsCategory.productFastTrackEdit,
  ),
  notShowFastTrackProductEditCardEcoscore(
    tag: 'ecoscore not applicable - no fast-track product edit card',
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
  shareList(
    tag: 'shared a list',
    category: AnalyticsCategory.list,
  ),
  openListWeb(
    tag: 'open a list in wbe',
    category: AnalyticsCategory.list,
  ),
  productDeepLink(
    tag: 'open a product from an URL',
    category: AnalyticsCategory.deepLink,
  ),
  genericDeepLink(
    tag: 'generic deep link',
    category: AnalyticsCategory.deepLink,
  ),
  questionVisible(
    tag: 'question visible',
    category: AnalyticsCategory.robotoff,
  ),
  questionClicked(
    tag: 'question clicked',
    category: AnalyticsCategory.robotoff,
  ),
  hungerGameOpened(
    tag: 'hunger game opened',
    category: AnalyticsCategory.hungerGame,
  );

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

  static late int _uniqueRandom;

  static Future<void> linkPreferences(UserPreferences userPreferences) async {
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

    _uniqueRandom = await userPreferences.getUniqueRandom();
  }

  static Future<void> initSentry({
    required Function()? appRunner,
  }) async {
    await SentryFlutter.init(
      (SentryOptions options) {
        options
          ..dsn =
              'https://22ec5d0489534b91ba455462d3736680@o241488.ingest.sentry.io/5376745'
          ..beforeSend = (
            SentryEvent event,
            Hint hint,
          ) async {
            return event.copyWith(
              tags: <String, String>{
                'store': GlobalVars.storeLabel.name,
                'scanner': GlobalVars.scannerLabel.name,
              },
            );
          };
        // To set a uniform sample rate
        options
          ..tracesSampleRate = 1.0
          ..beforeSend = _beforeSend
          ..environment =
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
      MatomoTracker.instance.setVisitorUserId(_visitorId);
    }
  }

  /// Returns true if analytics reporting is enabled.
  static bool get isEnabled =>
      _analyticsReporting == _AnalyticsTrackingMode.enabled;

  static FutureOr<SentryEvent?> _beforeSend(
    SentryEvent event,
    dynamic hint,
  ) async {
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
        siteId: '2',
        visitorId: _visitorId,
      );
    } catch (err) {
      // With Hot Reload, this may trigger a late field already initialized
    }
  }

  /// A visitor id should have a length of 16 characters.
  static String? get _visitorId {
    // if user opts out then track anonymously with userId containing zeros
    if (kDebugMode) {
      return 'smoothie_debug--';
    }

    switch (_analyticsReporting) {
      case _AnalyticsTrackingMode.anonymous:
        return _anonymousVisitorId;
      case _AnalyticsTrackingMode.disabled:
        return '';
      case _AnalyticsTrackingMode.enabled:
        return OpenFoodAPIConfiguration.uuid;
    }
  }

  /// Returns a unique visitor id that starts with a letter between A and Z.
  static String get _anonymousVisitorId => _uniqueLetter + ('0' * 15);

  /// Returns a letter between A and Z, depending on [_uniqueRandom].
  static String get _uniqueLetter =>
      String.fromCharCode('A'.codeUnitAt(0) + _uniqueRandom % 26);

  static void trackEvent(
    AnalyticsEvent msg, {
    int? eventValue,
    String? barcode,
  }) =>
      MatomoTracker.instance.trackEvent(
        eventInfo: EventInfo(
          name: msg.name,
          category: msg.category.tag,
          action: msg.name,
          value: eventValue ?? _formatBarcode(barcode),
        ),
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
        eventInfo: EventInfo(
          name: msg,
          category: category,
          action: msg,
          value: eventValue ?? _formatBarcode(barcode),
        ),
      );

  static void trackProductEdit(
          AnalyticsEditEvents editEventName, String barcode,
          [bool saved = false]) =>
      MatomoTracker.instance.trackEvent(
        eventInfo: EventInfo(
          name: saved ? '${editEventName.name}-saved' : editEventName.name,
          category: AnalyticsCategory.productEdit.tag,
          action: editEventName.name,
          value: _formatBarcode(barcode),
        ),
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
      MatomoTracker.instance.trackOutlink(link: url);

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
