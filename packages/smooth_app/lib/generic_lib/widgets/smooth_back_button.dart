import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smooth_app/themes/constant_icons.dart';

/// Displays an [IconButton] containing the platform-specific default
/// back button icon.
class SmoothBackButton extends StatelessWidget {
  const SmoothBackButton({
    this.onPressed,
    this.iconColor,
    Key? key,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onPressed ?? () => Navigator.maybePop(context),
        child: Tooltip(
          message: MaterialLocalizations.of(context).backButtonTooltip,
          child: Padding(
            padding: _iconPadding,
            child: Icon(
              ConstantIcons.instance.getBackIcon(),
              //Used Theme which was mmore appropriate as icon colour should be according to it
              color: iconColor ??
                  (Theme.of(context).colorScheme.brightness == Brightness.light
                      ? Colors.black
                      : Colors.white),
            ),
          ),
        ),
      );

  /// The iOS/macOS icon requires a little padding to be well-centered
  EdgeInsetsGeometry get _iconPadding {
    if (Platform.isMacOS || Platform.isIOS) {
      return const EdgeInsetsDirectional.only(end: 2.0);
    } else {
      return EdgeInsets.zero;
    }
  }
}
