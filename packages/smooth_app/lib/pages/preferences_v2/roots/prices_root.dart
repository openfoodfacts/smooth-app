import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/lazy_counter.dart';
import 'package:smooth_app/pages/preferences/lazy_counter_widget.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_button.dart';
import 'package:smooth_app/pages/prices/price_user_button.dart';
import 'package:smooth_app/pages/prices/prices_locations_page.dart';
import 'package:smooth_app/pages/prices/prices_page.dart';
import 'package:smooth_app/pages/prices/prices_products_page.dart';
import 'package:smooth_app/pages/prices/prices_proofs_page.dart';
import 'package:smooth_app/pages/prices/prices_stats_page.dart';
import 'package:smooth_app/pages/prices/prices_users_page.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/pages/prices/proof_bulk_add_page.dart';
import 'package:smooth_app/query/product_query.dart';

class PricesRoot extends PreferencesRoot {
  const PricesRoot({required super.title});

  @override
  List<PreferenceCard> getCards(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String userId = ProductQuery.getWriteUser().userId;
    final bool isConnected = OpenFoodAPIConfiguration.globalUser != null;
    final UserPreferences userPreferences = context.read<UserPreferences>();

    return <PreferenceCard>[
      if (isConnected) ...<PreferenceCard>[
        PreferenceCard(
          title: appLocalizations.user_profile_title_id_default(userId),
          tiles: <PreferenceTile>[
            PreferenceTile(
              icon: CupertinoIcons.money_dollar_circle,
              title: PriceUserButton.showUserTitle(
                user: userId,
                context: context,
              ),
              trailing: LazyCounterWidget(LazyCounterPrices(userId)),
              onTap: () async => PriceUserButton.showUserPrices(
                user: userId,
                context: context,
              ),
            ),
            PreferenceTile(
              icon: Icons.receipt,
              title: appLocalizations.user_search_proofs_title,
              onTap: () async => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      const PricesProofsPage(selectProof: false),
                ),
              ),
            ),
          ],
        ),
      ],
      PreferenceCard(
        title: appLocalizations.contribute,
        tiles: <PreferenceTile>[
          PreferenceTile(
            icon: Icons.add_shopping_cart,
            title: appLocalizations.prices_add_a_receipt,
            onTap: () async => ProductPriceAddPage.showProductPage(
              context: context,
              proofType: ProofType.receipt,
            ),
          ),
          PreferenceTile(
            icon: Icons.add_shopping_cart,
            title: appLocalizations.prices_add_price_tags,
            onTap: () async => ProductPriceAddPage.showProductPage(
              context: context,
              proofType: ProofType.priceTag,
            ),
          ),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.prices_generic_title,
        tiles: <PreferenceTile>[
          PreferenceTile(
            icon: CupertinoIcons.money_dollar_circle,
            title: appLocalizations.all_search_prices_latest_title,
            trailing: const LazyCounterWidget(LazyCounterPrices(null)),
            onTap: () async => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => PricesPage(
                  GetPricesModel(
                    parameters: GetPricesModel.getStandardPricesParameters(),
                    uri: OpenPricesAPIClient.getUri(
                      path: 'prices',
                      uriHelper: ProductQuery.uriPricesHelper,
                    ),
                    title: appLocalizations.all_search_prices_latest_title,
                    lazyCounterPrices: const LazyCounterPrices(null),
                  ),
                ),
              ),
            ),
          ),
          PreferenceTile(
            icon: PriceButton.userIconData,
            title: appLocalizations.all_search_prices_top_user_title,
            onTap: () async => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const PricesUsersPage(),
              ),
            ),
          ),
          PreferenceTile(
            icon: PriceButton.locationIconData,
            title: appLocalizations.all_search_prices_top_location_title,
            onTap: () async => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const PricesLocationsPage(),
              ),
            ),
          ),
          PreferenceTile(
            icon: PriceButton.productIconData,
            title: appLocalizations.all_search_prices_top_product_title,
            onTap: () async => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const PricesProductsPage(),
              ),
            ),
          ),
          PreferenceTile(
            icon: Icons.bar_chart,
            title: appLocalizations.prices_stats_statistics,
            onTap: () async => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const PricesStatsPage(),
              ),
            ),
          ),
        ],
      ),
      PreferenceCard(
        title: 'Experiments',
        tiles: <PreferenceTile>[
          if (userPreferences.getFlag(
                UserPreferencesDevMode.userPreferencesFlagBulkProofUpload,
              ) ??
              false)
            PreferenceTile(
              icon: Icons.upload_file,
              title: appLocalizations.prices_bulk_proof_upload_title,
              onTap: () async => ProofBulkAddPage.showPage(context: context),
            ),
          UrlPreferenceTile(
            icon: Icons.assistant,
            title: appLocalizations.prices_contribution_assistant,
            url:
                'https://prices.openfoodfacts.org/experiments/contribution-assistant',
          ),
          UrlPreferenceTile(
            icon: Icons.verified,
            title: appLocalizations.prices_validation_assistant,
            url:
                'https://prices.openfoodfacts.org/experiments/price-validation-assistant',
          ),
          UrlPreferenceTile(
            icon: Icons.add_box,
            title: appLocalizations.prices_multiple_proof_addition_system,
            url: 'https://prices.openfoodfacts.org/proofs/add/multiple',
          ),
          UrlPreferenceTile(
            icon: Icons.emoji_events,
            title: appLocalizations.prices_challenges_page,
            url: 'https://prices.openfoodfacts.org/experiments/challenge',
          ),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.privacy_policy,
        tiles: <PreferenceTile>[
          UrlPreferenceTile(
            icon: Icons.privacy_tip,
            title: appLocalizations.contribute_prices_gdpr,
            url: 'https://wiki.openfoodfacts.org/GDPR_request',
          ),
        ],
      ),
    ];
  }
}
