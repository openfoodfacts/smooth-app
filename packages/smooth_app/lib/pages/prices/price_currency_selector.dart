import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/pages/onboarding/currency_selector_helper.dart';
import 'package:smooth_app/pages/prices/currency_extension.dart';
import 'package:smooth_app/pages/prices/price_model.dart';

/// Button that displays the currency for price adding.
class PriceCurrencySelector extends StatelessWidget {
  PriceCurrencySelector();

  final CurrencySelectorHelper _helper = CurrencySelectorHelper();

  @override
  Widget build(BuildContext context) {
    final PriceModel model = context.watch<PriceModel>();
    return SmoothLargeButtonWithIcon(
      onPressed: model.proof != null
          ? null
          : () async {
              final Currency? currency = await _helper.openCurrencySelector(
                context: context,
                selected: model.currency,
              );
              if (currency == null) {
                return;
              }
              if (!context.mounted) {
                return;
              }
              model.currency = currency;
            },
      text: model.currency.getFullName(),
      leadingIcon: Icon(_helper.currencyIconData),
    );
  }
}
