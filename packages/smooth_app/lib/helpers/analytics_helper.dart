import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/query/product_query.dart';

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
  hungerGame(tag: 'hunger game'),
  appRating(tag: 'app rating'),
  taglineFeed(tag: 'tagline feed'),
  donation(tag: 'donation'),
  lifecycle(tag: 'lifecycle'),
  onboarding(tag: 'onboarding'),
  knowledgePanel(tag: 'knowledge panel'),
  navigation(tag: 'navigation'),
  foodPreferences(tag: 'food preferences');

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
  producerSignup(
    tag: 'signed up as producer',
    category: AnalyticsCategory.userManagement,
  ),
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
  notShowFastTrackProductEditCardEnvironmentalScore(
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
  closeFastTrackProductPage(
    tag: 'closed fast-track product edit page',
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
  closeNewProductPage(
    tag: 'closed new product page',
    category: AnalyticsCategory.newProduct,
  ),
  shareList(tag: 'shared a list', category: AnalyticsCategory.list),
  openListWeb(tag: 'open a list in wbe', category: AnalyticsCategory.list),
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
  ),
  appRatingSatisfied(tag: 'satisfied', category: AnalyticsCategory.appRating),
  appRatingNeutral(tag: 'neutral', category: AnalyticsCategory.appRating),
  appRatingNotSatisfied(
    tag: 'not satisfied',
    category: AnalyticsCategory.appRating,
  ),
  taglineNewsDisplayed(
    tag: 'tagline news displayed',
    category: AnalyticsCategory.taglineFeed,
  ),
  taglineNewsClicked(
    tag: 'tagline news clicked',
    category: AnalyticsCategory.taglineFeed,
  ),
  donationPageOpened(
    tag: 'donation page opened',
    category: AnalyticsCategory.donation,
  ),
  donationHandoff(
    tag: 'donation handoff',
    category: AnalyticsCategory.donation,
  ),
  donationAlreadyDonated(
    tag: 'donation already donated',
    category: AnalyticsCategory.donation,
  ),
  donationReminderShown(
    tag: 'donation reminder shown',
    category: AnalyticsCategory.donation,
  ),
  donationReminderHandoff(
    tag: 'donation reminder handoff',
    category: AnalyticsCategory.donation,
  ),
  donationReminderNotNow(
    tag: 'donation reminder not now',
    category: AnalyticsCategory.donation,
  ),
  donationStripShown(
    tag: 'donation strip shown',
    category: AnalyticsCategory.donation,
  ),
  donationStripClosed(
    tag: 'donation strip closed',
    category: AnalyticsCategory.donation,
  ),
  appFirstOpen(tag: 'app first open', category: AnalyticsCategory.lifecycle),
  onboardingPageVisited(
    tag: 'onboarding page visited',
    category: AnalyticsCategory.onboarding,
  ),
  knowledgePanelOpen(
    tag: 'knowledge panel open',
    category: AnalyticsCategory.knowledgePanel,
  ),
  appOpen(tag: 'app open', category: AnalyticsCategory.lifecycle),
  productPageTabSelected(
    tag: 'product page tab selected',
    category: AnalyticsCategory.navigation,
  ),
  bottomTabSelected(
    tag: 'bottom tab selected',
    category: AnalyticsCategory.navigation,
  ),
  foodPreferenceSaved(
    tag: 'food preference saved',
    category: AnalyticsCategory.foodPreferences,
  ),
  questionAnswered(
    tag: 'question answered',
    category: AnalyticsCategory.hungerGame,
  ),
  cameraPermissionRefused(
    tag: 'camera permission refused',
    category: AnalyticsCategory.scanning,
  ),
  userListCreated(tag: 'user list created', category: AnalyticsCategory.list),
  userListProductAdded(
    tag: 'product added to user list',
    category: AnalyticsCategory.list,
  );

  const AnalyticsEvent({required this.tag, required this.category});

  final String tag;
  final AnalyticsCategory category;
}

enum AnalyticsRobotoffEvents {
  robotoffNutritionExtracted(name: 'robotoff nutrition extracted'),
  robotoffNutritionInsightAccepted(name: 'robotoff nutrition insight accepted'),
  robotoffNutritionInsightRejected(name: 'robotoff nutrition insight rejected');

  const AnalyticsRobotoffEvents({required this.name});

  final String name;
}

enum AnalyticsEditEvents {
  basicDetails(name: 'BasicDetails'),
  photos(name: 'Photos'),
  powerEditScreen(name: 'Power Edit Screen'),
  ingredients_and_Origins(name: 'Ingredient And Origins'),
  categories(name: 'Categories'),
  traces(name: 'Traces'),
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
    _uniqueRandom = await userPreferences.getUniqueRandom();

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

