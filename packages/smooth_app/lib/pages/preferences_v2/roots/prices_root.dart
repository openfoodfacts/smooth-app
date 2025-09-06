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
            _buildUserPricesTile(context, appLocalizations, userId),
            _buildProofsTile(context, appLocalizations),
          ],
        ),
      ],
      PreferenceCard(
        title: appLocalizations.contribute,
        tiles: <PreferenceTile>[
          _buildAddReceiptTile(context, appLocalizations),
          _buildAddPriceTagsTile(context, appLocalizations),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.prices_generic_title,
        tiles: <PreferenceTile>[
          _buildNewestPricesTile(context, appLocalizations),
          _buildTopContributorsTile(context, appLocalizations),
          _buildTopLocationsTile(context, appLocalizations),
          _buildTopProductsTile(context, appLocalizations),
          _buildMetricsTile(context, appLocalizations),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_prices_ways_contribute_title,
        tiles: <PreferenceTile>[
          if (userPreferences.getFlag(
                UserPreferencesDevMode.userPreferencesFlagBulkProofUpload,
              ) ??
              false)
            _buildBulkProofUploadTile(context, appLocalizations),
          _buildContributionAssistantTile(appLocalizations),
          _buildValidationAssistantTile(appLocalizations),
          _buildMultipleProofTile(appLocalizations),
          _buildChallengesTile(appLocalizations),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_prices_loyalty_data_title,
        tiles: <PreferenceTile>[_buildGdprTile(appLocalizations)],
      ),
    ];
  }

  // User Profile section (when connected)
  PreferenceTile _buildUserPricesTile(
    BuildContext context,
    AppLocalizations appLocalizations,
    String userId,
  ) {
    return PreferenceTile(
      icon: Icons.attach_money_outlined,
      title: PriceUserButton.showUserTitle(user: userId, context: context),
      subtitleText: appLocalizations.preferences_prices_user_prices_subtitle,
      trailing: LazyCounterWidget(LazyCounterPrices(userId)),
      onTap: () async =>
          PriceUserButton.showUserPrices(user: userId, context: context),
    );
  }

  PreferenceTile _buildProofsTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      icon: Icons.receipt_long_outlined,
      title: appLocalizations.user_search_proofs_title,
      subtitleText: appLocalizations.preferences_prices_proofs_subtitle,
      onTap: () async => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              const PricesProofsPage(selectProof: false),
        ),
      ),
    );
  }

  // Contribute section
  PreferenceTile _buildAddReceiptTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      icon: Icons.receipt_long_outlined,
      title: appLocalizations.prices_add_a_receipt,
      subtitleText: appLocalizations.preferences_prices_add_receipt_subtitle,
      onTap: () async => ProductPriceAddPage.showProductPage(
        context: context,
        proofType: ProofType.receipt,
      ),
    );
  }

  PreferenceTile _buildAddPriceTagsTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      icon: Icons.sell_outlined,
      title: appLocalizations.prices_add_price_tags,
      subtitleText: appLocalizations.preferences_prices_add_price_tags_subtitle,
      onTap: () async => ProductPriceAddPage.showProductPage(
        context: context,
        proofType: ProofType.priceTag,
      ),
    );
  }

  // Prices section
  PreferenceTile _buildNewestPricesTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      icon: CupertinoIcons.money_dollar_circle,
      title: appLocalizations.preferences_prices_newest_title,
      subtitleText: appLocalizations.preferences_prices_newest_subtitle,
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
    );
  }

  PreferenceTile _buildTopContributorsTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      icon: PriceButton.userIconData,
      title: appLocalizations.preferences_prices_top_contributors_title,
      onTap: () async => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const PricesUsersPage(),
        ),
      ),
    );
  }

  PreferenceTile _buildTopLocationsTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      icon: PriceButton.locationIconData,
      title: appLocalizations.all_search_prices_top_location_title,
      onTap: () async => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const PricesLocationsPage(),
        ),
      ),
    );
  }

  PreferenceTile _buildTopProductsTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      icon: PriceButton.productIconData,
      title: appLocalizations.all_search_prices_top_product_title,
      onTap: () async => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const PricesProductsPage(),
        ),
      ),
    );
  }

  PreferenceTile _buildMetricsTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      icon: Icons.bar_chart,
      title: appLocalizations.preferences_prices_metrics_title,
      subtitleText: appLocalizations.preferences_prices_metrics_subtitle,
      onTap: () async => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const PricesStatsPage(),
        ),
      ),
    );
  }

  // Ways to Contribute section
  PreferenceTile _buildBulkProofUploadTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      icon: Icons.upload_file,
      title: appLocalizations.prices_bulk_proof_upload_title,
      onTap: () async => ProofBulkAddPage.showPage(context: context),
    );
  }

  UrlPreferenceTile _buildContributionAssistantTile(
    AppLocalizations appLocalizations,
  ) {
    return UrlPreferenceTile(
      icon: Icons.add_a_photo_outlined,
      title: appLocalizations.prices_contribution_assistant,
      url:
          'https://prices.openfoodfacts.org/experiments/contribution-assistant',
    );
  }

  UrlPreferenceTile _buildValidationAssistantTile(
    AppLocalizations appLocalizations,
  ) {
    return UrlPreferenceTile(
      icon: Icons.check_circle_outline,
      title: appLocalizations.prices_validation_assistant,
      subtitleText:
          appLocalizations.preferences_prices_validation_assistant_subtitle,
      url:
          'https://prices.openfoodfacts.org/experiments/price-validation-assistant',
    );
  }

  UrlPreferenceTile _buildMultipleProofTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      icon: Icons.add_photo_alternate_outlined,
      title: appLocalizations.prices_multiple_proof_addition_system,
      subtitleText: appLocalizations.preferences_prices_multiple_proof_subtitle,
      url: 'https://prices.openfoodfacts.org/proofs/add/multiple',
    );
  }

  UrlPreferenceTile _buildChallengesTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      icon: Icons.emoji_events_outlined,
      title: appLocalizations.preferences_prices_challenges_title,
      subtitleText: appLocalizations.preferences_prices_challenges_subtitle,
      url: 'https://prices.openfoodfacts.org/experiments/challenge',
    );
  }

  // Loyalty Data section
  UrlPreferenceTile _buildGdprTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      icon: Icons.card_membership_outlined,
      title: appLocalizations.contribute_prices_gdpr,
      subtitleText: appLocalizations.preferences_prices_gdpr_subtitle,
      url: 'https://wiki.openfoodfacts.org/GDPR_request',
    );
  }
}
