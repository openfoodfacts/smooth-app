import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/dao_string.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/product/product_type_extensions.dart';
import 'package:uuid/uuid.dart';

// ignore: avoid_classes_with_only_static_members
abstract class ProductQuery {
  const ProductQuery._();

  static const ProductQueryVersion productQueryVersion = ProductQueryVersion.v3;

  static late OpenFoodFactsCountry _country;

  static String replaceSubdomain(final String url) =>
      UriHelper.replaceSubdomain(
        Uri.parse(url),
        language: getLanguage(),
        country: getCountry(),
      ).toString();

  /// Returns the global language for API queries.
  static OpenFoodFactsLanguage getLanguage() {
    final List<OpenFoodFactsLanguage> languages =
        OpenFoodAPIConfiguration.globalLanguages ?? <OpenFoodFactsLanguage>[];
    if (languages.isEmpty) {
      // very very unlikely
      return OpenFoodFactsLanguage.UNDEFINED;
    }
    return languages[0];
  }

  /// Sets the global language for API queries.
  static void setLanguage(
    final BuildContext context,
    final UserPreferences userPreferences, {
    String? languageCode,
  }) {
    languageCode ??= userPreferences.appLanguageCode ??
        Localizations.localeOf(context).languageCode;

    final OpenFoodFactsLanguage language =
        LanguageHelper.fromJson(languageCode);
    OpenFoodAPIConfiguration.globalLanguages = <OpenFoodFactsLanguage>[
      language,
    ];
    if (languageCode != userPreferences.appLanguageCode) {
      userPreferences.setAppLanguageCode(languageCode);
    }
  }

  /// Returns the global country for API queries.
  static OpenFoodFactsCountry getCountry() => _country;

  /// Sets the global country for API queries: implicit choice at init time.
  static Future<void> initCountry(
    final UserPreferences userPreferences,
  ) async {
    // not ideal, but we have many contributors monitoring France
    const OpenFoodFactsCountry defaultCountry = OpenFoodFactsCountry.FRANCE;
    final String? isoCode = userPreferences.userCountryCode ??
        PlatformDispatcher.instance.locale.countryCode?.toLowerCase();
    final OpenFoodFactsCountry country =
        OpenFoodFactsCountry.fromOffTag(isoCode) ?? defaultCountry;
    await _setCountry(userPreferences, country);
    if (userPreferences.userCurrencyCode == null) {
      // very very first time, or old app with new code
      final Currency? possibleCurrency = country.currency;
      if (possibleCurrency != null) {
        await userPreferences.setUserCurrencyCode(possibleCurrency.name);
      }
    }
  }

  /// Sets the global country for API queries: explicit choice by the user.
  ///
  /// Returns true if the [isoCode] was correctly detected.
  static Future<bool> setCountry(
    final UserPreferences userPreferences,
    final String isoCode,
  ) async {
    final OpenFoodFactsCountry? country =
        OpenFoodFactsCountry.fromOffTag(isoCode);
    if (country == null) {
      return false;
    }
    await _setCountry(userPreferences, country);
    return true;
  }

  /// Sets the global country for API queries.
  static Future<void> _setCountry(
    final UserPreferences userPreferences,
    final OpenFoodFactsCountry country,
  ) async {
    _country = country;
    // we need this to run "world" queries
    OpenFoodAPIConfiguration.globalCountry = null;

    final String isoCode = country.offTag;
    if (isoCode != userPreferences.userCountryCode) {
      await userPreferences.setUserCountryCode(isoCode);
    }
  }

  /// Returns the global locale string (e.g. 'pt_BR')
  static String getLocaleString() => '${getLanguage().code}'
      '_'
      '${getCountry().offTag.toUpperCase()}';

