import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/currency_extension.dart';
import 'package:smooth_app/pages/prices/price_amount_field.dart';
import 'package:smooth_app/pages/prices/price_amount_model.dart';
import 'package:smooth_app/pages/prices/price_currency_selector.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/prices/price_per_extension.dart';
import 'package:smooth_app/pages/prices/price_product_list_tile.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_dropdown.dart';

/// Card that displays the amounts (discounted or not) for price adding.
class PriceAmountCard extends StatefulWidget {
  const PriceAmountCard({required this.index, required super.key});

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
    _controllerWithoutDiscount = TextEditingController(
      text: model.priceWithoutDiscount,
    );
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

    return SmoothCardWithRoundedHeader(
      title:
          '${appLocalizations.prices_amount_subtitle}'
          '${total == 1 ? '' : ' (${widget.index + 1}/$total)'}',
      leading: const Icon(Icons.calculate_rounded),
      trailing: const _PriceAmountCurrencyButton(),
      contentPadding: const EdgeInsetsDirectional.symmetric(
        vertical: MEDIUM_SPACE,
        horizontal: SMALL_SPACE,
      ),
      child: Column(
        children: <Widget>[
          PriceProductListTile(
            product: model.product,
            trailing: total == 1
                ? null
                : InkWell(
                    onTap: () => priceModel.removeAt(widget.index),
                    child: const Icon(Icons.clear),
                  ),
          ),
          if (model.product.categoryTag.isNotEmpty)
            const SizedBox(height: SMALL_SPACE),
          if (model.product.categoryTag.isNotEmpty)
            SmoothDropdownButton<PricePer>(
              isExpanded: true,
              value: model.product.pricePer,
              items: PricePer.values
                  .map(
                    (final PricePer pricePer) => SmoothDropdownItem<PricePer>(
                      value: pricePer,
                      label: pricePer.getTitle(appLocalizations),
                    ),
                  )
                  .toList(),
              onChanged: (final PricePer? value) {
                if (value == null) {
                  return;
                }
                model.product.pricePer = value;
              },
            ),
          SwitchListTile(
            value: model.promo,
            onChanged: (final bool value) =>
                setState(() => model.promo = !model.promo),
            title: Text(appLocalizations.prices_amount_is_discounted),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
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

class _PriceAmountCurrencyButton extends StatelessWidget {
  const _PriceAmountCurrencyButton();

  @override
  Widget build(BuildContext context) {
    final PriceModel model = context.watch<PriceModel>();

    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final Color color = context.lightTheme()
        ? extension.primaryBlack
        : extension.primaryUltraBlack;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: VERY_SMALL_SPACE,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: ROUNDED_BORDER_RADIUS,
        child: Tooltip(
          message: AppLocalizations.of(context).prices_amount_update_currency,
          child: InkWell(
            borderRadius: ROUNDED_BORDER_RADIUS,
            onTap: () async =>
                PriceCurrencySelector.openSelector(context: context),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: BALANCED_SPACE,
                vertical: BALANCED_SPACE,
              ),
              child: icons.AppIconTheme(
                color: color,
                child: Row(
                  children: <Widget>[
                    const icons.Currency(),
                    const SizedBox(width: SMALL_SPACE),
                    Text(
                      model.currency.getFullName(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: LARGE_SPACE),
                    const icons.Chevron.down(size: 10.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
