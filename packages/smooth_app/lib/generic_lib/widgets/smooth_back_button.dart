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
    final String semanticLabel = _semanticLabel(context);

    return Tooltip(
      message: semanticLabel,
      child: Semantics(
        value: semanticLabel,
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
              child: _circledIcon(switch (backButtonType ??
                  BackButtonType.back) {
                BackButtonType.back => const icons.Arrow.left(),
                BackButtonType.close => const icons.Close.bold(size: 14.0),
                BackButtonType.minimize => const icons.Chevron.down(),
              }),
            ),
          ),
        ),
      ),
    );
  }

  String _semanticLabel(BuildContext context) => switch (backButtonType ??
      BackButtonType.back) {
    BackButtonType.back => MaterialLocalizations.of(context).backButtonTooltip,
    BackButtonType.close => MaterialLocalizations.of(
      context,
    ).closeButtonTooltip,
    BackButtonType.minimize => MaterialLocalizations.of(
      context,
    ).closeButtonTooltip,
  };

  Widget _circledIcon(Widget icon) => Padding(
    padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
    child: DecoratedBox(
      decoration: ShapeDecoration(
        shape: CircleBorder(
          side: BorderSide(color: iconColor ?? Colors.white, width: 1.75),
        ),
      ),
      child: icons.AppIconTheme(
        size: 16.0,
        color: iconColor ?? Colors.white,
        child: icon,
      ),
    ),
  );
}

enum BackButtonType {
  back,
  close,
  minimize;

  static BackButtonType? byName(String? type) {
    return switch (type) {
      'back' => BackButtonType.back,
      'close' => BackButtonType.close,
      'minimize' => BackButtonType.minimize,
      _ => null,
    };
  }
}
