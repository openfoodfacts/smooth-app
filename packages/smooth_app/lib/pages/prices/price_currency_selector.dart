import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/pages/onboarding/currency_selector_helper.dart';
import 'package:smooth_app/pages/prices/currency_extension.dart';

/// Button that displays the currency for price adding.
class PriceCurrencySelector extends StatelessWidget {
  PriceCurrencySelector();

  final CurrencySelectorHelper helper = CurrencySelectorHelper();

  @override
  Widget build(BuildContext context) {
    // TODO(monsieurtanuki): use PriceModel for currency?
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final Currency selected = helper.getSelected(
      userPreferences.userCurrencyCode,
    );
    return SmoothLargeButtonWithIcon(
      onPressed: () async {
        final Currency? currency = await helper.openCurrencySelector(
          context: context,
          selected: selected,
        );
        if (currency != null) {
          await userPreferences.setUserCurrencyCode(currency.name);
        }
      },
      text: selected.getFullName(),
      icon: helper.currencyIconData,
    );
  }
}
