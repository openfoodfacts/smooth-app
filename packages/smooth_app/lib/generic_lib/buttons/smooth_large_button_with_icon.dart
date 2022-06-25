import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';

class SmoothLargeButtonWithIcon extends StatelessWidget {
  const SmoothLargeButtonWithIcon({
    required this.text,
    required this.icon,
    required this.onPressed,
    this.padding,
  });

  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return SmoothSimpleButton(
      minWidth: double.infinity,
      padding: padding ?? const EdgeInsets.all(10),
      onPressed: onPressed,
      buttonColor: themeData.colorScheme.secondary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            color: themeData.colorScheme.onSecondary,
          ),
          const Spacer(),
          Expanded(
            flex: 10,
            child: AutoSizeText(
              text,
              maxLines: 2,
              style: themeData.textTheme.bodyText2!.copyWith(
                color: themeData.colorScheme.onSecondary,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
