import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/add_product/price_add_product_action.dart';

/// Card where the user can input a price product: type the barcode or scan.
class PriceAddProductCard extends StatelessWidget {
  const PriceAddProductCard();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothCardWithRoundedHeader(
      title: appLocalizations.prices_add_an_item,
      leading: const Icon(Icons.add_circle_outlined),
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: SMALL_SPACE,
        vertical: MEDIUM_SPACE,
      ),
      child: Column(
        children: priceAddProductActions
            .map(
              (final PriceAddProductAction action) => Padding(
                padding: const EdgeInsets.only(bottom: MEDIUM_SPACE),
                child: SmoothLargeButtonWithIcon(
                  text: action.label(appLocalizations),
                  leadingIcon: action.icon(context),
                  onPressed: () => action.execute(context),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
