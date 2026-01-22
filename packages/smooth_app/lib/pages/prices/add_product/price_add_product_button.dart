import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/add_product/price_add_product_action.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class PriceAddProductButton extends StatelessWidget {
  const PriceAddProductButton({super.key});

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return FloatingActionButton(
      tooltip: appLocalizations.prices_add_an_item,
      shape: const CircleBorder(),
      onPressed: () async => _onPressed(context, appLocalizations),
      backgroundColor: theme.secondaryVibrant,
      child: const icons.Add.circled(color: Colors.white),
    );
  }

  Future<void> _onPressed(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) async {
    final List<PriceAddProductAction> options = priceAddProductActions;

    final PriceAddProductAction? option =
        await showSmoothListOfChoicesModalSheet<PriceAddProductAction>(
          context: context,
          title: appLocalizations.prices_add_an_item,
          labels: options.map(
            (final PriceAddProductAction option) =>
                option.label(appLocalizations),
          ),
          values: options,
          prefixIcons: options.map(
            (final PriceAddProductAction option) => IconTheme.merge(
              data: const IconThemeData(size: 24.0),
              child: option.icon(context),
            ),
          ),
          safeArea: true,
        );

    if (option == null || !context.mounted) {
      return;
    }

    return option.execute(context);
  }
}
