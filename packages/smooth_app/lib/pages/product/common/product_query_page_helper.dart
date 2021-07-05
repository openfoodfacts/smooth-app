// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';

// Project imports:
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/pages/product/common/product_query_page.dart';

class ProductQueryPageHelper {
  Future<void> openBestChoice({
    required final ProductQuery productQuery,
    required final LocalDatabase localDatabase,
    required final Color color,
    required final String heroTag,
    required final String name,
    required final BuildContext context,
  }) async {
    final ProductListSupplier supplier =
        await ProductListSupplier.getBestSupplier(
      productQuery,
      localDatabase,
    );
    Navigator.push<Widget>(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => ProductQueryPage(
          productListSupplier: supplier,
          heroTag: heroTag,
          mainColor: color,
          name: name,
          lastUpdate: supplier.timestamp,
        ),
      ),
    );
  }

  static String getDurationStringFromSeconds(
      final int seconds, AppLocalizations appLocalizations) {
    final double minutes = seconds / 60;
    final int roundMinutes = minutes.round();
    if (roundMinutes < 60) {
      return appLocalizations.plural_ago_minutes(roundMinutes);
    }

    final double hours = minutes / 60;
    final int roundHours = hours.round();
    if (roundHours < 24) {
      return appLocalizations.plural_ago_hours(roundHours);
    }

    final double days = hours / 24;
    final int roundDays = days.round();
    if (roundDays < 7) {
      return appLocalizations.plural_ago_days(roundDays);
    }
    final double weeks = days / 7;
    final int roundWeeks = weeks.round();
    if (roundWeeks <= 4) {
      return appLocalizations.plural_ago_weeks(roundWeeks);
    }

    final double months = days / (365 / 12);
    final int roundMonths = months.round();
    return appLocalizations.plural_ago_months(roundMonths);
  }

  static String getDurationStringFromTimestamp(
      final int timestamp, BuildContext context) {
    final int now = LocalDatabase.nowInMillis();
    final int seconds = ((now - timestamp) / 1000).floor();
    return getDurationStringFromSeconds(seconds, AppLocalizations.of(context)!);
  }

  static String getProductListLabel(
      final ProductList productList, final BuildContext context,
      {final bool verbose = true}) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    switch (productList.listType) {
      case ProductList.LIST_TYPE_HTTP_SEARCH_GROUP:
        return '${_getGroupName(productList.parameters, appLocalizations)}'
            '${verbose ? ' ${appLocalizations.category_search}' : ''}';
      case ProductList.LIST_TYPE_HTTP_SEARCH_KEYWORDS:
        return '${productList.parameters}'
            '${verbose ? ' ${appLocalizations.category_search}' : ''}';
      case ProductList.LIST_TYPE_HTTP_SEARCH_CATEGORY:
        return '${productList.parameters}'
            '${verbose ? ' ${appLocalizations.category_search}' : ''}';
      case ProductList.LIST_TYPE_SCAN:
        return appLocalizations.scan;
      case ProductList.LIST_TYPE_HISTORY:
        return appLocalizations.recently_seen_products;
      case ProductList.LIST_TYPE_USER_DEFINED:
        return '${productList.parameters}'
            '${verbose ? ' ${appLocalizations.my_list}' : ''}';
      case ProductList.LIST_TYPE_USER_PANTRY:
        return '${productList.parameters}'
            '${verbose ? ' ${appLocalizations.my_pantrie_lists}' : ''}';
      case ProductList.LIST_TYPE_USER_SHOPPING:
        return '${productList.parameters}'
            '${verbose ? ' ${appLocalizations.my_shopping_lists}' : ''}';
    }
    return '${appLocalizations.unknown_product_list} ${productList.listType} / ${productList.parameters}';
  }

  static String _getGroupName(
      final String groupId, final AppLocalizations appLocalizations) {
    for (final PnnsGroup2 group2 in PnnsGroup2.values) {
      if (group2.id == groupId) {
        return group2.name;
      }
    }
    return '${appLocalizations.not_found} $groupId';
  }

  static String getProductCount(
      final ProductList productList, final AppLocalizations appLocalizations) {
    if (productList.databaseCountDistinct == null ||
        productList.databaseCountDistinct == 0) {
      return appLocalizations.no_product;
    }
    if (productList.databaseCountDistinct == 1) {
      return appLocalizations.one_product;
    }
    return '${productList.databaseCountDistinct} ${appLocalizations.x_products}';
  }

  /// Returns the label for an "add button" with this [productListType]
  static String getCreateListLabel(
    final String productListType,
    final AppLocalizations appLocalizations,
  ) {
    switch (productListType) {
      case ProductList.LIST_TYPE_USER_DEFINED:
        return appLocalizations.new_list;
      case ProductList.LIST_TYPE_USER_PANTRY:
        return appLocalizations.new_pantry;
      case ProductList.LIST_TYPE_USER_SHOPPING:
        return appLocalizations.new_shopping;
    }
    throw Exception('not handled for product list type $productListType');
  }

  /// Returns the shape for a product list button with this [productListType]
  static OutlinedBorder? getShape(final String productListType) {
    switch (productListType) {
      case ProductList.LIST_TYPE_USER_DEFINED:
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.0),
        );
      case ProductList.LIST_TYPE_USER_PANTRY:
        return null;
      case ProductList.LIST_TYPE_USER_SHOPPING:
        return const BeveledRectangleBorder(
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(16.0),
            right: Radius.circular(16.0),
          ),
        );
      case ProductList.LIST_TYPE_SCAN:
      case ProductList.LIST_TYPE_HISTORY:
      case ProductList.LIST_TYPE_HTTP_SEARCH_CATEGORY:
      case ProductList.LIST_TYPE_HTTP_SEARCH_GROUP:
      case ProductList.LIST_TYPE_HTTP_SEARCH_KEYWORDS:
        return null;
    }
    throw Exception('not handled for product list type $productListType');
  }
}
