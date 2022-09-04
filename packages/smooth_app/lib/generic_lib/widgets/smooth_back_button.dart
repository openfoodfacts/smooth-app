import 'package:flutter/material.dart';
import 'package:smooth_app/themes/constant_icons.dart';

/// Displays an [IconButton] containing the platform-specific default
/// back button icon.
class SmoothBackButton extends StatelessWidget {
  const SmoothBackButton({
    this.onPressed,
  });

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(ConstantIcons.instance.getBackIcon()),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: onPressed ?? () => Navigator.maybePop(context),
      );
}
