import 'package:flutter/material.dart';

/// A [Checkbox.adaptive] that ensures that the Cupertino variant follows
/// the same theme as the Material variant.
/// (Active color = fill color)
class SmoothCheckbox extends StatelessWidget {
  const SmoothCheckbox({
    super.key,
    required this.value,
    this.tristate = false,
    required this.onChanged,
    this.mouseCursor,
    this.activeColor,
    this.fillColor,
    this.checkColor,
    this.focusColor,
    this.hoverColor,
    this.overlayColor,
    this.splashRadius,
    this.materialTapTargetSize,
    this.visualDensity,
    this.focusNode,
    this.autofocus = false,
    this.shape,
    this.side,
    this.isError = false,
    this.semanticLabel,
  });

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final MouseCursor? mouseCursor;
  final Color? activeColor;
  final WidgetStateProperty<Color?>? fillColor;
  final Color? checkColor;
  final bool tristate;
  final MaterialTapTargetSize? materialTapTargetSize;
  final VisualDensity? visualDensity;
  final Color? focusColor;
  final Color? hoverColor;
  final WidgetStateProperty<Color?>? overlayColor;
  final double? splashRadius;
  final FocusNode? focusNode;
  final bool autofocus;
  final OutlinedBorder? shape;
  final BorderSide? side;
  final bool isError;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Checkbox.adaptive(
      value: value,
      onChanged: onChanged,
      mouseCursor: mouseCursor,
      activeColor: (fillColor ?? Theme.of(context).checkboxTheme.fillColor!)
          .resolve(<WidgetState>{WidgetState.selected}),
      fillColor: fillColor,
      checkColor: checkColor,
      tristate: tristate,
      materialTapTargetSize: materialTapTargetSize,
      visualDensity: visualDensity ?? VisualDensity.standard,
      focusColor: focusColor,
      hoverColor: hoverColor,
      overlayColor: overlayColor,
      splashRadius: splashRadius,
      focusNode: focusNode,
      autofocus: autofocus,
      shape: shape,
      side: side,
      isError: isError,
      semanticLabel: semanticLabel,
    );
  }
}
