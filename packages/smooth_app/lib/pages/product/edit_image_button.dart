import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// Standard text button for the "edit image" pages.
class EditImageButton extends StatelessWidget {
  const EditImageButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.borderWidth,
  }) : _centerContent = false;

  /// Centered version of the button.
  const EditImageButton.center({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.borderWidth,
  }) : _centerContent = true;

  final Widget icon;
  final String label;
  final VoidCallback onPressed;
  final double? borderWidth;
  final bool _centerContent;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: OutlinedButton.icon(
        icon: IconTheme.merge(
          data: IconThemeData(size: !_centerContent ? 15.0 : null),
          child: icon,
        ),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(colorScheme.onPrimary),
          shape: WidgetStateProperty.all(
            const RoundedRectangleBorder(borderRadius: ROUNDED_BORDER_RADIUS),
          ),
          side: borderWidth == null
              ? null
              : WidgetStateBorderSide.resolveWith(
                  (_) => BorderSide(
                    color: colorScheme.primary,
                    width: borderWidth!,
                  ),
                ),
          padding: _centerContent
              ? WidgetStateProperty.all(
                  const EdgeInsetsDirectional.symmetric(vertical: LARGE_SPACE),
                )
              : null,
          alignment: _centerContent ? AlignmentDirectional.center : null,
        ),
        onPressed: onPressed,
        label: SizedBox(
          width: !_centerContent ? double.infinity : null,
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal:
                  (borderWidth ?? 0.0) + (_centerContent ? SMALL_SPACE : 0.0),
              vertical: borderWidth ?? 0.0,
            ),
            child: AutoSizeText(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _centerContent
                  ? const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
