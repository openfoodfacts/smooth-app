import 'package:flutter/material.dart';

class SmoothSimpleButton extends StatelessWidget {
  const SmoothSimpleButton({
    required this.text,
    required this.onPressed,
    this.minWidth = 15,
    this.height = 20,
    this.important = true,
  });

  final String text;
  final VoidCallback onPressed;
  final double minWidth;
  final double height;
  final bool important;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return MaterialButton(
      color: themeData.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          text,
          style: themeData.textTheme.bodyText2!
              .copyWith(color: themeData.colorScheme.onPrimary),
        ),
      ),
      height: height,
      minWidth: minWidth,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
      ),
      onPressed: () => onPressed(),
    );
  }
}
