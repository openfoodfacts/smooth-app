import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/data_models/query_product_list_supplier.dart';
import 'package:smooth_app/data_models/database_product_list_supplier.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/product_query_page.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_alert_dialog.dart';

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
    if (timestamp == null) {
      _openQueryPage(
        color: color,
        heroTag: heroTag,
        name: name,
        context: context,
        popBefore: false,
        supplier: QueryProductListSupplier(productQuery),
      );
      return;
    }
    final int now = LocalDatabase.nowInMillis();
    final int seconds = ((now - timestamp) / 1000).floor();
    final String lastTime = getDurationString(seconds);
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SmoothAlertDialog(
          title: 'Cached products',
          body: Text(
            'You already ran the same search $lastTime.\n'
            'Do you want to reuse the cached results or to refresh them via internet?',
          ),
          actions: <SmoothSimpleButton>[
            SmoothSimpleButton(
              onPressed: () => _openQueryPage(
                color: color,
                heroTag: heroTag,
                name: name,
                context: context,
                popBefore: true,
                supplier:
                    DatabaseProductListSupplier(productQuery, localDatabase),
              ),
              text: 'reuse',
              width: 100,
            ),
            SmoothSimpleButton(
              onPressed: () => _openQueryPage(
                color: color,
                heroTag: heroTag,
                name: name,
                context: context,
                popBefore: true,
                supplier: QueryProductListSupplier(productQuery),
              ),
              text: 'refresh',
              width: 100,
            ),
          ],
        );
      },
    );
  }

  void _openQueryPage({
    @required final Color color,
    @required final String heroTag,
    @required final String name,
    @required final ProductListSupplier supplier,
    @required final BuildContext context,
    @required final bool popBefore,
  }) {
    if (popBefore) {
      Navigator.pop(context);
    }
    Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => ProductQueryPage(
          productListSupplier: supplier,
          heroTag: heroTag,
          mainColor: color,
          name: name,
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
