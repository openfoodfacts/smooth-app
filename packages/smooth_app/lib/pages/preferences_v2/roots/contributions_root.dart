import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/lazy_counter.dart';
import 'package:smooth_app/pages/preferences/lazy_counter_widget.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/query/paged_product_query.dart';
import 'package:smooth_app/query/paged_to_be_completed_product_query.dart';
import 'package:smooth_app/query/paged_user_product_query.dart';
import 'package:smooth_app/query/product_query.dart';

class ContributionsRoot extends PreferencesRoot {
  const ContributionsRoot({required super.title});

  @override
  List<PreferenceCard> getCards(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final String userId = ProductQuery.getWriteUser().userId;

    return <PreferenceCard>[
      PreferenceCard(
        title: appLocalizations.contribute,
        tiles: <PreferenceTile>[
          PreferenceTile(
            icon: Icons.add_circle_outline,
            title: appLocalizations.user_search_contributor_title,
            trailing: const LazyCounterWidget(
              LazyCounterUserSearch(UserSearchType.CONTRIBUTOR),
            ),
            onTap: () async => _openProductQuery(
              context: context,
              localDatabase: localDatabase,
              productQuery: PagedUserProductQuery(
                userId: userId,
                type: UserSearchType.CONTRIBUTOR,
                productType: ProductType.food,
              ),
              title: appLocalizations.user_search_contributor_title,
            ),
          ),
          PreferenceTile(
            icon: Icons.edit,
            title: appLocalizations.user_search_informer_title,
            trailing: const LazyCounterWidget(
              LazyCounterUserSearch(UserSearchType.INFORMER),
            ),
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
          ),
          PreferenceTile(
            icon: Icons.add_a_photo,
            title: appLocalizations.user_search_photographer_title,
            trailing: const LazyCounterWidget(
              LazyCounterUserSearch(UserSearchType.PHOTOGRAPHER),
            ),
            onTap: () async => _openProductQuery(
              context: context,
              localDatabase: localDatabase,
              productQuery: PagedUserProductQuery(
                userId: userId,
                type: UserSearchType.PHOTOGRAPHER,
                productType: ProductType.food,
              ),
              title: appLocalizations.user_search_photographer_title,
            ),
          ),
          PreferenceTile(
            icon: Icons.more_horiz,
            title: appLocalizations.user_search_to_be_completed_title,
            trailing: const LazyCounterWidget(
              LazyCounterUserSearch(UserSearchType.TO_BE_COMPLETED),
            ),
            onTap: () async => _openProductQuery(
              context: context,
              localDatabase: localDatabase,
              productQuery: PagedUserProductQuery(
                userId: userId,
                type: UserSearchType.TO_BE_COMPLETED,
                productType: ProductType.food,
              ),
              title: appLocalizations.user_search_to_be_completed_title,
            ),
          ),
          PreferenceTile(
            icon: Icons.more_outlined,
            title: appLocalizations.all_search_to_be_completed_title,
            onTap: () async => _openProductQuery(
              context: context,
              localDatabase: localDatabase,
              productQuery: PagedToBeCompletedProductQuery(
                productType: ProductType.food,
              ),
              title: appLocalizations.all_search_to_be_completed_title,
            ),
          ),
          UrlPreferenceTile(
            icon: Icons.category,
            title: appLocalizations.categorize_products_country_title,
            url:
                'https://hunger.openfoodfacts.org/eco-score?cc=${ProductQuery.getCountry().offTag}',
          ),
        ],
      ),
    ];
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
