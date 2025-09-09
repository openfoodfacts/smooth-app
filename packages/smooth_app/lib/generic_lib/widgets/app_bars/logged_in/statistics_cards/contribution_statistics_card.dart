import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_in/statistics_cards/app_bar_statistics_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/lazy_counter.dart';
import 'package:smooth_app/query/paged_user_product_query.dart';

class ContributionStatisticsCard extends StatelessWidget {
  const ContributionStatisticsCard({this.autoSizeGroup, super.key});

  final AutoSizeGroup? autoSizeGroup;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return AppBarStatisticsCard(
      imagePath: 'assets/preferences/ingredients.svg',
      description: appLocalizations.preferences_app_bar_products_modified,
      lazyCounter: const LazyCounterUserSearch(UserSearchType.CONTRIBUTOR),
      autoSizeGroup: autoSizeGroup,
    );
  }
}
