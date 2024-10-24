import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/preferences/lazy_counter.dart';
import 'package:smooth_app/pages/preferences/lazy_counter_widget.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_user_button.dart';
import 'package:smooth_app/pages/prices/prices_page.dart';
import 'package:smooth_app/pages/prices/prices_proofs_page.dart';
import 'package:smooth_app/pages/prices/prices_users_page.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Home page of Prices
class PricesHomePage extends StatelessWidget {
  const PricesHomePage();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothScaffold(
      appBar: SmoothAppBar(
        centerTitle: false,
        leading: const SmoothBackButton(),
        title: Text(
          appLocalizations.prices_generic_title,
        ),
      ),
      body: ListView(
        children: <Widget>[
          _getListTile(
            title: PriceUserButton.showUserTitle(
              user: ProductQuery.getWriteUser().userId,
              context: context,
            ),
            onTap: () async => PriceUserButton.showUserPrices(
              user: ProductQuery.getWriteUser().userId,
              context: context,
            ),
            lazyCounter: LazyCounterPrices(ProductQuery.getWriteUser().userId),
          ),
          _getListTile(
            title: appLocalizations.user_search_proofs_title,
            onTap: () async => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const PricesProofsPage(
                  selectProof: false,
                ),
              ),
            ),
            trailingIconData: Icons.receipt,
          ),
          _getListTile(
            title: appLocalizations.prices_add_a_receipt,
            onTap: () async => ProductPriceAddPage.showProductPage(
              context: context,
              proofType: ProofType.receipt,
            ),
            trailingIconData: Icons.add_shopping_cart,
          ),
          _getListTile(
            title: appLocalizations.prices_add_price_tags,
            onTap: () async => ProductPriceAddPage.showProductPage(
              context: context,
              proofType: ProofType.priceTag,
            ),
            trailingIconData: Icons.add_shopping_cart,
          ),
          _getListTile(
            title: appLocalizations.all_search_prices_latest_title,
            onTap: () async => Navigator.of(context).push(
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
            lazyCounter: const LazyCounterPrices(null),
          ),
          _getListTile(
            title: appLocalizations.all_search_prices_top_user_title,
            onTap: () async => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const PricesUsersPage(),
              ),
            ),
            trailingIconData: ConstantIcons.instance.getForwardIcon(),
          ),
          _getListTile(
            title: appLocalizations.all_search_prices_top_location_title,
            onTap: () async => LaunchUrlHelper.launchURL(
              OpenPricesAPIClient.getUri(
                path: 'locations',
                uriHelper: ProductQuery.uriPricesHelper,
              ).toString(),
            ),
            trailingIconData: Icons.open_in_new,
          ),
          _getListTile(
            title: appLocalizations.all_search_prices_top_product_title,
            onTap: () async => LaunchUrlHelper.launchURL(
              OpenPricesAPIClient.getUri(
                path: 'products',
                uriHelper: ProductQuery.uriPricesHelper,
              ).toString(),
            ),
            trailingIconData: Icons.open_in_new,
          ),
        ],
      ),
    );
  }

  Widget _getListTile({
    required final String title,
    required final VoidCallback onTap,
    final IconData? trailingIconData,
    final LazyCounter? lazyCounter,
  }) =>
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: UserPreferencesListTile(
          title: Text(title),
          onTap: onTap,
          trailing: lazyCounter != null
              ? LazyCounterWidget(lazyCounter)
              : trailingIconData == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(trailingIconData),
                    ),
        ),
      );
}
