import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/lazy_counter.dart';
import 'package:smooth_app/pages/preferences/lazy_counter_widget.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/prices_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/query/paged_product_query.dart';
import 'package:smooth_app/query/paged_to_be_completed_product_query.dart';
import 'package:smooth_app/query/paged_user_product_query.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class ContributionsRoot extends PreferencesRoot {
  const ContributionsRoot({required super.title});

  @override
  List<PreferenceCard> getCards(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final String userId = ProductQuery.getWriteUser().userId;

    return <PreferenceCard>[
      PreferenceCard(
        title: appLocalizations.preferences_my_contributions_title,
        tiles: <PreferenceTile>[
          _buildNewProductsTile(
            context,
            appLocalizations,
            localDatabase,
            userId,
          ),
          _buildInformerTile(context, appLocalizations, localDatabase, userId),
          _buildPhotographerTile(
            context,
            appLocalizations,
            localDatabase,
            userId,
          ),
          _buildToBeCompletedTile(
            context,
            appLocalizations,
            localDatabase,
            userId,
          ),
          _buildAllIncompleteTile(context, appLocalizations, localDatabase),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_my_contributions_prices_title,
        tiles: <PreferenceTile>[_buildMyPricesTile(context, appLocalizations)],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_contribute_title,
        tiles: <PreferenceTile>[_buildCategorizeProductsTile(appLocalizations)],
      ),
    ];
  }

  // Contribution section
  PreferenceTile _buildNewProductsTile(
    BuildContext context,
    AppLocalizations appLocalizations,
    LocalDatabase localDatabase,
    String userId,
  ) {
    return PreferenceTile(
      icon: const icons.Milk.happy(),
      title: appLocalizations.preferences_contributions_products_added_title,
      subtitleText:
          appLocalizations.preferences_contributions_new_products_subtitle,
      padding: const EdgeInsetsDirectional.only(
        start: LARGE_SPACE,
        end: SMALL_SPACE,
      ),
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
    );
  }

  PreferenceTile _buildInformerTile(
    BuildContext context,
    AppLocalizations appLocalizations,
    LocalDatabase localDatabase,
    String userId,
  ) {
    return PreferenceTile(
      icon: const icons.Changes(size: 20.0),
      title: appLocalizations.user_search_informer_title,
      padding: const EdgeInsetsDirectional.only(
        start: LARGE_SPACE,
        end: SMALL_SPACE,
      ),
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
    );
  }

  PreferenceTile _buildPhotographerTile(
    BuildContext context,
    AppLocalizations appLocalizations,
    LocalDatabase localDatabase,
    String userId,
  ) {
    return PreferenceTile(
      icon: const icons.Camera.happy(),
      title: appLocalizations.user_search_photographer_title,
      padding: const EdgeInsetsDirectional.only(
        start: LARGE_SPACE,
        end: SMALL_SPACE,
      ),
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
    );
  }

  PreferenceTile _buildToBeCompletedTile(
    BuildContext context,
    AppLocalizations appLocalizations,
    LocalDatabase localDatabase,
    String userId,
  ) {
    return PreferenceTile(
      icon: const icons.Incomplete(),
      title: appLocalizations.preferences_contributions_to_be_completed_title,
      padding: const EdgeInsetsDirectional.only(
        start: LARGE_SPACE,
        end: SMALL_SPACE,
      ),
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
    );
  }

  PreferenceTile _buildAllIncompleteTile(
    BuildContext context,
    AppLocalizations appLocalizations,
    LocalDatabase localDatabase,
  ) {
    return PreferenceTile(
      icon: const icons.Eye.checkbox(),
      title: appLocalizations.preferences_contributions_all_incomplete_title,
      subtitleText:
          appLocalizations.preferences_contributions_all_incomplete_subtitle,
      onTap: () async => _openProductQuery(
        context: context,
        localDatabase: localDatabase,
        productQuery: PagedToBeCompletedProductQuery(
          productType: ProductType.food,
        ),
        title: appLocalizations.all_search_to_be_completed_title,
      ),
    );
  }

  PreferenceTile _buildMyPricesTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      icon: const icons.PriceTag(),
      title: appLocalizations.preferences_my_contributions_my_prices_title,
      subtitleText:
          appLocalizations.preferences_my_contributions_my_prices_subtitle,
      onTap: () async => Navigator.of(context).push(
        MaterialPageRoute<Widget>(
          builder: (BuildContext context) =>
              ChangeNotifierProvider<PreferencesRootSearchController>(
                create: (_) => PreferencesRootSearchController(),
                child: PricesRoot(
                  title: appLocalizations.preferences_prices_title,
                ),
              ),
        ),
      ),
    );
  }

  UrlPreferenceTile _buildCategorizeProductsTile(
    AppLocalizations appLocalizations,
  ) {
    return UrlPreferenceTile(
      icon: const icons.Globe(),
      title: appLocalizations.categorize_products_country_title,
      subtitleText:
          appLocalizations.preferences_contributions_categorize_subtitle,
      url:
          'https://hunger.openfoodfacts.org/eco-score?cc=${ProductQuery.getCountry().offTag}',
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
