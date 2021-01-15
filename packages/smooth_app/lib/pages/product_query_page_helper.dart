import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/data_models/query_product_list_supplier.dart';
import 'package:smooth_app/data_models/database_product_list_supplier.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/product_query_page.dart';
import 'package:smooth_app/database/dao_product_list.dart';

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

  static String getDurationString(final int seconds) {
    final double minutes = seconds / 60;
    final int roundMinutes = minutes.round();
    if (roundMinutes == 0) {
      return 'less than one minute ago';
    }
    if (roundMinutes == 1) {
      return 'about 1 minute ago';
    }
    if (roundMinutes < 60) {
      return 'about $roundMinutes minutes ago';
    }
    final double hours = minutes / 60;
    final int roundHours = hours.round();
    if (roundHours == 1) {
      return 'about 1 hour ago';
    }
    if (roundHours < 24) {
      return 'about $roundHours hours ago';
    }
    final double days = hours / 24;
    final int roundDays = days.round();
    if (roundDays == 1) {
      return 'about one day ago';
    }
    if (roundDays < 7) {
      return 'about $roundDays days ago';
    }
    final double weeks = days / 7;
    final int roundWeeks = weeks.round();
    if (roundWeeks == 1) {
      return 'about 1 week ago';
    }
    if (roundWeeks <= 4) {
      return 'about $roundWeeks weeks ago';
    }
    final double months = days / (365 / 12);
    final int roundMonths = months.round();
    if (roundMonths == 1) {
      return 'about 1 month ago';
    }
    return 'about $roundMonths months ago';
  }
}
