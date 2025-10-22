import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

/// Displays an [IconButton] containing the platform-specific default
/// back button icon.
class SmoothBackButton extends StatelessWidget {
  const SmoothBackButton({
    this.onPressed,
    this.iconColor,
    this.backButtonType,
    super.key,
  });

  final VoidCallback? onPressed;
  final Color? iconColor;
  final BackButtonType? backButtonType;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: MaterialLocalizations.of(context).backButtonTooltip,
      child: Semantics(
        value: MaterialLocalizations.of(context).backButtonTooltip,
        excludeSemantics: true,
        button: true,
        child: SizedBox(
          width: kToolbarHeight,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              Navigator.of(context).maybePop();
            },
            child: SizedBox.expand(
              child: backButtonType == BackButtonType.minimize
                  ? const icons.Chevron.down(size: 16.0)
                  : Padding(
                      padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
                      child: DecoratedBox(
                        decoration: ShapeDecoration(
                          shape: CircleBorder(
                            side: BorderSide(
                              color: iconColor ?? Colors.white,
                              width: 1.75,
                            ),
                          ),
                        ),
                        child: icons.Arrow.left(
                          size: 16.0,
                          color: iconColor ?? Colors.white,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

enum BackButtonType {
  back,
  minimize;

  static BackButtonType? byName(String? type) {
    return switch (type) {
      'back' => BackButtonType.back,
      'minimize' => BackButtonType.minimize,
      _ => null,
    };
  }
}
