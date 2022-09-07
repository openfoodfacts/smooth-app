import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_base_card.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/product/add_new_product_page.dart';

class SmoothProductCardNotFound extends StatelessWidget {
  SmoothProductCardNotFound({
    required this.barcode,
    this.callback,
  }) : assert(barcode.isNotEmpty);

  final Future<void> Function(String?)? callback;
  final String barcode;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SmoothProductBaseCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: textTheme.headline5,
              children: <InlineSpan>[
                TextSpan(
                  text: appLocalizations.missing_product,
                  style: textTheme.headline2,
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
                  style: textTheme.bodyText2,
                ),
                TextSpan(
                  text: '(${appLocalizations.barcode_barcode(barcode)})',
                  style: textTheme.bodyText2,
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
                // TODO(monsieurtanuki): careful, waiting for pop'ed value
                final String? result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute<String>(
                    builder: (BuildContext context) =>
                        AddNewProductPage(barcode),
                  ),
                );
                if (callback != null) {
                  await callback!(result);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
