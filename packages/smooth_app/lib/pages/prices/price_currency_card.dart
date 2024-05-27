import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/prices/price_currency_selector.dart';

/// Card that displays the currency for price adding.
class PriceCurrencyCard extends StatelessWidget {
  const PriceCurrencyCard();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothCard(
      child: Column(
        children: <Widget>[
          Text(appLocalizations.prices_currency_subtitle),
          PriceCurrencySelector(),
        ],
      ),
    );
  }
}
