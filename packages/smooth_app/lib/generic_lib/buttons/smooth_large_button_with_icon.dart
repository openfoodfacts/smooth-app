import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';

class SmoothLargeButtonWithIcon extends StatelessWidget {
  const SmoothLargeButtonWithIcon({
    required this.text,
    required this.icon,
    required this.onPressed,
    this.padding,
    this.trailing,
    this.backgroundColor,
    this.foregroundColor,
    this.textAlign,
    this.textStyle,
  });

  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final IconData? trailing;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextAlign? textAlign;
  final TextStyle? textStyle;

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
      padding: padding ?? const EdgeInsets.all(10),
      onPressed: onPressed,
      buttonColor: _getBackgroundColor(themeData),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            color: _getForegroundColor(themeData),
          ),
          const Spacer(),
          Expanded(
            flex: 10,
            child: AutoSizeText(
              text,
              maxLines: 3,
              minFontSize: 10,
              textAlign: textAlign,
              style: style,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          if (trailing != null)
            Icon(
              trailing,
              color: _getForegroundColor(themeData),
            ),
        ],
      ),
    );
  }
}