  /// Initializes Sentry. Must be called after [GlobalVars] are set
  /// (see [launchSmoothApp] in main.dart) because [SentryOptions.environment]
  /// and [_beforeSend] read [GlobalVars.storeLabel]/[GlobalVars.scannerLabel].
  static Future<void> initSentry({required Function()? appRunner}) async {
    await SentryFlutter.init((SentryFlutterOptions options) {
      options
        ..dsn = 'https://22ec5d0489534b91ba455462d3736680@o241488.ingest.sentry.io/5376745'
        ..tracesSampler = (SentrySamplingContext samplingContext) {
          // HTTP traces are sent only when the user consented to both
          // analytics and crash reporting (see isTracingEnabled).
          // samplingContext is currently unused; if URL-based sampling is needed
          // (e.g. exclude image CDN) inspect samplingContext.transactionContext
          // or custom samplingContext.custom.
          return isTracingEnabled ? 1.0 : 0.0;
        }
        ..enableTombstone = true
        ..beforeSend = _beforeSend
        ..beforeSendTransaction = _beforeSendTransaction
        ..captureFailedRequests = false
        // Enable W3C Trace Context propagation so SDK package:http clients
        // emit the standard `traceparent` header for OTel-compatible
        // backends. Our custom dart:io wrapper injects `traceparent` manually
        // (W3C-only, no `sentry-trace`/`baggage`) because sentry-dart ships
        // no dart:io wrapper.
        ..propagateTraceparent = true
        ..environment =
            '${GlobalVars.storeLabel.name}-${GlobalVars.scannerLabel.name}'
        // Debug-only: forward Fimber app logs to Sentry Logs for branch
        // debugging. Sentry 10 always enables logs, so drop them before
        // sending in release builds. Error/trace pipelines stay consent-gated
        // in both modes.
        ..beforeSendLog = (SentryLog log, Hint hint) => kDebugMode ? log : null;
    }, appRunner: appRunner);
  }

  /// Don't call this method directly, it is automatically updated via the
  /// [UserPreferences]
  static void _setCrashReports(bool crashReports) =>
      _crashReports = crashReports;

