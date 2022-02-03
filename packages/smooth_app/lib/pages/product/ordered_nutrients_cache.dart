import 'dart:convert';
import 'package:openfoodfacts/model/OrderedNutrients.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:smooth_app/database/dao_string.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';

/// Helper class about getting and caching the back-end ordered nutrients.
class OrderedNutrientsCache {
  const OrderedNutrientsCache(this.localDatabase);

  final LocalDatabase localDatabase;

  /// Returns the ordered nutrients cached in the database.
  Future<OrderedNutrients?> get() async {
    final DaoString daoString = DaoString(localDatabase);
    final String? string = await daoString.get(_getKey());
    if (string != null) {
      try {
        return OrderedNutrients.fromJson(
          jsonDecode(string) as Map<String, dynamic>,
        );
      } catch (e) {
        await daoString.put(_getKey(), null);
      }
    }
    return null;
  }

  /// Downloads the ordered nutrients and caches them in the database.
  Future<OrderedNutrients> download() async {
    final String string = await OpenFoodAPIClient.getOrderedNutrientsJsonString(
      country: ProductQuery.getCountry()!,
      language: ProductQuery.getLanguage()!,
    );
    final OrderedNutrients result = OrderedNutrients.fromJson(
      jsonDecode(string) as Map<String, dynamic>,
    );
    final DaoString daoString = DaoString(localDatabase);
    await daoString.put(_getKey(), string);
    return result;
  }

  /// Clears the cache.
  ///
  /// Typical use case: when it's time to refresh the cached data.
  Future<void> clear() async {
    final DaoString daoString = DaoString(localDatabase);
    daoString.put(_getKey(), null);
  }

  /// Database key.
  String _getKey() {
    final OpenFoodFactsCountry country = ProductQuery.getCountry()!;
    final OpenFoodFactsLanguage language = ProductQuery.getLanguage()!;
    return 'nutrients.pl'
        '/${country.iso2Code}'
        '/${language.code}'
        '/${OpenFoodAPIConfiguration.globalQueryType}';
  }
}
