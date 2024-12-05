import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
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
    cache._orderedNutrients = await cache._get();
    if (cache._orderedNutrients == null) {
      if (context.mounted) {
        cache._orderedNutrients = await LoadingDialog.run<OrderedNutrients>(
          context: context,
          future: cache._download(),
        );
      }
    }
    if (cache._orderedNutrients == null) {
      if (context.mounted) {
        await LoadingDialog.error(context: context);
      }
      return null;
    }
    return cache;
  }

  /// Returns the ordered nutrients cached in the database.
  Future<OrderedNutrients?> _get() async {
    final String? string = _cache[_getKey()];
    if (string != null) {
      try {
        return OrderedNutrients.fromJson(
          jsonDecode(string) as Map<String, dynamic>,
        );
      } catch (e) {
        _cache.remove(_getKey());
      }
    }
    return null;
  }

  UriProductHelper get _uriProductHelper => ProductQuery.getUriProductHelper(
        productType: ProductType.food,
      );

  /// Downloads the ordered nutrients and caches them in the database.
  Future<OrderedNutrients> _download() async {
    final String string = await OpenFoodAPIClient.getOrderedNutrientsJsonString(
      country: ProductQuery.getCountry(),
      language: ProductQuery.getLanguage(),
      uriHelper: _uriProductHelper,
    );
    final OrderedNutrients result = OrderedNutrients.fromJson(
      jsonDecode(string) as Map<String, dynamic>,
    );
    _cache[_getKey()] = string;
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
