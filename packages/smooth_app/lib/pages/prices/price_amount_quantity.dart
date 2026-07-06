import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

/// The number of items in the price amount list.
class PriceAmountQuantity extends StatelessWidget {
  const PriceAmountQuantity({super.key});

  /// Custom radius due to the [SmoothCardWithRoundedHeader] internal padding
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(16.0));

  @override
  Widget build(BuildContext context) {
    final PriceModel model = context.watch<PriceModel>();

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
            mainAxisSize: MainAxisSize.min,
            spacing: SMALL_SPACE,
            children: <Widget>[
              const icons.Ingredients.basket(),
              Text(
                model.length.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
