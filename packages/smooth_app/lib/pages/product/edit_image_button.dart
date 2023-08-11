import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// Standard text button for the "edit image" pages.
class EditImageButton extends StatelessWidget {
  const EditImageButton({
    required this.iconData,
    required this.label,
    required this.onPressed,
    this.borderWidth,
  });

  final IconData iconData;
  final String label;
  final VoidCallback onPressed;
  final double? borderWidth;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      icon: Icon(iconData),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(colorScheme.onPrimary),
        shape: MaterialStateProperty.all(
          const RoundedRectangleBorder(borderRadius: ROUNDED_BORDER_RADIUS),
        ),
        side: borderWidth == null
            ? null
            : MaterialStateBorderSide.resolveWith(
                (_) => BorderSide(
                  color: colorScheme.primary,
                  width: borderWidth!,
                ),
              ),
      ),
      onPressed: onPressed,
      label: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(borderWidth ?? 0),
          child: Text(label),
        ),
      ),
    );
  }
}
