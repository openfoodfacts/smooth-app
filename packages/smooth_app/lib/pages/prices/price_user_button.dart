import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/lazy_counter.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/prices_page.dart';
import 'package:smooth_app/query/product_query.dart';

/// Helper methods for displaying a user, for Prices.
class PriceUserButton {
  const PriceUserButton._();

  static String showUserTitle({
    required final String user,
    required final BuildContext context,
  }) => user == ProductQuery.getWriteUser().userId
      ? AppLocalizations.of(context).user_search_prices_title
      : AppLocalizations.of(context).user_any_search_prices_title(user);

  static Future<void> showUserPrices({
    required final String user,
    required final BuildContext context,
  }) async => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) => PricesPage(
        GetPricesModel(
          parameters: GetPricesModel.getStandardPricesParameters()
            ..owner = user,
          displayEachOwner: false,
          uri: OpenPricesAPIClient.getUri(
            path: 'users/$user',
            uriHelper: ProductQuery.uriPricesHelper,
          ),
          title: showUserTitle(user: user, context: context),
          subtitle: user,
          lazyCounterPrices: LazyCounterPrices(user),
        ),
      ),
    ),
  );
}
