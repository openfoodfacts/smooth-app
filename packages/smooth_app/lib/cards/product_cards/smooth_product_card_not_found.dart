import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_base_card.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
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
      child: Column(
        children: <Widget>[
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: ProductCardCloseButton(onRemove: onRemoveProduct),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: textTheme.headlineSmall,
                    children: <InlineSpan>[
                      TextSpan(
                        text: appLocalizations.missing_product,
                        style: textTheme.displayMedium,
                      ),
                      const WidgetSpan(
                        alignment: PlaceholderAlignment.belowBaseline,
                        baseline: TextBaseline.alphabetic,
                        child: SizedBox(
                          height: LARGE_SPACE,
                        ),
                      ),
                      TextSpan(
                        text: '\n${appLocalizations.add_product_take_photos}\n',
                        style: textTheme.bodyMedium,
                      ),
                      TextSpan(
                        text: '(${appLocalizations.barcode_barcode(barcode)})',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: LARGE_SPACE),
                  child: SmoothLargeButtonWithIcon(
                    text: appLocalizations.add_product_information_button_label,
                    icon: Icons.add,
                    padding: const EdgeInsets.symmetric(vertical: LARGE_SPACE),
                    onPressed: () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              AddNewProductPage(barcode: barcode),
                        ),
                      );

                      if (onAddProduct != null) {
                        await onAddProduct!();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
