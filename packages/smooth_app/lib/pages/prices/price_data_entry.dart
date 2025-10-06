import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/text/dynamic_text.dart';

class PriceDataEntry extends StatelessWidget {
  const PriceDataEntry({
    required this.icon,
    required this.label,
    this.shortLabel,
    this.labelPadding,
    this.labelStyle,
  });

  final Widget icon;
  final String label;
  final String? shortLabel;
  final EdgeInsetsGeometry? labelPadding;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return Row(
      children: <Widget>[
        icon,
        const SizedBox(width: SMALL_SPACE),
        Expanded(
          child: Padding(
            padding: labelPadding ?? EdgeInsetsDirectional.zero,
            child: DefaultTextStyle.merge(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: lightTheme
                    ? extension.primaryBlack
                    : extension.primaryLight,
              ).merge(labelStyle),
              child: _child,
            ),
          ),
        ),
      ],
    );
  }

  Widget get _child {
    if (shortLabel == null) {
      return Text(label);
    } else {
      return SmoothDynamicLayout(
        replacement: Text(shortLabel!),
        child: Text(label),
      );
    }
  }
}
