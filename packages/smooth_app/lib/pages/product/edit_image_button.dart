import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/widgets/autosize_text.dart';

/// Standard text button for the "edit image" pages.
class EditImageButton extends StatelessWidget {
  const EditImageButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.borderWidth,
  });

  final Widget icon;
  final String label;
  final VoidCallback onPressed;
  final double? borderWidth;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: OutlinedButton.icon(
        icon: IconTheme.merge(
          data: const IconThemeData(size: 15.0),
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
        ),
        onPressed: onPressed,
        label: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: borderWidth ?? 0.0,
              vertical: borderWidth ?? 0.0,
            ),
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
