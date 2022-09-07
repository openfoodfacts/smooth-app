import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/product/add_new_product_page.dart';

class SmoothProductCardNotFound extends StatelessWidget {
  const SmoothProductCardNotFound({
    required this.barcode,
    this.callback,
    this.elevation = 0.0,
  });

  final Function(String?)? callback;
  final double elevation;
  final String barcode;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final EdgeInsets padding = EdgeInsets.symmetric(
        vertical: constraints.maxHeight * 0.10,
        horizontal: constraints.maxWidth * 0.05,
      );

      final TextTheme textTheme = Theme.of(context).textTheme;

      return SmoothCard(
        elevation: elevation,
        color: themeData.brightness == Brightness.light
            ? Colors.white
            : Colors.black,
        padding: padding,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: constraints.maxWidth - padding.horizontal,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: themeData.textTheme.headline5,
                    children: <TextSpan>[
                      TextSpan(
                        text: appLocalizations.missing_product,
                        style: textTheme.headline2,
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
          ),
        ),
      );
    });
  }
}
