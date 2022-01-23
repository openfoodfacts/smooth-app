import 'package:flutter/material.dart';

class SmoothSimpleButton extends StatelessWidget {
  const SmoothSimpleButton({
    required this.text,
    required this.onPressed,
    this.minWidth = 15,
    this.height = 20,
    this.borderRadius = const BorderRadius.all(Radius.circular(15.0)),
    this.padding = const EdgeInsets.all(10),
    this.buttonColor,
    this.textColor,
    this.icon,
  });

  final String text;
  final VoidCallback onPressed;
  final double minWidth;
  final double height;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final Color? buttonColor;
  final Color? textColor;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return MaterialButton(
      color: buttonColor ?? themeData.colorScheme.primary,
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if (icon != null) icon!,
            const Spacer(),
            Text(
              text,
              textAlign: TextAlign.center,
              style: themeData.textTheme.bodyText2!.copyWith(
                color: textColor ?? themeData.colorScheme.onPrimary,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
      height: height,
      minWidth: minWidth,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      onPressed: () => onPressed(),
    );
  }
}
