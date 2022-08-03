import 'package:openfoodfacts/model/UserAgent.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:openfoodfacts/utils/QueryType.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/dao_string.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:uuid/uuid.dart';

// ignore: avoid_classes_with_only_static_members
abstract class ProductQuery {
  static OpenFoodFactsCountry? _country;

  /// Returns the global language for API queries.
  static OpenFoodFactsLanguage? getLanguage() {
    final List<OpenFoodFactsLanguage> languages =
        OpenFoodAPIConfiguration.globalLanguages ?? <OpenFoodFactsLanguage>[];
    if (languages.isEmpty) {
      return null;
    }
    return languages[0];
  }

  /// Sets the global language for API queries.
  static void setLanguage(final String languageCode) {
    final OpenFoodFactsLanguage language =
        LanguageHelper.fromJson(languageCode);
    OpenFoodAPIConfiguration.globalLanguages = <OpenFoodFactsLanguage>[
      language,
    ];
  }

  /// Returns the global country for API queries?
  static OpenFoodFactsCountry? getCountry() => _country;

  /// Sets the global country for API queries.
  static void setCountry(final String? isoCode) {
    _country = CountryHelper.fromJson(isoCode);
    // we need this to run "world" queries
    OpenFoodAPIConfiguration.globalCountry = null;
  }

  /// Returns the global locale string (e.g. 'pt_BR')
  static String getLocaleString() => '${getLanguage()!.code}'
      '_'
      '${getCountry()!.iso2Code.toUpperCase()}';

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
      uuidString.put(_UUID_NAME, uuid);
    }
    OpenFoodAPIConfiguration.uuid = uuid;
  }

  static User getUser() =>
      OpenFoodAPIConfiguration.globalUser ??
      const User(
        userId: 'smoothie-app',
        password: 'strawberrybanana',
        comment: 'Test user for project smoothie',
      );

  static bool isLoggedIn() => OpenFoodAPIConfiguration.globalUser != null;

  /// Sets the query type according to the current [UserPreferences]
  static void setQueryType(final UserPreferences userPreferences) {
    OpenFoodAPIConfiguration.globalQueryType = userPreferences
                .getFlag(UserPreferencesDevMode.userPreferencesFlagProd) ??
            true
        ? QueryType.PROD
        : QueryType.TEST;
    final String? testEnvHost = userPreferences
        .getDevModeString(UserPreferencesDevMode.userPreferencesTestEnvHost);
    if (testEnvHost != null) {
      OpenFoodAPIConfiguration.uriTestHost = testEnvHost;
    }
  }

  static List<ProductField> get fields => <ProductField>[
        ProductField.NAME,
        ProductField.BRANDS,
        ProductField.BARCODE,
        ProductField.NUTRISCORE,
        ProductField.FRONT_IMAGE,
        ProductField.IMAGE_FRONT_SMALL_URL,
        ProductField.IMAGE_FRONT_URL,
        ProductField.IMAGE_INGREDIENTS_URL,
        ProductField.IMAGE_NUTRITION_URL,
        ProductField.IMAGE_PACKAGING_URL,
        ProductField.SELECTED_IMAGE,
        ProductField.QUANTITY,
        ProductField.SERVING_SIZE,
        ProductField.STORES,
        ProductField.PACKAGING_QUANTITY,
        ProductField.PACKAGING,
        ProductField.PACKAGING_TAGS,
        ProductField.PACKAGING_TEXT_IN_LANGUAGES,
        ProductField.PACKAGING_TEXT_ALL_LANGUAGES,
        ProductField.NO_NUTRITION_DATA,
        ProductField.NUTRIMENTS,
        ProductField.NUTRIENT_LEVELS,
        ProductField.NUTRIMENT_ENERGY_UNIT,
        ProductField.ADDITIVES,
        ProductField.INGREDIENTS_ANALYSIS_TAGS,
        ProductField.INGREDIENTS_TEXT,
        ProductField.LABELS_TAGS,
        ProductField.LABELS_TAGS_IN_LANGUAGES,
        ProductField.ENVIRONMENT_IMPACT_LEVELS,
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
      ];
}
