import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_string.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/query/product_query.dart';

/// Helper class about getting and caching the back-end ordered nutrients.
class OrderedNutrientsCache {
  OrderedNutrientsCache._();

  OrderedNutrients? _orderedNutrients;

  OrderedNutrients get orderedNutrients => _orderedNutrients!;

  // We store the cached data in a static instead of a database, so that data
  // can be refreshed (by each app full restart).
  static final Map<String, String> _cache = <String, String>{};

  /// Returns an app-local/downloaded cache, or null if it failed.
  static Future<OrderedNutrientsCache?> getCache(
    final BuildContext context,
  ) async {
    final OrderedNutrientsCache cache = OrderedNutrientsCache._();
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    // quickest
    cache._orderedNutrients = await cache._getStaticVersion();
    if (cache._orderedNutrients != null) {
      return cache;
    }
    // less quick, but still local
    cache._orderedNutrients = await cache._getDatabaseVersion(localDatabase);
    if (cache._orderedNutrients != null) {
      return cache;
    }
    // server version, the very first time
    if (!context.mounted) {
      return null;
    }
    cache._orderedNutrients = await LoadingDialog.run<OrderedNutrients>(
      context: context,
      future: cache._download(localDatabase),
    );
    if (cache._orderedNutrients != null) {
      return cache;
    }
    if (context.mounted) {
      await LoadingDialog.error(context: context);
    }
    return null;
  }

  /// Returns the ordered nutrients cached in a static field.
  Future<OrderedNutrients?> _getStaticVersion() async {
    final String key = _getKey();
    final String? string = _cache[key];
    if (string != null) {
      try {
        return OrderedNutrients.fromJson(
          jsonDecode(string) as Map<String, dynamic>,
        );
      } catch (e) {
        _cache.remove(key);
      }
    }
    return null;
  }

  /// Returns the ordered nutrients cached in the database.
  Future<OrderedNutrients?> _getDatabaseVersion(
    final LocalDatabase localDatabase,
  ) async {
    final String key = _getKey();
    final DaoString daoString = DaoString(localDatabase);
    final String? string = await daoString.get(key);
    if (string != null) {
      try {
        final OrderedNutrients result = OrderedNutrients.fromJson(
          jsonDecode(string) as Map<String, dynamic>,
        );
        _cache[key] = string;
        return result;
      } catch (e) {
        await daoString.put(key, null);
      }
    }
    return null;
  }

  UriProductHelper get _uriProductHelper =>
      ProductQuery.getUriProductHelper(productType: ProductType.food);

  /// Downloads the ordered nutrients and caches them in the database.
  Future<OrderedNutrients> _download(final LocalDatabase localDatabase) async {
    final String string = await OpenFoodAPIClient.getOrderedNutrientsJsonString(
      country: ProductQuery.getCountry(),
      language: ProductQuery.getLanguage(),
      uriHelper: _uriProductHelper,
    );
    final OrderedNutrients result = OrderedNutrients.fromJson(
      jsonDecode(string) as Map<String, dynamic>,
    );
    final DaoString daoString = DaoString(localDatabase);
    final String key = _getKey();
    await daoString.put(key, string);
    _cache[key] = string;
    return result;
  }

  /// Database key.
  String _getKey() {
    final OpenFoodFactsCountry country = ProductQuery.getCountry();
    final OpenFoodFactsLanguage language = ProductQuery.getLanguage();
    return 'nutrients.pl'
        '/${country.offTag}'
        '/${language.code}'
        '/${_uriProductHelper.domain}';
  }
}
