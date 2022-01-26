import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';

class SmoothActionButton extends StatelessWidget {
  const SmoothActionButton({
    required this.text,
    required this.onPressed,
    this.minWidth = 15,
    this.height = 20,
  });

  final String text;
  final VoidCallback onPressed;
  final double minWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return SmoothSimpleButton(
      child: Text(
        text,
        style: themeData.textTheme.bodyText2!
            .copyWith(color: themeData.colorScheme.onPrimary),
      ),
      onPressed: onPressed,
      height: height,
      minWidth: minWidth,
    );
  }
}
