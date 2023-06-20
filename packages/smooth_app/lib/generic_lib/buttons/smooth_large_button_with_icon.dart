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
  });

  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;
  final IconData? trailing;
  final Color? backgroundColor;
  final Color? foregroundColor;

  Color _getBackgroundColor(final ThemeData themeData) =>
      backgroundColor ?? themeData.colorScheme.secondary;

  Color _getForegroundColor(final ThemeData themeData) =>
      foregroundColor ?? themeData.colorScheme.onSecondary;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
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
              maxLines: 2,
              textAlign: TextAlign.center,
              style: themeData.textTheme.bodyMedium!.copyWith(
                color: _getForegroundColor(themeData),
              ),
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
