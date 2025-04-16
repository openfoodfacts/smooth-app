import 'package:flutter/material.dart';

class SmoothIconButton extends StatelessWidget {
  const SmoothIconButton({
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 18.0,
    this.tooltip,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(99999),
        border: Border.all(
          color: theme.primaryColor,
          width: 1.0,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: IconButton(
        icon: icon,
        onPressed: onPressed,
        color: color ?? theme.primaryColor,
        iconSize: size,
        padding: EdgeInsets.zero,
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
