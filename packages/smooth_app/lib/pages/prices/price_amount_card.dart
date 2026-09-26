import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_sliver_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/price_amount_card_item.dart';
import 'package:smooth_app/pages/prices/price_model.dart';

/// Card that displays the amounts (discounted or not) for price adding.
class PriceAmountCard extends StatelessWidget {
  const PriceAmountCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final PriceModel model = Provider.of<PriceModel>(context);

    return SliverCardWithRoundedHeader(
      title: appLocalizations.prices_amount_subtitle,
      pinned: false,
      leading: const Icon(Icons.calculate_rounded),
      titlePadding: const EdgeInsetsDirectional.symmetric(
        vertical: BALANCED_SPACE,
        horizontal: LARGE_SPACE,
      ),
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: SMALL_SPACE,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: model.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (BuildContext context, int index) => Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: MEDIUM_SPACE,
          ),
          child: PriceAmountCardItem(
            index: index,
            key: Key('PriceAmountCardItem_$index'),
          ),
        ),
      ),
    );
  }
}
