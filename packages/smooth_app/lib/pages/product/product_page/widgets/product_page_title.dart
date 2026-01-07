import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class ProductPageTitle extends StatelessWidget {
  const ProductPageTitle({required this.label, this.trailing, super.key});

  final String label;
  final WidgetBuilder? trailing;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension themeExtension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return Semantics(
      explicitChildNodes: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: lightTheme
              ? themeExtension.primaryMedium
              : themeExtension.primarySemiDark,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
          ),
          child: SizedBox(
            width: double.infinity,
            child: Row(
              children: <Widget>[
                const SizedBox(width: 21.5),
                SmoothModalSheetHeaderPrefixIndicator(
                  color: lightTheme
                      ? themeExtension.primaryUltraBlack
                      : themeExtension.primaryLight,
                ),
                const SizedBox(width: 18.5),
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: lightTheme
                          ? themeExtension.primaryUltraBlack
                          : themeExtension.primaryLight,
                    ),
                  ),
                ),
                if (trailing != null) trailing!.call(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
