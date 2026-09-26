import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/common/product_query_page.dart';
import 'package:smooth_app/pages/product/common/search_helper.dart';
import 'package:smooth_app/query/paged_product_query.dart';

class ProductQueryPageHelper {
  const ProductQueryPageHelper._();

  static Future<Widget> getBestChoiceWidget({
    required final PagedProductQuery productQuery,
    required final LocalDatabase localDatabase,
    required final String name,
    required final BuildContext context,
    bool editableAppBarTitle = true,
    bool searchResult = true,
  }) async {
    final ProductListSupplier supplier =
        await ProductListSupplier.getBestSupplier(productQuery, localDatabase);

    return ProductQueryPage(
      productListSupplier: supplier,
      name: name,
      includeAppBar: editableAppBarTitle,
      searchResult: searchResult,
    );
  }

  static Future<void> openBestChoice({
    required final PagedProductQuery productQuery,
    required final LocalDatabase localDatabase,
    required final String name,
    required final BuildContext context,
    bool editableAppBarTitle = true,
    bool searchResult = true,
    SearchQueryCallback? editQueryCallback,
  }) async {
    final Widget widget = await getBestChoiceWidget(
      productQuery: productQuery,
      localDatabase: localDatabase,
      name: name,
      context: context,
      editableAppBarTitle: editableAppBarTitle,
      searchResult: searchResult,
    );

    if (!context.mounted) {
      return;
    }

    final bool? result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (BuildContext context) => widget),
    );

    if (result == true) {
      editQueryCallback?.call(name);
    }
  }

  static String getDurationStringFromSeconds(
    final int seconds,
    final AppLocalizations appLocalizations, {
    final bool compact = false,
  }) {
    final double minutes = seconds / 60;
    final int roundMinutes = minutes.round();
    if (roundMinutes == 0) {
      // TODO(monsieurtanuki): localize if relevant
      if (compact) {
        return '${seconds}s';
      }
    }
    if (roundMinutes < 60) {
      if (compact) {
        return '${roundMinutes}m';
      }
      return appLocalizations.plural_ago_minutes(roundMinutes);
    }

    final double hours = minutes / 60;
    final int roundHours = hours.round();
    if (roundHours < 24) {
      if (compact) {
        return '${roundHours}h';
      }
      return appLocalizations.plural_ago_hours(roundHours);
    }

    final double days = hours / 24;
    final int roundDays = days.round();
    if (roundDays < 7) {
      if (compact) {
        return '${roundDays}d';
      }
      return appLocalizations.plural_ago_days(roundDays);
    }
    final double weeks = days / 7;
    final int roundWeeks = weeks.round();
    if (compact) {
      return '${roundWeeks}w';
    }
    if (roundWeeks <= 4) {
      return appLocalizations.plural_ago_weeks(roundWeeks);
    }

    final double months = days / (365 / 12);
    final int roundMonths = months.round();
    return appLocalizations.plural_ago_months(roundMonths);
  }

  static String getDurationStringFromTimestamp(
    final int timestamp,
    final BuildContext context, {
    final bool compact = false,
  }) {
    final int now = LocalDatabase.nowInMillis();
    final int seconds = ((now - timestamp) / 1000).floor();
    return getDurationStringFromSeconds(
      seconds,
      AppLocalizations.of(context),
      compact: compact,
    );
  }

  static String getProductListLabel(
    final ProductList productList,
    final AppLocalizations appLocalizations,
  ) {
    switch (productList.listType) {
      case ProductListType.HTTP_SEARCH_KEYWORDS:
      case ProductListType.HTTP_SEARCH_CATEGORY:
      case ProductListType.HTTP_USER_CONTRIBUTOR:
      case ProductListType.HTTP_USER_INFORMER:
      case ProductListType.HTTP_USER_PHOTOGRAPHER:
      case ProductListType.HTTP_USER_TO_BE_COMPLETED:
      case ProductListType.HTTP_ALL_TO_BE_COMPLETED:
      case ProductListType.USER:
        return productList.parameters;
      case ProductListType.SCAN_SESSION:
        return appLocalizations.scan;
      case ProductListType.SCAN_HISTORY:
        return appLocalizations.scan_history;
      case ProductListType.HISTORY:
        return appLocalizations.recently_seen_products;
    }
  }
}
