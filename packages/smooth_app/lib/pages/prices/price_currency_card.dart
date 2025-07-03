import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/price_currency_selector.dart';

/// Card that displays the currency for price adding.
class PriceCurrencyCard extends StatelessWidget {
  const PriceCurrencyCard();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothCardWithRoundedHeader(
      title: appLocalizations.prices_currency_subtitle,
      leading: const Icon(Icons.price_change),
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: SMALL_SPACE,
        vertical: MEDIUM_SPACE,
      ),
      child: PriceCurrencySelector(),
    );
  }
}
