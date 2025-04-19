import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/lazy_counter.dart';
import 'package:smooth_app/pages/preferences/lazy_counter_widget.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_button.dart';
import 'package:smooth_app/pages/prices/price_user_button.dart';
import 'package:smooth_app/pages/prices/prices_locations_page.dart';
import 'package:smooth_app/pages/prices/prices_page.dart';
import 'package:smooth_app/pages/prices/prices_products_page.dart';
import 'package:smooth_app/pages/prices/prices_proofs_page.dart';
import 'package:smooth_app/pages/prices/prices_users_page.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/pages/prices/proof_bulk_add_page.dart';
import 'package:smooth_app/query/product_query.dart';

/// Display of "Prices" for the preferences page.
class UserPreferencesPrices extends AbstractUserPreferences {
  UserPreferencesPrices({
    required super.context,
    required super.userPreferences,
    required super.appLocalizations,
    required super.themeData,
  });

  @override
  PreferencePageType getPreferencePageType() => PreferencePageType.PRICES;

  @override
  String getTitleString() => appLocalizations.prices_generic_title;

  @override
  IconData getLeadingIconData() => CupertinoIcons.money_dollar_circle;

  @override
  List<UserPreferencesItem> getChildren() {
    final String userId = ProductQuery.getWriteUser().userId;
    final bool isConnected = OpenFoodAPIConfiguration.globalUser != null;
    return <UserPreferencesItem>[
      if (isConnected)
        _getListTile(
          PriceUserButton.showUserTitle(
            user: userId,
            context: context,
          ),
          () async => PriceUserButton.showUserPrices(
            user: userId,
            context: context,
          ),
          CupertinoIcons.money_dollar_circle,
          lazyCounter: LazyCounterPrices(userId),
        ),
      if (isConnected)
        _getListTile(
          appLocalizations.user_search_proofs_title,
          () async => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const PricesProofsPage(
                selectProof: false,
              ),
            ),
          ),
          Icons.receipt,
        ),
      _getListTile(
        appLocalizations.prices_add_a_receipt,
        () async => ProductPriceAddPage.showProductPage(
          context: context,
          proofType: ProofType.receipt,
        ),
        Icons.add_shopping_cart,
      ),
      _getListTile(
        appLocalizations.prices_add_price_tags,
        () async => ProductPriceAddPage.showProductPage(
          context: context,
          proofType: ProofType.priceTag,
        ),
        Icons.add_shopping_cart,
      ),
      _getListTile(
        appLocalizations.all_search_prices_latest_title,
        () async => Navigator.of(context).push(
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
        CupertinoIcons.money_dollar_circle,
        lazyCounter: const LazyCounterPrices(null),
      ),
      _getListTile(
        appLocalizations.all_search_prices_top_user_title,
        () async => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const PricesUsersPage(),
          ),
        ),
        PriceButton.userIconData,
      ),
      _getListTile(
        appLocalizations.all_search_prices_top_location_title,
        () async => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const PricesLocationsPage(),
          ),
        ),
        PriceButton.locationIconData,
      ),
      _getListTile(
        appLocalizations.all_search_prices_top_product_title,
        () async => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const PricesProductsPage(),
          ),
        ),
        PriceButton.productIconData,
      ),
      if (userPreferences.getFlag(
              UserPreferencesDevMode.userPreferencesFlagBulkProofUpload) ??
          false)
        _getListTile(
          appLocalizations.prices_bulk_proof_upload_title,
          () async => ProofBulkAddPage.showPage(
            context: context,
          ),
          Icons.upload_file,
        ),
      _getListTile(
        appLocalizations.prices_contribution_assistant,
        () async => LaunchUrlHelper.launchURL(
          'https://prices.openfoodfacts.org/experiments/contribution-assistant',
        ),
        Icons.open_in_new,
      ),
      _getListTile(
        appLocalizations.prices_validation_assistant,
        () async => LaunchUrlHelper.launchURL(
          'https://prices.openfoodfacts.org/experiments/price-validation-assistant',
        ),
        Icons.open_in_new,
      ),
      _getListTile(
        appLocalizations.prices_multiple_proof_addition_system,
        () async => LaunchUrlHelper.launchURL(
          'https://prices.openfoodfacts.org/proofs/add/multiple',
        ),
        Icons.open_in_new,
      ),
      _getListTile(
        appLocalizations.prices_challenges_page,
        () async => LaunchUrlHelper.launchURL(
          'https://prices.openfoodfacts.org/experiments/challenge',
        ),
        Icons.open_in_new,
      ),
      _getListTile(
        appLocalizations.contribute_prices_gdpr,
        () async => LaunchUrlHelper.launchURL(
            'https://wiki.openfoodfacts.org/GDPR_request'),
        Icons.open_in_new,
      ),
    ];
  }

  // we need the [AppNavigator] for a better back-gesture management.
  @override
  Future<void> runHeaderAction() async => AppNavigator.of(context).push(
        AppRoutes.PREFERENCES(PreferencePageType.PRICES),
      );

  UserPreferencesItem _getListTile(
    final String title,
    final VoidCallback onTap,
    final IconData leading, {
    final LazyCounter? lazyCounter,
  }) =>
      UserPreferencesItemSimple(
        labels: <String>[title],
        builder: (_) => Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          color: Theme.of(context).cardColor,
          child: UserPreferencesListTile(
            title: Text(title),
            onTap: onTap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            leading: UserPreferencesListTile.getTintedIcon(leading, context),
            trailing:
                lazyCounter == null ? null : LazyCounterWidget(lazyCounter),
          ),
        ),
      );
}
