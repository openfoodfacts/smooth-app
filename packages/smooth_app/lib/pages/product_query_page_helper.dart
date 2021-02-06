import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/data_models/query_product_list_supplier.dart';
import 'package:smooth_app/data_models/database_product_list_supplier.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/product_query_page.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';
import 'package:smooth_app/data_models/product_list.dart';

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
    Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
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

  static String getDurationStringFromSeconds(final int seconds) {
    final double minutes = seconds / 60;
    final int roundMinutes = minutes.round();
    if (roundMinutes == 0) {
      return 'less than 1 minute ago';
    }
    if (roundMinutes == 1) {
      return '1 minute ago';
    }
    if (roundMinutes < 60) {
      return '$roundMinutes minutes ago';
    }
    final double hours = minutes / 60;
    final int roundHours = hours.round();
    if (roundHours == 1) {
      return '1 hour ago';
    }
    if (roundHours < 24) {
      return '$roundHours hours ago';
    }
    final double days = hours / 24;
    final int roundDays = days.round();
    if (roundDays == 1) {
      return 'one day ago';
    }
    if (roundDays < 7) {
      return '$roundDays days ago';
    }
    final double weeks = days / 7;
    final int roundWeeks = weeks.round();
    if (roundWeeks == 1) {
      return '1 week ago';
    }
    if (roundWeeks <= 4) {
      return '$roundWeeks weeks ago';
    }
    final double months = days / (365 / 12);
    final int roundMonths = months.round();
    if (roundMonths == 1) {
      return '1 month ago';
    }
    return '$roundMonths months ago';
  }

  static String getDurationStringFromTimestamp(final int timestamp) {
    final int now = LocalDatabase.nowInMillis();
    final int seconds = ((now - timestamp) / 1000).floor();
    return getDurationStringFromSeconds(seconds);
  }

  static String getProductListLabel(
    final ProductList productList, {
    final bool verbose = true,
  }) {
    switch (productList.listType) {
      case ProductList.LIST_TYPE_HTTP_SEARCH_GROUP:
        return '${_getGroupName(productList.parameters)}${verbose ? ' (category search)' : ''}';
      case ProductList.LIST_TYPE_HTTP_SEARCH_KEYWORDS:
        return '${productList.parameters}${verbose ? ' (keyword search)' : ''}';
      case ProductList.LIST_TYPE_SCAN:
        return 'Scan';
      case ProductList.LIST_TYPE_HISTORY:
        return 'History';
      case ProductList.LIST_TYPE_USER_DEFINED:
        return '${productList.parameters}${verbose ? ' (my list)' : ''}';
    }
    return 'Unknown product list: ${productList.listType} / ${productList.parameters}';
  }

  static String _getGroupName(final String groupId) {
    for (final PnnsGroup2 group2 in PnnsGroup2.values) {
      if (group2.id == groupId) {
        return group2.name;
      }
    }
    return 'not found: $groupId';
  }

  static String getProductCount(final ProductList productList) {
    if (productList.databaseCountDistinct == null ||
        productList.databaseCountDistinct == 0) {
      return 'no product';
    }
    if (productList.databaseCountDistinct == 1) {
      return '1 product';
    }
    return '${productList.databaseCountDistinct} products';
  }
}
