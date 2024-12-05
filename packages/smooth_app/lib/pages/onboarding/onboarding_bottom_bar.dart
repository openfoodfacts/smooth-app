import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// Bottom Bar during onboarding. Typical use case: previous/next buttons.
class OnboardingBottomBar extends StatelessWidget {
  const OnboardingBottomBar({
    required this.rightButton,
    required this.backgroundColor,
    required this.leftButton,
    this.semanticsHorizontalOrder = true,
  });

  final Widget? leftButton;
  final Widget rightButton;

  /// If [true], the [leftButton] will be said first by the screen reader.
  final bool semanticsHorizontalOrder;

  /// Color of the background where we put the buttons.
  ///
  /// If null, transparent background and no visible divider.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    // Side padding is 8% of total width.
    final double sidePadding = screenSize.width * .08;
    final bool hasPrevious = leftButton != null;
    return Column(
      children: <Widget>[
        Container(
          height: SMALL_SPACE,
          width: screenSize.width,
          color: backgroundColor == null ? null : LIGHT_GREY_COLOR,
        ),
        Container(
          padding: EdgeInsets.symmetric(
            vertical: VERY_LARGE_SPACE,
            horizontal: sidePadding,
          ),
          width: screenSize.width,
          color: backgroundColor,
          child: Row(
            mainAxisAlignment: hasPrevious
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (leftButton != null)
                Semantics(
                  sortKey: OrdinalSortKey(semanticsHorizontalOrder ? 2.0 : 1.0),
                  child: leftButton,
                ),
              Semantics(
                sortKey: OrdinalSortKey(semanticsHorizontalOrder ? 1.0 : 2.0),
                child: rightButton,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Onboarding Bottom Button, e.g. "next" or "previous".
class OnboardingBottomButton extends StatelessWidget {
  const OnboardingBottomButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.label,
    this.nextKey,
  });

  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final String label;

  /// Button Key - typically used during screenshot generation.
  final Key? nextKey;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints.tightFor(height: MINIMUM_TOUCH_SIZE),
        child: ElevatedButton(
          key: nextKey,
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(backgroundColor),
            overlayColor: backgroundColor == Colors.white
                ? WidgetStateProperty.all<Color>(Theme.of(context).splashColor)
                : null,
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40))),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: foregroundColor,
                ),
          ),
        ),
      );
}

/// Onboarding Bottom Icon, e.g. arrow for "next" or "previous".
class OnboardingBottomIcon extends StatelessWidget {
  const OnboardingBottomIcon({
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    this.iconPadding,
  });

  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final EdgeInsetsGeometry? iconPadding;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(MEDIUM_SPACE),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
        onPressed: onPressed,
        child: Padding(
          padding: iconPadding ?? EdgeInsets.zero,
          child: Icon(icon),
        ),
      );
}
