// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';

// Project imports:
import 'package:smooth_app/data_models/database_product_list_supplier.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/data_models/query_product_list_supplier.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/pages/product/common/product_query_page.dart';

class ProductQueryPageHelper {
  Future<void> openBestChoice({
    @required final ProductQuery productQuery,
    @required final LocalDatabase localDatabase,
    @required final Color color,
    @required final String heroTag,
    @required final String name,
    @required final BuildContext context,
  }) async {
    final int timestamp = await DaoProductList(localDatabase)
        .getTimestamp(productQuery.getProductList());
    final ProductListSupplier supplier = timestamp == null
        ? QueryProductListSupplier(productQuery)
        : DatabaseProductListSupplier(productQuery, localDatabase);
    Navigator.push<Widget>(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => ProductQueryPage(
          productListSupplier: supplier,
          heroTag: heroTag,
          mainColor: color,
          name: name,
          lastUpdate: timestamp,
        ),
      ),
    );
  }

  static String getDurationStringFromSeconds(
      final int seconds, AppLocalizations appLocalizations) {
    final double minutes = seconds / 60;
    final int roundMinutes = minutes.round();
    if (roundMinutes == 0) {
      return appLocalizations.ago_less_1_minute;
    }
    if (roundMinutes == 1) {
      return appLocalizations.ago_1_minute;
    }
    if (roundMinutes < 60) {
      return '$roundMinutes ${appLocalizations.ago_x_minutes}';
    }
    final double hours = minutes / 60;
    final int roundHours = hours.round();
    if (roundHours == 1) {
      return appLocalizations.ago_1_hour;
    }
    if (roundHours < 24) {
      return '$roundHours ${appLocalizations.ago_x_hours}';
    }
    final double days = hours / 24;
    final int roundDays = days.round();
    if (roundDays == 1) {
      return appLocalizations.ago_1_day;
    }
    if (roundDays < 7) {
      return '$roundDays ${appLocalizations.ago_x_days}';
    }
    final double weeks = days / 7;
    final int roundWeeks = weeks.round();
    if (roundWeeks == 1) {
      return appLocalizations.ago_1_week;
    }
    if (roundWeeks <= 4) {
      return '$roundWeeks ${appLocalizations.ago_x_weeks}';
    }
    final double months = days / (365 / 12);
    final int roundMonths = months.round();
    if (roundMonths == 1) {
      return appLocalizations.ago_1_month;
    }
    return '$roundMonths ${appLocalizations.ago_x_months}';
  }

  static String getDurationStringFromTimestamp(
      final int timestamp, BuildContext context) {
    final int now = LocalDatabase.nowInMillis();
    final int seconds = ((now - timestamp) / 1000).floor();
    return getDurationStringFromSeconds(seconds, AppLocalizations.of(context));
  }

  static bool isListReversed(final ProductList productList) =>
      productList.listType == ProductList.LIST_TYPE_HISTORY ||
      productList.listType == ProductList.LIST_TYPE_SCAN;

  static String getProductListLabel(
    final ProductList productList, {
    final bool verbose = true,
    final AppLocalizations appLocalizations,
  }) {
    switch (productList.listType) {
      case ProductList.LIST_TYPE_HTTP_SEARCH_GROUP:
        return '${_getGroupName(productList.parameters, appLocalizations)}${verbose ? ' ${appLocalizations.category_search}' : ''}';
      case ProductList.LIST_TYPE_HTTP_SEARCH_KEYWORDS:
        return '${productList.parameters}${verbose ? ' ${appLocalizations.category_search}' : ''}';
      case ProductList.LIST_TYPE_HTTP_SEARCH_CATEGORY:
        return '${productList.parameters}${verbose ? ' ${appLocalizations.category_search}' : ''}';
      case ProductList.LIST_TYPE_SCAN:
        return appLocalizations.scan;
      case ProductList.LIST_TYPE_HISTORY:
        return appLocalizations.recently_seen_products;
      case ProductList.LIST_TYPE_USER_DEFINED:
        return '${productList.parameters}${verbose ? ' ${appLocalizations.my_list}' : ''}';
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
}
