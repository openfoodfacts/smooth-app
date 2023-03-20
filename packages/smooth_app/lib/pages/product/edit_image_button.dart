import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// Standard text button for the "edit image" pages.
class EditImageButton extends StatelessWidget {
  const EditImageButton({
    required this.iconData,
    required this.label,
    required this.onPressed,
  });

  final IconData iconData;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        icon: Icon(iconData),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            Theme.of(context).colorScheme.background,
          ),
          shape: MaterialStateProperty.all(
            const RoundedRectangleBorder(borderRadius: ROUNDED_BORDER_RADIUS),
          ),
        ),
        onPressed: onPressed,
        label: Text(label),
      );
}
