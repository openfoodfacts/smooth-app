import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/prices/price_amount_field.dart';
import 'package:smooth_app/pages/prices/price_amount_model.dart';
import 'package:smooth_app/pages/prices/price_product_list_tile.dart';

/// Card that displays the amounts (discounted or not) for price adding.
class PriceAmountCard extends StatefulWidget {
  const PriceAmountCard(this.model);

  final PriceAmountModel model;

  @override
  State<PriceAmountCard> createState() => _PriceAmountCardState();
}

class _PriceAmountCardState extends State<PriceAmountCard> {
  final TextEditingController _controllerPaid = TextEditingController();
  final TextEditingController _controllerWithoutDiscount =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothCard(
      child: Column(
        children: <Widget>[
          Text(appLocalizations.prices_amount_subtitle),
          PriceProductListTile(
            product: widget.model.product,
          ),
          SmoothLargeButtonWithIcon(
            icon: widget.model.promo
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            text: appLocalizations.prices_amount_is_discounted,
            onPressed: () => setState(
              () => widget.model.promo = !widget.model.promo,
            ),
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
                  model: widget.model,
                ),
              );
              if (!widget.model.promo) {
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
                  model: widget.model,
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
