import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';
import 'package:smooth_app/themes/theme_provider.dart';

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
    final bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode(context);
    return SmoothSimpleButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            color: isDarkMode
                ? Theme.of(context).colorScheme.onPrimary
                : Colors.blue,
          ),
          const Spacer(),
          Text(
            text,
            textAlign: TextAlign.center,
            style: themeData.textTheme.bodyText2!.copyWith(
              color: isDarkMode
                  ? Theme.of(context).colorScheme.onPrimary
                  : Colors.blue,
            ),
          ),
          const Spacer(),
        ],
      ),
      minWidth: double.infinity,
      padding: padding ?? const EdgeInsets.all(10),
      buttonColor: isDarkMode ? Colors.grey : const Color(0xffeaf5fb),
      onPressed: onPressed,
    );
  }
}
