import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';

/// A common Widget for carrousel item cards.
/// It allows to have the correct width/height and also a scale down feature,
/// in the case where the content is too big.
///
/// An optional [backgroundColorOpacity] can be used (mainly for the "main" card).
class SmoothProductBaseCard extends StatelessWidget {
  const SmoothProductBaseCard({
    required this.child,
    this.backgroundColorOpacity,
    this.margin,
    super.key,
  });

  final Widget child;
  final double? backgroundColorOpacity;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return SizedBox.expand(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final EdgeInsets padding = EdgeInsets.symmetric(
            vertical: constraints.maxHeight * 0.05,
            horizontal: constraints.maxWidth * 0.05,
          );

          return SmoothCard(
            color: themeData.brightness == Brightness.light
                ? Colors.white.withOpacity(backgroundColorOpacity ?? 1.0)
                : Colors.black.withOpacity(backgroundColorOpacity ?? 1.0),
            margin: margin,
            padding: padding,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: constraints.maxWidth - padding.horizontal,
                height: constraints.maxHeight - padding.vertical,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A simple button to express we can remove a card
class ProductCardCloseButton extends StatelessWidget {
  const ProductCardCloseButton({
    this.onRemove,
    this.iconData = Icons.clear_rounded,
    this.padding,
  });

  final OnRemoveCallback? onRemove;
  final IconData iconData;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          onRemove?.call(context);
          SmoothHapticFeedback.lightNotification();
        },
        child: Tooltip(
          message: appLocalizations.product_card_remove_product_tooltip,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(SMALL_SPACE),
            child: Icon(
              iconData,
              size: DEFAULT_ICON_SIZE,
            ),
          ),
        ),
      ),
    );
  }
}

typedef OnRemoveCallback = void Function(BuildContext context);
