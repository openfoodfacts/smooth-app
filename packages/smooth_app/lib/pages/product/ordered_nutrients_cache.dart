import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/OrderedNutrients.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_string.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';

/// Helper class about getting and caching the back-end ordered nutrients.
class OrderedNutrientsCache {
  OrderedNutrientsCache._(final LocalDatabase localDatabase)
      : _daoString = DaoString(localDatabase);

  final DaoString _daoString;

  OrderedNutrients? _orderedNutrients;
  OrderedNutrients get orderedNutrients => _orderedNutrients!;

  /// Returns a database/downloaded cache, or null if it failed.
  static Future<OrderedNutrientsCache?> getCache(
    final BuildContext context,
  ) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final OrderedNutrientsCache cache = OrderedNutrientsCache._(localDatabase);
    cache._orderedNutrients = await cache._get() ??
        await LoadingDialog.run<OrderedNutrients>(
          context: context,
          future: cache._download(),
        );
    if (cache._orderedNutrients == null) {
      await LoadingDialog.error(context: context);
      return null;
    }
    return cache;
  }

  /// Returns the ordered nutrients cached in the database.
  Future<OrderedNutrients?> _get() async {
    final String? string = await _daoString.get(_getKey());
    if (string != null) {
      try {
        return OrderedNutrients.fromJson(
          jsonDecode(string) as Map<String, dynamic>,
        );
      } catch (e) {
        await _daoString.put(_getKey(), null);
      }
    }
    return null;
  }

  /// Downloads the ordered nutrients and caches them in the database.
  Future<OrderedNutrients> _download() async {
    final String string = await OpenFoodAPIClient.getOrderedNutrientsJsonString(
      country: ProductQuery.getCountry()!,
      language: ProductQuery.getLanguage()!,
    );
    final OrderedNutrients result = OrderedNutrients.fromJson(
      jsonDecode(string) as Map<String, dynamic>,
    );
    await _daoString.put(_getKey(), string);
    return result;
  }

  /// Clears the cache.
  ///
  /// Typical use case: when it's time to refresh the cached data.
  Future<void> clear() async => _daoString.put(_getKey(), null);

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
