import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_in/statistics_cards/app_bar_statistics_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/lazy_counter.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/query/paged_user_product_query.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/autosize_text.dart';

class ContributionStatisticsCard extends StatelessWidget {
  const ContributionStatisticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return AppBarStatisticsCard(
      imagePath: 'assets/preferences/ingredients.svg.vec',
      description: appLocalizations.preferences_app_bar_products_modified,
      lazyCounter: const LazyCounterUserSearch(UserSearchType.INFORMER),
      autoSizeGroup: context.read<AutoSizeGroup>(),
      onTap: () {
        ProductQueryPageHelper.openBestChoice(
          name: appLocalizations.user_search_informer_title,
          localDatabase: context.read<LocalDatabase>(),
          productQuery: PagedUserProductQuery(
            userId: ProductQuery.getWriteUser().userId,
            type: UserSearchType.INFORMER,
            productType: ProductType.food,
          ),
          context: context,
          editableAppBarTitle: true,
        );
      },
    );
  }
}