  /// Don't call this method directly, it is automatically updated via the
  /// [UserPreferences]
  static void _setAnalyticsReports(bool allow) {
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
  @visibleForTesting
  static bool Function()? debugIsAnalyticsEnabledOverride;

  static bool get isEnabled =>
      debugIsAnalyticsEnabledOverride?.call() ??
      _analyticsReporting == _AnalyticsTrackingMode.enabled;

  @visibleForTesting
  static bool Function()? debugIsCrashEnabledOverride;

  static bool get _crashReportsEffective =>
      debugIsCrashEnabledOverride?.call() ?? _crashReports;

  /// Returns true only when the user consented to both analytics and crash
  /// reporting. HTTP performance traces follow this gate, so disabling
  /// either consent stops all Sentry trace traffic.
  static bool get isTracingEnabled => isEnabled && _crashReportsEffective;

  /// Runs [action] inside a Sentry span for a user-facing feature.
  ///
  /// If a span is already active, creates an `app.feature` child so HTTP
  /// calls made by [action] nest under it (e.g. "Hunger Games answer
  /// question" -> `http.client` child). Otherwise starts a standalone
  /// transaction bound to the scope for the duration of [action] (finished
  /// automatically, unbinding itself).
  /// No-op (just runs [action]) when tracing consent is off.
  /// Never throws itself: tracing failures degrade to running [action]
  /// directly, and [action]'s own errors are rethrown unchanged.
  static Future<T> traceFeature<T>(
    String name,
    Future<T> Function() action,
  ) async {
    if (!isTracingEnabled) {
      return action();
    }
    // Guarded separately so a throwing span factory can never break [action]:
    // [span] simply stays null and every use below is null-aware.
    ISentrySpan? span;
    try {
      span =
          Sentry.getSpan()?.startChild('app.feature', description: name) ??
          Sentry.startTransaction(name, 'app.feature', bindToScope: true);
    } catch (_) {
      span = null;
    }
    try {
      final T result = await action();
      try {
        span?.status = const SpanStatus.ok();
        await span?.finish();
      } catch (_) {}
      return result;
    } catch (e) {
      try {
        span?.throwable = e;
        span?.status = const SpanStatus.internalError();
        await span?.finish();
      } catch (_) {}
      rethrow;
    }
  }

  @visibleForTesting
  static bool get debugCrashReportsEnabled => _crashReportsEffective;

  /// Drops transactions sampled before consent was revoked: [tracesSampler]
  /// decides at transaction start, so an in-flight transaction would
  /// otherwise still be sent after opt-out.
  static FutureOr<SentryTransaction?> _beforeSendTransaction(
    SentryTransaction transaction,
    Hint hint,
  ) {
    if (!isTracingEnabled) {
      return null;
    }
    return transaction;
  }

  static FutureOr<SentryEvent?> _beforeSend(SentryEvent event, Hint hint) {
    if (!_crashReportsEffective) {
      return null;
    }
    return event
      ..tags = <String, String>{
        ...?event.tags,
        'store': GlobalVars.storeLabel.name,
        'scanner': GlobalVars.scannerLabel.name,
      };
  }

  static late PackageInfo _packageInfo;

  /// Undispatched actions survive a restart for a day, and no longer: the
  /// default [PersistenceFilter] of [DispatchSettings.persistent] drops
  /// anything older than 23h59m59s when the queue is loaded.
  static Future<void> initMatomo(
    bool screenshotMode, {
    DispatchSettings dispatchSettings = const DispatchSettings.persistent(),
  }) async {
    _packageInfo = await PackageInfo.fromPlatform();
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
        dispatchSettings: dispatchSettings,
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

  static const Duration _visitTimeout = Duration(minutes: 30);

  static void trackAppOpen(
    UserPreferences userPreferences, {
    Duration? backgroundedFor,
  }) {
    if (userPreferences.lastVisitedOnboardingPage.isOnboardingNotStarted()) {
      return;
    }
    if (backgroundedFor != null && backgroundedFor < _visitTimeout) {
      return;
    }
    trackEvent(AnalyticsEvent.appOpen);
  }

  static void trackEvent(
    AnalyticsEvent msg, {
    int? eventValue,
    String? barcode,
    String? action,
  }) => trackCustomEvent(
    msg.name,
    msg.category.tag,
    eventValue: eventValue,
    barcode: barcode,
    action: action,
  );

  // Used by code which is outside of the core:smooth_app code
  // e.g. the scanner implementation
  static void trackCustomEvent(
    String msg,
    String category, {
    int? eventValue,
    String? barcode,
    String? action,
    ProductType? productType,
  }) {
    if (!MatomoTracker.instance.initialized) {
      return;
    }
    final Map<String, String> dimensions = <String, String>{
      'dimension1': ProductQuery.getLanguage().offTag,
      'dimension2': ProductQuery.getCountry().offTag,
      'dimension3': ProductQuery.isLoggedIn() ? 'Y' : 'N',
      'dimension4': _packageInfo.version,
      'dimension5': productType?.offTag ?? '',
    };
    MatomoTracker.instance.trackEvent(
      eventInfo: EventInfo(
        name: msg,
        category: category,
        action: action ?? msg,
        value: eventValue ?? _formatBarcode(barcode),
      ),
      dimensions: dimensions,
    );
  }

  static void trackRobotoffExtraction(
    AnalyticsRobotoffEvents event,
    Nutrient nutrient,
    Product product,
  ) => trackCustomEvent(
    event.name,
    AnalyticsCategory.robotoff.tag,
    action: nutrient.name,
    barcode: product.barcode,
    productType: product.productType ?? ProductType.food,
  );

  static void trackProductEdit(
    AnalyticsEditEvents editEventName,
    Product product, [
    bool saved = false,
  ]) => trackCustomEvent(
    saved ? '${editEventName.name}-saved' : editEventName.name,
    AnalyticsCategory.productEdit.tag,
    action: editEventName.name,
    barcode: product.barcode,
    productType: product.productType ?? ProductType.food,
  );

  static void trackProductEvent(
    AnalyticsEvent msg, {
    required Product product,
    int? eventValue,
  }) => trackCustomEvent(
    msg.name,
    msg.category.tag,
    eventValue: eventValue,
    barcode: product.barcode,
    productType: product.productType ?? ProductType.food,
  );

  static void trackTaglineNewsEvent(AnalyticsEvent msg, String newsId) =>
      trackCustomEvent(msg.name, msg.category.tag, action: newsId);

  static void trackSearch({
    required String search,
    String? searchCategory,
    int? searchCount,
  }) {
    if (!MatomoTracker.instance.initialized) {
      return;
    }
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

  static void trackOutlink({required String url}) {
    if (!MatomoTracker.instance.initialized) {
      return;
    }
    MatomoTracker.instance.trackOutlink(link: url);
  }

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
    unawaited(Sentry.captureException(throwable, stackTrace: stackTrace));
  }
}

enum _AnalyticsTrackingMode {
  // With the user consent
  enabled,
  // Without the user consent
  anonymous,
  // On F-Droid builds
  disabled,
}