  /// Sets a comment for the user agent.
  ///
  /// cf. https://github.com/openfoodfacts/smooth-app/issues/2248
  static void setUserAgentComment(final String comment) {
    final UserAgent? previous = OpenFoodAPIConfiguration.userAgent;
    if (previous == null) {
      return;
    }
    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: previous.name,
      version: previous.version,
      system: previous.system,
      url: previous.url,
      comment: comment,
    );
  }

  static const String _UUID_NAME = 'UUID_NAME_REV_1';

  /// Sets the uuid id as "final variable", for instance for API queries.
  ///
  /// To be called at main / init.
  static Future<void> setUuid(final LocalDatabase localDatabase) async {
    final DaoString uuidString = DaoString(localDatabase);
    String? uuid = await uuidString.get(_UUID_NAME);

    if (uuid == null) {
      // Crop down to 16 letters for matomo
      uuid = const Uuid().v4().replaceAll('-', '').substring(0, 16);
      await uuidString.put(_UUID_NAME, uuid);
    }
    OpenFoodAPIConfiguration.uuid = uuid;
    await Sentry.configureScope((Scope scope) {
      scope.contexts['uuid'] = OpenFoodAPIConfiguration.uuid;
      scope.setUser(SentryUser(username: OpenFoodAPIConfiguration.uuid));
    });
  }

  /// We don't track users for READ operations if they didn't consent.
  static User getReadUser() =>
      AnalyticsHelper.isEnabled ? getWriteUser() : _testUser;

  /// We do track users for WRITE operations.
  static User getWriteUser() =>
      OpenFoodAPIConfiguration.globalUser ?? _testUser;

  static User get _testUser => const User(
        userId: 'smoothie-app',
        password: 'strawberrybanana',
        comment: 'Test user for project smoothie',
      );

  static late UriProductHelper _uriProductHelper;

  /// Product helper only for prices.
  static late UriProductHelper uriPricesHelper;

  static bool isLoggedIn() => OpenFoodAPIConfiguration.globalUser != null;

  /// Sets the query type according to the current [UserPreferences]
  static void setQueryType(final UserPreferences userPreferences) {
    UriProductHelper getProductHelper(final String flagProd) =>
        userPreferences.getFlag(flagProd) ?? true
            ? uriHelperFoodProd
            : getTestUriProductHelper(userPreferences);

    _uriProductHelper = getProductHelper(
      UserPreferencesDevMode.userPreferencesFlagProd,
    );
    uriPricesHelper = getProductHelper(
      UserPreferencesDevMode.userPreferencesFlagPriceProd,
    );
  }

  /// Returns the standard test env, or the custom test env if relevant.
  static UriProductHelper getTestUriProductHelper(
      final UserPreferences userPreferences) {
    final String testEnvDomain = userPreferences.getDevModeString(
            UserPreferencesDevMode.userPreferencesTestEnvDomain) ??
        '';
    return testEnvDomain.isEmpty
        ? uriHelperFoodTest
        : UriProductHelper(
            isTestMode: true,
            userInfoForPatch: HttpHelper.userInfoForTest,
            domain: testEnvDomain,
          );
  }

  static ProductType? extractProductType(
    final UriProductHelper uriProductHelper,
  ) {
    final String domain = uriProductHelper.domain;
    for (final ProductType productType in ProductType.values) {
      if (domain.contains(productType.getDomain())) {
        return productType;
      }
    }
    return null;
  }

  // TODO(monsieurtanuki): make the parameter "required"
  static UriProductHelper getUriProductHelper({
    required final ProductType? productType,
  }) {
    final UriProductHelper currentUriProductHelper = _uriProductHelper;
    if (productType == null) {
      return currentUriProductHelper;
    }
    final ProductType? currentProductType =
        extractProductType(currentUriProductHelper);
    if (currentProductType == null) {
      return currentUriProductHelper;
    }
    if (currentProductType == productType) {
      return currentUriProductHelper;
    }
    return UriProductHelper(
      domain: currentUriProductHelper.domain.replaceFirst(
        currentProductType.getDomain(),
        productType.getDomain(),
      ),
    );
  }

  static List<ProductField> get fields => const <ProductField>[
        ProductField.NAME,
        ProductField.NAME_ALL_LANGUAGES,
        ProductField.BRANDS,
        ProductField.BARCODE,
        ProductField.PRODUCT_TYPE,
        ProductField.NUTRISCORE,
        ProductField.FRONT_IMAGE,
        ProductField.IMAGE_FRONT_URL,
        ProductField.IMAGE_INGREDIENTS_URL,
        ProductField.IMAGE_NUTRITION_URL,
        ProductField.IMAGE_PACKAGING_URL,
        ProductField.IMAGES,
        ProductField.SELECTED_IMAGE,
        ProductField.QUANTITY,
        ProductField.SERVING_SIZE,
        ProductField.STORES,
        ProductField.PACKAGING_QUANTITY,
        ProductField.PACKAGING,
        ProductField.PACKAGINGS,
        ProductField.PACKAGINGS_COMPLETE,
        ProductField.PACKAGING_TAGS,
        ProductField.PACKAGING_TEXT_ALL_LANGUAGES,
        ProductField.NO_NUTRITION_DATA,
        ProductField.NUTRIMENT_DATA_PER,
        ProductField.NUTRITION_DATA,
        ProductField.NUTRIMENTS,
        ProductField.NUTRIENT_LEVELS,
        ProductField.NUTRIMENT_ENERGY_UNIT,
        ProductField.ADDITIVES,
        ProductField.INGREDIENTS_ANALYSIS_TAGS,
        ProductField.INGREDIENTS_TEXT,
        ProductField.INGREDIENTS_TEXT_ALL_LANGUAGES,
        ProductField.LABELS_TAGS,
        ProductField.LABELS_TAGS_IN_LANGUAGES,
        ProductField.COMPARED_TO_CATEGORY,
        ProductField.CATEGORIES_TAGS,
        ProductField.CATEGORIES_TAGS_IN_LANGUAGES,
        ProductField.LANGUAGE,
        ProductField.ATTRIBUTE_GROUPS,
        ProductField.STATES_TAGS,
        ProductField.ECOSCORE_DATA,
        ProductField.ECOSCORE_GRADE,
        ProductField.ECOSCORE_SCORE,
        ProductField.KNOWLEDGE_PANELS,
        ProductField.COUNTRIES,
        ProductField.COUNTRIES_TAGS,
        ProductField.COUNTRIES_TAGS_IN_LANGUAGES,
        ProductField.EMB_CODES,
        ProductField.ORIGINS,
        ProductField.WEBSITE,
        ProductField.OBSOLETE,
        ProductField.OWNER_FIELDS,
        ProductField.OWNER,
      ];
}
