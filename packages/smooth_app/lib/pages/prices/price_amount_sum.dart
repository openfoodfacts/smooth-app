import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/pages/prices/price_amount_model.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class PriceAmountSum extends StatelessWidget {
  const PriceAmountSum({super.key});

  /// Custom radius due to the [SmoothCardWithRoundedHeader] internal padding
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(16.0));

  @override
  Widget build(BuildContext context) {
    final PriceModel model = context.watch<PriceModel>();

    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: ProductQuery.getLocaleString(),
      name: model.currency.name,
    );

    return Material(
      color: Colors.white,
      borderRadius: _radius,
      child: SizedBox(
        height: 25.0,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: BALANCED_SPACE,
          ),
          child: Row(
            spacing: SMALL_SPACE,
            children: <Widget>[
              const icons.Currency(),
              Center(
                child: MultipleChangeNotifierBuilder<PriceAmountModel>(
                  notifiers: model.priceAmountModels,
                  builder: (_, List<PriceAmountModel> models) {
                    return Text(
                      currencyFormat.format(_calculateTotalAmount(models)),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTotalAmount(List<PriceAmountModel> models) {
    double total = 0.0;

    for (final PriceAmountModel model in models) {
      total += double.tryParse(model.paidPrice.replaceAll(',', '.')) ?? 0.0;
    }

    return total;
  }
}
