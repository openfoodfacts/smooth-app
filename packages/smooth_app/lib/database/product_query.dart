import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:openfoodfacts/utils/QueryType.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/user_preferences_dev_mode.dart';

abstract class ProductQuery {
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
  static OpenFoodFactsCountry? getCountry() =>
      OpenFoodAPIConfiguration.globalCountry;

  /// Sets the global country for API queries.
  static void setCountry(final String? isoCode) =>
      OpenFoodAPIConfiguration.globalCountry = CountryHelper.fromJson(isoCode);

  static User getUser() =>
      OpenFoodAPIConfiguration.globalUser ??
      const User(
        userId: 'smoothie-app',
        password: 'strawberrybanana',
        comment: 'Test user for project smoothie',
      );

  /// Sets the query type according to the current [UserPreferences]
  static void setQueryType(final UserPreferences userPreferences) =>
      OpenFoodAPIConfiguration.globalQueryType = userPreferences
                  .getFlag(UserPreferencesDevMode.userPreferencesFlagProd) ??
              true
          ? QueryType.PROD
          : QueryType.TEST;

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
        ProductField.PACKAGING_QUANTITY,
        ProductField.NUTRIMENTS,
        ProductField.NUTRIENT_LEVELS,
        ProductField.NUTRIMENT_ENERGY_UNIT,
        ProductField.ADDITIVES,
        ProductField.INGREDIENTS_ANALYSIS_TAGS,
        ProductField.LABELS_TAGS,
        ProductField.LABELS_TAGS_IN_LANGUAGES,
        ProductField.ENVIRONMENT_IMPACT_LEVELS,
        ProductField.CATEGORIES_TAGS_IN_LANGUAGES,
        ProductField.LANGUAGE,
        ProductField.ATTRIBUTE_GROUPS,
        ProductField.STATES_TAGS,
        ProductField.ECOSCORE_DATA,
        ProductField.ECOSCORE_GRADE,
        ProductField.ECOSCORE_SCORE,
        ProductField.ENVIRONMENT_IMPACT_LEVELS,
      ];

  Future<SearchResult> getSearchResult();

  ProductList getProductList();
}
