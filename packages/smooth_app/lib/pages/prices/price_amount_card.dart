import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/prices/price_amount_field.dart';
import 'package:smooth_app/pages/prices/price_amount_model.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/prices/price_product_list_tile.dart';

/// Card that displays the amounts (discounted or not) for price adding.
class PriceAmountCard extends StatefulWidget {
  const PriceAmountCard({
    required this.index,
    required super.key,
  });

  final int index;

  @override
  State<PriceAmountCard> createState() => _PriceAmountCardState();
}

class _PriceAmountCardState extends State<PriceAmountCard> {
  late final TextEditingController _controllerPaid;
  late final TextEditingController _controllerWithoutDiscount;

  @override
  void initState() {
    super.initState();
    final PriceAmountModel model = Provider.of<PriceModel>(
      context,
      listen: false,
    ).elementAt(widget.index);
    _controllerPaid = TextEditingController(text: model.paidPrice);
    _controllerWithoutDiscount =
        TextEditingController(text: model.priceWithoutDiscount);
  }

  @override
  void dispose() {
    _controllerPaid.dispose();
    _controllerWithoutDiscount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final PriceModel priceModel = Provider.of<PriceModel>(context);
    final PriceAmountModel model = priceModel.elementAt(widget.index);
    final int total = priceModel.length;

    return SmoothCard(
      child: Column(
        children: <Widget>[
          Text(
            '${appLocalizations.prices_amount_subtitle}'
            '${total == 1 ? '' : ' (${widget.index + 1}/$total)'}',
          ),
          PriceProductListTile(
            product: model.product,
            trailingIconData: total == 1 ? null : Icons.clear,
            onPressed:
                total == 1 ? null : () => priceModel.removeAt(widget.index),
          ),
          SmoothLargeButtonWithIcon(
            icon: model.promo ? Icons.check_box : Icons.check_box_outline_blank,
            text: appLocalizations.prices_amount_is_discounted,
            onPressed: () => setState(
              () => model.promo = !model.promo,
            ),
          ),
          const SizedBox(height: SMALL_SPACE),
          Row(
            children: <Widget>[
              Expanded(
                child: PriceAmountField(
                  controller: _controllerPaid,
                  isPaidPrice: true,
                  model: model,
                ),
              ),
              const SizedBox(width: LARGE_SPACE),
              Expanded(
                child: !model.promo
                    ? Container()
                    : PriceAmountField(
                        controller: _controllerWithoutDiscount,
                        isPaidPrice: false,
                        model: model,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
