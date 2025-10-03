import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_in/statistics_cards/app_bar_statistics_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/lazy_counter.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/query/paged_product_query.dart';
import 'package:smooth_app/query/paged_user_product_query.dart';

class ContributionStatisticsCard extends StatelessWidget {
  const ContributionStatisticsCard({
    required this.userId,
    this.autoSizeGroup,
    super.key,
  });

  final String userId;
  final AutoSizeGroup? autoSizeGroup;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final LocalDatabase localDatabase = context.read<LocalDatabase>();

    return AppBarStatisticsCard(
      imagePath: 'assets/preferences/ingredients.svg',
      description: appLocalizations.preferences_app_bar_products_modified,
      lazyCounter: const LazyCounterUserSearch(UserSearchType.INFORMER),
      onTap: () async => _openProductQuery(
        context: context,
        localDatabase: localDatabase,
        productQuery: PagedUserProductQuery(
          userId: userId,
          type: UserSearchType.INFORMER,
          productType: ProductType.food,
        ),
        title: appLocalizations.user_search_informer_title,
      ),
      autoSizeGroup: autoSizeGroup,
    );
  }

  Future<void> _openProductQuery({
    required BuildContext context,
    required LocalDatabase localDatabase,
    required PagedProductQuery productQuery,
    required String title,
  }) async => ProductQueryPageHelper.openBestChoice(
    name: title,
    localDatabase: localDatabase,
    productQuery: productQuery,
    context: context,
    editableAppBarTitle: true,
  );
}
