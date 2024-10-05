import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_button.dart';
import 'package:smooth_app/pages/prices/prices_page.dart';
import 'package:smooth_app/query/product_query.dart';

/// Widget that displays a user, for Prices.
class PriceUserButton extends StatelessWidget {
  const PriceUserButton(this.user);

  final String user;

  static String showUserTitle({
    required final String user,
    required final BuildContext context,
  }) =>
      user == ProductQuery.getWriteUser().userId
          ? AppLocalizations.of(context).user_search_prices_title
          : AppLocalizations.of(context).user_any_search_prices_title;

  static Future<void> showUserPrices({
    required final String user,
    required final BuildContext context,
  }) async =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => PricesPage(
            GetPricesModel(
              parameters: GetPricesParameters()
                ..owner = user
                ..orderBy = <OrderBy<GetPricesOrderField>>[
                  const OrderBy<GetPricesOrderField>(
                    field: GetPricesOrderField.created,
                    ascending: false,
                  ),
                ]
                ..pageSize = GetPricesModel.pageSize
                ..pageNumber = 1,
              displayOwner: false,
              displayProduct: true,
              uri: OpenPricesAPIClient.getUri(
                path: 'users/$user',
                uriHelper: ProductQuery.uriPricesHelper,
              ),
              title: showUserTitle(user: user, context: context),
              subtitle: user,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => PriceButton(
        tooltip: AppLocalizations.of(context).prices_open_user_proofs(user),
        title: user,
        iconData: Icons.account_box,
        onPressed: () async => showUserPrices(
          user: user,
          context: context,
        ),
      );
}
