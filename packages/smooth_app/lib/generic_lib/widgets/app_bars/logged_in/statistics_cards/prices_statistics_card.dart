import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_in/statistics_cards/app_bar_statistics_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/lazy_counter.dart';
import 'package:smooth_app/pages/prices/price_user_button.dart';
import 'package:smooth_app/widgets/autosize_text.dart';

class PricesStatisticsCard extends StatelessWidget {
  const PricesStatisticsCard({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return AppBarStatisticsCard(
      imagePath: 'assets/preferences/cash.svg.vec',
      description: appLocalizations.preferences_app_bar_prices_added,
      lazyCounter: LazyCounterPrices(userId),
      autoSizeGroup: context.read<AutoSizeGroup>(),
      onTap: () =>
          PriceUserButton.showUserPrices(user: userId, context: context),
    );
  }
}
