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
  const PriceAmountCard({
    required this.priceModel,
    required this.index,
    required this.refresh,
    this.focusNode,
    super.key,
  });

  final PriceModel priceModel;
  final int index;
  // TODO(monsieurtanuki): not elegant, the display was not refreshed when removing an item
  final VoidCallback refresh;
  final FocusNode? focusNode;

  @override
  State<PriceAmountCard> createState() => _PriceAmountCardState();
}

class _PriceAmountCardState extends State<PriceAmountCard> {
  late final TextEditingController _controllerPaid;
  late final TextEditingController _controllerWithoutDiscount;

  @override
  void initState() {
    super.initState();
    _controllerPaid = TextEditingController(text: _model.paidPrice);
    _controllerWithoutDiscount =
        TextEditingController(text: _model.priceWithoutDiscount);
  }

  @override
  void dispose() {
    _controllerPaid.dispose();
    _controllerWithoutDiscount.dispose();
    super.dispose();
  }

  PriceAmountModel get _model =>
      widget.priceModel.priceAmountModels[widget.index];
  int get _total => widget.priceModel.priceAmountModels.length;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool isEmpty = _model.product.barcode.isEmpty;
    return SmoothCard(
      child: Column(
        children: <Widget>[
          Text(
            '${appLocalizations.prices_amount_subtitle}'
            '${_total == 1 ? '' : ' (${widget.index + 1}/$_total)'}',
          ),
          PriceProductListTile(
            product: _model.product,
            trailingIconData: isEmpty
                ? Icons.edit
                : _total == 1
                    ? null
                    : Icons.clear,
            onPressed: isEmpty
                ? () async {
                    final PriceMetaProduct? product =
                        await Navigator.of(context).push<PriceMetaProduct>(
                      MaterialPageRoute<PriceMetaProduct>(
                        builder: (BuildContext context) =>
                            PriceProductSearchPage(
                          barcodes: widget.priceModel.getBarcodes(),
                        ),
                      ),
                    );
                    if (product == null) {
                      return;
                    }
                    _model.product = product;
                    widget.refresh.call();
                  }
                : _total == 1
                    ? null
                    : () {
                        widget.priceModel.priceAmountModels
                            .removeAt(widget.index);
                        widget.refresh.call();
                      },
          ),
          SmoothLargeButtonWithIcon(
            icon:
                _model.promo ? Icons.check_box : Icons.check_box_outline_blank,
            text: appLocalizations.prices_amount_is_discounted,
            onPressed: () => setState(
              () => _model.promo = !_model.promo,
            ),
          ),
          const SizedBox(height: SMALL_SPACE),
          Row(
            children: <Widget>[
              Expanded(
                child: PriceAmountField(
                  focusNode: widget.focusNode,
                  controller: _controllerPaid,
                  isPaidPrice: true,
                  model: _model,
                ),
              ),
              const SizedBox(width: LARGE_SPACE),
              Expanded(
                child: !_model.promo
                    ? Container()
                    : PriceAmountField(
                        controller: _controllerWithoutDiscount,
                        isPaidPrice: false,
                        model: _model,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
