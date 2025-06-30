import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class SmoothLargeButtonWithIcon extends StatelessWidget {
  const SmoothLargeButtonWithIcon({
    required this.text,
    required this.onPressed,
    this.padding,
    this.leadingIcon,
    this.trailingIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.textAlign,
    this.textStyle,
    this.borderRadius,
    this.elevation,
  });

  final String text;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextAlign? textAlign;
  final TextStyle? textStyle;
  final BorderRadiusGeometry? borderRadius;
  final WidgetStateProperty<double?>? elevation;

  Color _getBackgroundColor(final ThemeData themeData) =>
      backgroundColor ?? themeData.colorScheme.secondary;

  Color _getForegroundColor(final ThemeData themeData) =>
      foregroundColor ?? themeData.colorScheme.onSecondary;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    TextStyle style = textStyle ?? themeData.textTheme.bodyMedium!;

    if (foregroundColor != null) {
      style = style.copyWith(color: _getForegroundColor(themeData));
    }

    return SmoothSimpleButton(
      minWidth: double.infinity,
      padding: padding ?? const EdgeInsets.all(BALANCED_SPACE),
      onPressed: onPressed,
      elevation: elevation,
      borderRadius: borderRadius ?? ROUNDED_BORDER_RADIUS,
      buttonColor: _getBackgroundColor(themeData),
      child: IconTheme(
        data: IconThemeData(color: _getForegroundColor(themeData)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if (leadingIcon != null) ...<Widget>[
              leadingIcon!,
              const SizedBox(width: BALANCED_SPACE),
            ],
            Expanded(
              child: AutoSizeText(
                text,
                maxLines: 3,
                minFontSize: 10,
                textAlign: textAlign,
                style: style,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailingIcon != null) ...<Widget>[
              const SizedBox(width: BALANCED_SPACE),
              trailingIcon!,
            ],
          ],
        ),
      ),
    );
  }
}
