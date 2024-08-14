import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/database/dao_string_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/helpers/string_extension.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/product/common/product_dialog_helper.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/product/common/search_helper.dart';
import 'package:smooth_app/query/keywords_product_query.dart';

/// Search helper dedicated to product search.
class SearchProductHelper extends SearchHelper {
  SearchProductHelper();

  @override
  String get historyKey => DaoStringList.keySearchProductHistory;

  @override
  String getHintText(final AppLocalizations appLocalizations) =>
      appLocalizations.search;

  @override
  void search(
    BuildContext context,
    String query, {
    required SearchQueryCallback searchQueryCallback,
  }) {
    query = query.trim();
    if (query.isEmpty) {
      return;
    } else if (query.removeSpaces().hasOnlyDigits()) {
      // This maybe a barcode => remove spaces within the string
      query = query.removeSpaces();
    }

    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    addQuery(localDatabase, query);

    if (int.tryParse(query) != null) {
      _onSubmittedBarcode(
        query,
        context,
        localDatabase,
        // TODO(monsieurtanuki): we should use searchQueryCallback here too, shouldn't we?
      );
    } else {
      _onSubmittedText(
        query,
        context,
        localDatabase,
      );
    }
  }

// used to be in now defunct `ChoosePage`
  Future<void> _onSubmittedBarcode(
    final String value,
    final BuildContext context,
    final LocalDatabase localDatabase,
  ) async {
    final ProductDialogHelper productDialogHelper = ProductDialogHelper(
      barcode: value,
      context: context,
      localDatabase: localDatabase,
    );
    final FetchedProduct fetchedProduct =
        await productDialogHelper.openBestChoice();
    if (fetchedProduct.status == FetchedProductStatus.ok) {
      AnalyticsHelper.trackSearch(
        search: value,
        searchCategory: 'barcode',
        searchCount: 1,
      );
      if (context.mounted) {
        AppNavigator.of(context).push(
          AppRoutes.PRODUCT(
            fetchedProduct.product!.barcode!,
            heroTag: 'search_${fetchedProduct.product!.barcode!}',
          ),
          extra: fetchedProduct.product,
        );
      }
    } else {
      AnalyticsHelper.trackSearch(
        search: value,
        searchCategory: 'barcode',
        searchCount: 0,
      );
      productDialogHelper.openError(fetchedProduct);
    }
  }

// used to be in now defunct `ChoosePage`
  Future<void> _onSubmittedText(
    final String value,
    final BuildContext context,
    final LocalDatabase localDatabase,
  ) async {
    emit(
      SearchQuery(
        search: value,
        widget: await ProductQueryPageHelper.getBestChoiceWidget(
          name: value,
          localDatabase: localDatabase,
          productQuery: KeywordsProductQuery(value),
          context: context,
          editableAppBarTitle: false,
        ),
      ),
    );
  }
}
