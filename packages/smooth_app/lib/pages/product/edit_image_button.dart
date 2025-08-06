import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// Standard text button for the "edit image" pages.
class EditImageButton extends StatelessWidget {
  const EditImageButton({
    required this.iconData,
    required this.label,
    required this.onPressed,
    this.borderWidth,
  }) : _centerContent = false;

  /// Centered version of the button.
  const EditImageButton.center({
    required this.iconData,
    required this.label,
    required this.onPressed,
    this.borderWidth,
  }) : _centerContent = true;

  final IconData iconData;
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
        icon: Icon(iconData),
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
                  const EdgeInsets.symmetric(vertical: LARGE_SPACE),
                )
              : null,
          alignment: _centerContent ? AlignmentDirectional.center : null,
        ),
        onPressed: onPressed,
        label: SizedBox(
          width: !_centerContent ? double.infinity : null,
          child: Padding(
            padding: EdgeInsets.all(borderWidth ?? 0),
            child: AutoSizeText(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
