import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/prices/price_amount_field.dart';
import 'package:smooth_app/pages/prices/price_model.dart';

/// Card that displays the amounts (discounted or not) for price adding.
class PriceAmountCard extends StatefulWidget {
  const PriceAmountCard();

  @override
  State<PriceAmountCard> createState() => _PriceAmountCardState();
}

class _PriceAmountCardState extends State<PriceAmountCard> {
  final TextEditingController _controllerPaid = TextEditingController();
  final TextEditingController _controllerWithoutDiscount =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final PriceModel model = context.watch<PriceModel>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothCard(
      child: Column(
        children: <Widget>[
          Text(appLocalizations.prices_amount_subtitle),
          SmoothLargeButtonWithIcon(
            icon: model.promo ? Icons.check_box : Icons.check_box_outline_blank,
            text: appLocalizations.prices_amount_is_discounted,
            onPressed: () => model.promo = !model.promo,
          ),
          const SizedBox(height: SMALL_SPACE),
          LayoutBuilder(
            builder: (
              final BuildContext context,
              final BoxConstraints boxConstraints,
            ) {
              final double columnWidth =
                  (boxConstraints.maxWidth - LARGE_SPACE) / 2;
              final Widget columnPaid = SizedBox(
                width: columnWidth,
                child: PriceAmountField(
                  controller: _controllerPaid,
                  isPaidPrice: true,
                  model: model,
                ),
              );
              if (!model.promo) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: columnPaid,
                );
              }
              final Widget columnWithoutDiscount = SizedBox(
                width: columnWidth,
                child: PriceAmountField(
                  controller: _controllerWithoutDiscount,
                  isPaidPrice: false,
                  model: model,
                ),
              );
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  columnPaid,
                  columnWithoutDiscount,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
