import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';

class SmoothProductBaseCard extends StatelessWidget {
  const SmoothProductBaseCard({
    required this.child,
    this.backgroundColorOpacity,
    super.key,
  });

  final Widget child;
  final double? backgroundColorOpacity;

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
