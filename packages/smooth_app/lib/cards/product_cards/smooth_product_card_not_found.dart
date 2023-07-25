import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_base_card.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/product/add_new_product_page.dart';

class SmoothProductCardNotFound extends StatelessWidget {
  SmoothProductCardNotFound({
    required this.barcode,
    this.onAddProduct,
    this.onRemoveProduct,
  }) : assert(barcode.isNotEmpty);

  final Future<void> Function()? onAddProduct;
  final OnRemoveCallback? onRemoveProduct;
  final String barcode;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SmoothProductBaseCard(
      margin: const EdgeInsets.symmetric(
        vertical: VERY_SMALL_SPACE,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: ProductCardCloseButton(
              onRemove: (BuildContext context) {
                AnalyticsHelper.trackEvent(
                  AnalyticsEvent.ignoreProductNotFound,
                  barcode: barcode,
                );

                onRemoveProduct?.call(context);
              },
              iconData: CupertinoIcons.clear_circled,
            ),
          ),
          Expanded(
            flex: 2,
            child: AutoSizeText(
              appLocalizations.missing_product,
              style: textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: AutoSizeText(
              '\n${appLocalizations.add_product_take_photos}\n'
              '(${appLocalizations.barcode_barcode(barcode)})',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          SmoothLargeButtonWithIcon(
            text: appLocalizations.add_product_information_button_label,
            icon: Icons.add,
            padding: const EdgeInsets.symmetric(vertical: LARGE_SPACE),
            onPressed: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      AddNewProductPage.fromBarcode(barcode),
                ),
              );

              await onAddProduct?.call();
            },
          ),
        ],
      ),
    );
  }
}
