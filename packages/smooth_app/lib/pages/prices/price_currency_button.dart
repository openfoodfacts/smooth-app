import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/currency_extension.dart';
import 'package:smooth_app/pages/prices/price_currency_selector.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class PriceCurrencyButton extends StatelessWidget {
  const PriceCurrencyButton();

  /// Custom radius due to the [SmoothCardWithRoundedHeader] internal padding
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(16.0));

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
        borderRadius: _radius,
        child: Tooltip(
          message: AppLocalizations.of(context).prices_amount_update_currency,
          child: InkWell(
            borderRadius: _radius,
            onTap: () async =>
                PriceCurrencySelector.openSelector(context: context),
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                start: MEDIUM_SPACE,
                end: BALANCED_SPACE,
                top: BALANCED_SPACE,
                bottom: BALANCED_SPACE,
              ),
              child: icons.AppIconTheme(
                color: color,
                child: Row(
                  children: <Widget>[
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
