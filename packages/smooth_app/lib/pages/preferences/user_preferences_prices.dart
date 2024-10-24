import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/lazy_counter.dart';
import 'package:smooth_app/pages/preferences/lazy_counter_widget.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_user_button.dart';
import 'package:smooth_app/pages/prices/prices_page.dart';
import 'package:smooth_app/pages/prices/prices_proofs_page.dart';
import 'package:smooth_app/pages/prices/prices_users_page.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
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
                parameters: GetPricesParameters()
                  ..orderBy = <OrderBy<GetPricesOrderField>>[
                    const OrderBy<GetPricesOrderField>(
                      field: GetPricesOrderField.created,
                      ascending: false,
                    ),
                  ]
                  ..pageSize = GetPricesModel.pageSize
                  ..pageNumber = 1,
                displayOwner: true,
                displayProduct: true,
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
        Icons.account_box,
      ),
      _getPriceListTile(
        appLocalizations.all_search_prices_top_location_title,
        'locations',
      ),
      _getPriceListTile(
        appLocalizations.all_search_prices_top_product_title,
        'products',
      ),
    ];
  }

  UserPreferencesItem _getPriceListTile(
    final String title,
    final String path,
  ) =>
      _getListTile(
        title,
        () async => LaunchUrlHelper.launchURL(
          OpenPricesAPIClient.getUri(
            path: path,
            uriHelper: ProductQuery.uriPricesHelper,
          ).toString(),
        ),
        Icons.open_in_new,
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
