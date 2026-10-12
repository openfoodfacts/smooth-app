import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/pages/onboarding/currency_selector_helper.dart';
import 'package:smooth_app/pages/prices/currency_extension.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

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
          : () async => openSelector(context: context),
      text: model.currency.getFullName(),
      leadingIcon: Icon(_helper.currencyIconData),
      trailingIcon: const icons.Chevron.right(size: 10.0),
    );
  }

  static Future<void> openSelector({required BuildContext context}) async {
    final PriceModel model = context.read<PriceModel>();

    final CurrencySelectorHelper helper = CurrencySelectorHelper();
    final Currency? currency = await helper.openCurrencySelector(
      context: context,
      selected: model.currency,
    );

    if (currency != null) {
      model.currency = currency;
    }
  }
}
