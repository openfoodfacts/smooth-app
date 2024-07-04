import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/prices/price_amount_field.dart';
import 'package:smooth_app/pages/prices/price_amount_model.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/prices/price_product_list_tile.dart';
import 'package:smooth_app/pages/prices/price_product_search_page.dart';

/// Card that displays the amounts (discounted or not) for price adding.
class PriceAmountCard extends StatefulWidget {
  PriceAmountCard({
    required this.priceModel,
    required this.index,
    required this.refresh,
  })  : model = priceModel.priceAmountModels[index],
        total = priceModel.priceAmountModels.length;

  final PriceModel priceModel;
  final PriceAmountModel model;
  final int index;
  final int total;
  // TODO(monsieurtanuki): not elegant, the display was not refreshed when removing an item
  final VoidCallback refresh;

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
    final bool isEmpty = widget.model.product.barcode.isEmpty;
    return SmoothCard(
      child: Column(
        children: <Widget>[
          Text(
            '${appLocalizations.prices_amount_subtitle}'
            '${widget.total == 1 ? '' : ' (${widget.index + 1}/${widget.total})'}',
          ),
          PriceProductListTile(
            product: widget.model.product,
            trailingIconData: isEmpty
                ? Icons.edit
                : widget.total == 1
                    ? null
                    : Icons.clear,
            onPressed: isEmpty
                ? () async {
                    final PriceMetaProduct? product =
                        await Navigator.of(context).push<PriceMetaProduct>(
                      MaterialPageRoute<PriceMetaProduct>(
                        builder: (BuildContext context) =>
                            const PriceProductSearchPage(),
                      ),
                    );
                    if (product == null) {
                      return;
                    }
                    setState(() => widget.model.product = product);
                  }
                : widget.total == 1
                    ? null
                    : () {
                        widget.priceModel.priceAmountModels
                            .removeAt(widget.index);
                        widget.refresh.call();
                      },
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
          Row(
            children: <Widget>[
              Expanded(
                child: PriceAmountField(
                  controller: _controllerPaid,
                  isPaidPrice: true,
                  model: widget.model,
                ),
              ),
              const SizedBox(width: LARGE_SPACE),
              Expanded(
                child: !widget.model.promo
                    ? Container()
                    : PriceAmountField(
                        controller: _controllerWithoutDiscount,
                        isPaidPrice: false,
                        model: widget.model,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
