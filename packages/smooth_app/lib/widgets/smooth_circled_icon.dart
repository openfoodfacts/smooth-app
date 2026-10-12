import 'package:flutter/material.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SmoothCircledIcon extends StatelessWidget {
  const SmoothCircledIcon({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.borderColor,
    this.backgroundColor,
    this.padding,
    super.key,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    return Tooltip(
      message: tooltip,
      // 34 = Half the height (48 / 2) + 10
      verticalOffset: 34.0,
      preferBelow: true,
      enableFeedback: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Ink(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor ?? theme.primaryBlack,
                width: 1.0,
              ),
              color:
                  backgroundColor ??
                  (context.lightTheme()
                      ? theme.primaryLight
                      : theme.primaryDark),
            ),
            padding: padding ?? const EdgeInsetsDirectional.all(12.0),
            child: icon,
          ),
        ),
      ),
    );
  }
}

class CloseCircledIcon extends StatelessWidget {
  const CloseCircledIcon({this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SmoothCircledIcon(
      icon: const icons.Close(size: 20.0),
      onPressed:
          onPressed ??
          () {
            Navigator.of(context).maybePop();
          },
      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
    );
  }
}

class CircledTextIcon extends StatelessWidget {
  const CircledTextIcon({
    required this.icon,
    required this.text,
    required this.tooltip,
    this.onPressed,
    this.borderColor,
    this.backgroundColor,
    this.padding,
    super.key,
  });

  final Widget icon;
  final Widget text;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return Semantics(
      value: tooltip,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20.0),
          child: Ink(
            height: 48.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: borderColor ?? theme.primaryBlack,
                width: 1.0,
              ),
              color:
                  backgroundColor ??
                  (lightTheme ? theme.primaryLight : theme.primaryDark),
            ),
            padding:
                padding ??
                const EdgeInsetsDirectional.symmetric(
                  horizontal: 14.0,
                  vertical: 12.0,
                ),
            child: DefaultTextStyle(
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: IconTheme.of(context).color,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  icon,
                  const SizedBox(width: 16.0),
                  // Fake padding to have a better UI
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0.5),
                    child: text,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
