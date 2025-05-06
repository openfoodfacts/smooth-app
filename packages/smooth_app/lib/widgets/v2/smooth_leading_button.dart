import 'package:flutter/material.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SmoothLeadingButton extends StatelessWidget {
  const SmoothLeadingButton({
    required this.action,
    required this.foregroundColor,
    this.size,
  }) : assert(size == null || size >= 0.0);

  final SmoothLeadingAction action;
  final double? size;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final SmoothColorsThemeExtension colors =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    final String message = getMessage(localizations);
    final Color color = foregroundColor ??
        (context.darkTheme() ? colors.primaryMedium : colors.primaryBlack);

    return Semantics(
      button: true,
      value: message,
      excludeSemantics: true,
      child: Tooltip(
        message: message,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            customBorder: const CircleBorder(),
            splashColor: Colors.white70,
            child: Ink(
              decoration: BoxDecoration(
                border: Border.all(
                  color: color,
                  width: 1.0,
                ),
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: size ?? 36.0,
                child: appIcon(
                  size: 16.0,
                  color: color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget appIcon({
    required double size,
    required Color color,
  }) {
    assert(size >= 0.0);

    return switch (action) {
      SmoothLeadingAction.close => icons.Close(size: size, color: color),
      SmoothLeadingAction.back => icons.Arrow.left(size: size, color: color),
      SmoothLeadingAction.minimize => Padding(
          padding: const EdgeInsetsDirectional.only(top: 1.0),
          child: icons.Chevron.down(size: size, color: color),
        ),
    };
  }

  String getMessage(MaterialLocalizations localizations) {
    return switch (action) {
      SmoothLeadingAction.close => localizations.closeButtonTooltip,
      SmoothLeadingAction.back => localizations.backButtonTooltip,
      SmoothLeadingAction.minimize => localizations.closeButtonTooltip,
    };
  }
}

enum SmoothLeadingAction {
  close,
  back,
  minimize,
}
