import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/price_existing_amount_field.dart';
import 'package:smooth_app/pages/prices/price_l10n_helper.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/price_product_list_tile.dart';

/// Card that displays an existing amount.
class PriceExistingAmountCard extends StatefulWidget {
  const PriceExistingAmountCard(this.price);

  final Price price;

  @override
  State<PriceExistingAmountCard> createState() =>
      _PriceExistingAmountCardState();
}

class _PriceExistingAmountCardState extends State<PriceExistingAmountCard> {
  final PriceL10nHelper _helper = PriceL10nHelper();

  @override
  void initState() {
    super.initState();
    _helper.localizeTags(widget.price, () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool isDiscounted = widget.price.priceIsDiscounted ?? false;
    final String? category = _helper.getCategory();
    final List<String>? origins = _helper.getOrigins();
    final List<String>? labels = _helper.getLabels();
    final List<String> subtitle = <String>[];
    if (origins != null) {
      subtitle.addAll(origins);
    }
    if (labels != null) {
      subtitle.addAll(labels);
    }
    return SmoothCardWithRoundedHeader(
      title: appLocalizations.prices_amount_existing_subtitle,
      leading: const Icon(Icons.history),
      contentPadding: const EdgeInsetsDirectional.symmetric(
        vertical: MEDIUM_SPACE,
        horizontal: SMALL_SPACE,
      ),
      child: Column(
        children: <Widget>[
          if (widget.price.product != null)
            PriceProductListTile(
              product: PriceMetaProduct.priceProduct(widget.price.product!),
            ),
          if (category != null || subtitle.isNotEmpty)
            ListTile(
              title: category == null ? null : Text(category),
              subtitle: subtitle.isEmpty ? null : Text(subtitle.join(', ')),
            ),
          SwitchListTile(
            value: isDiscounted,
            onChanged: null,
            title: Text(appLocalizations.prices_amount_is_discounted),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: SMALL_SPACE),
          Row(
            children: <Widget>[
              Expanded(
                child: PriceExistingAmountField(
                  value: widget.price.price,
                  pricePer: widget.price.pricePer,
                ),
              ),
              const SizedBox(width: LARGE_SPACE),
              Expanded(
                child: !isDiscounted
                    ? Container()
                    : PriceExistingAmountField(
                        value: widget.price.priceWithoutDiscount,
                        pricePer: widget.price.pricePer,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
