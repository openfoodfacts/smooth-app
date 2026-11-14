import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/discount_type_extension.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class PriceDiscountTypeSelector extends StatelessWidget {
  const PriceDiscountTypeSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final DiscountType? value;
  final ValueChanged<DiscountType?> onChanged;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return TextButton(
      onPressed: () => _showDiscountMenu(context),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(
          theme.primarySemiDark,
        ),
        padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsetsDirectional.symmetric(
            vertical: SMALL_SPACE,
            horizontal: LARGE_SPACE,
          ),
        ),
        shape: const WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: CIRCULAR_BORDER_RADIUS),
        ),
      ),
      child: Row(
        spacing: MEDIUM_SPACE,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 3.0),
              child: Text(
                value?.getTitle(appLocalizations) ??
                    appLocalizations.prices_discount_type,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const icons.Chevron.down(),
        ],
      ),
    );
  }

  Future<void> _showDiscountMenu(BuildContext context) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final DiscountType? discountType =
        await showSmoothListOfChoicesModalSheet<DiscountType>(
          context: context,
          title: appLocalizations.prices_discount_type,
          labels: DiscountType.values
              .map(
                (DiscountType discount) => discount.getTitle(appLocalizations),
              )
              .toList(growable: false),

          subtitles: DiscountType.values
              .map(
                (DiscountType discount) =>
                    discount.getSubtitle(appLocalizations),
              )
              .toList(growable: false),
          prefixIcons: DiscountType.values
              .map(
                (DiscountType discount) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    borderRadius: ANGULAR_BORDER_RADIUS,
                  ),
                  child: SizedBox.square(
                    dimension: 42.0,
                    child: Icon(
                      discount.iconData,
                      size: 22.0,
                      color: colorScheme.onSecondary,
                    ),
                  ),
                ),
              )
              .toList(growable: false),
          contentPadding: const EdgeInsetsDirectional.symmetric(
            horizontal: LARGE_SPACE,
            vertical: VERY_SMALL_SPACE,
          ),
          values: DiscountType.values,
        );

    if (!context.mounted || discountType == null) {
      return;
    }

    onChanged.call(discountType);
  }
}
