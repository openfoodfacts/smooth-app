import 'package:material_ui/material_ui.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

// Centers the glyph of the arrow font inside its circle.
const EdgeInsetsDirectional _ARROW_PADDING = EdgeInsetsDirectional.only(
  start: 6.0,
  end: 6.0,
  top: 6.5,
  bottom: 7.5,
);

class CurrencyChangeSummary extends StatelessWidget {
  const CurrencyChangeSummary({
    required this.currency,
    required this.newCurrency,
  });

  final String currency;
  final String newCurrency;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();
    final Color chipColor = lightTheme
        ? extension.primaryMedium
        : extension.primarySemiDark;

    return Semantics(
      label: AppLocalizations.of(context)
          .currency_change_sheet_summary_semantics(currency, newCurrency),
      excludeSemantics: true,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: MEDIUM_SPACE,
        runSpacing: SMALL_SPACE,
        children: <Widget>[
          _CurrencyChip(code: currency, color: chipColor),
          if (Directionality.of(context) == TextDirection.rtl)
            icons.CircledArrow.left(
              type: icons.CircledArrowType.normal,
              color: Colors.white,
              circleColor: extension.secondaryVibrant,
              size: 24.0,
              padding: _ARROW_PADDING,
            )
          else
            icons.CircledArrow.right(
              type: icons.CircledArrowType.normal,
              color: Colors.white,
              circleColor: extension.secondaryVibrant,
              size: 24.0,
              padding: _ARROW_PADDING,
            ),
          _CurrencyChip(code: newCurrency, color: chipColor),
        ],
      ),
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  const _CurrencyChip({required this.code, required this.color});

  final String code;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: CIRCULAR_BORDER_RADIUS,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: VERY_LARGE_SPACE * 1.5,
          vertical: SMALL_SPACE,
        ),
        child: Text(code, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
