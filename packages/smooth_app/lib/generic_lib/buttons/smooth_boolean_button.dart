import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class SmoothBooleanButton extends StatelessWidget {
  const SmoothBooleanButton({
    required this.value,
    required this.onChanged,
  });

  final bool? value;
  final Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    return SizedBox(
      height: 28.0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              if (value == null || value == false) {
                onChanged(true);
              } else {
                onChanged(null);
              }
            },
            child: Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: LARGE_SPACE,
              ),
              decoration: BoxDecoration(
                color: _getSuccessColor(extension, background: true) ??
                    theme.cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(99999),
                  bottomLeft: Radius.circular(99999),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: _getColor(extension, true),
                  ),
                  top: BorderSide(
                    color: _getColor(extension, true),
                  ),
                  left: BorderSide(
                    color: _getColor(extension, true),
                  ),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.check_rounded,
                  size: 14.0,
                  color: _getColor(extension, true),
                ),
              ),
            ),
          ),
          VerticalDivider(
            color: _getColor(extension, null),
            thickness: 1.0,
          ),
          GestureDetector(
            onTap: () {
              if (value == null || value == true) {
                onChanged(false);
              } else {
                onChanged(null);
              }
            },
            child: Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: LARGE_SPACE,
              ),
              decoration: BoxDecoration(
                color: _getErrorColor(extension, background: true) ??
                    theme.cardColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(99999),
                  bottomRight: Radius.circular(99999),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: _getColor(extension, false),
                  ),
                  top: BorderSide(
                    color: _getColor(extension, false),
                  ),
                  right: BorderSide(
                    color: _getColor(extension, false),
                  ),
                ),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 14.0,
                color: _getColor(extension, false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(
    SmoothColorsThemeExtension extension,
    bool? success,
  ) {
    final Color defaultColor = extension.primaryNormal;

    if (value == null) {
      return defaultColor;
    }

    if (success == null) {
      return value! ? _getSuccessColor(extension)! : _getErrorColor(extension)!;
    }

    if (success) {
      return _getSuccessColor(extension) ?? defaultColor;
    } else {
      return _getErrorColor(extension) ?? defaultColor;
    }
  }

  Color? _getSuccessColor(SmoothColorsThemeExtension extension,
      {bool background = false}) {
    if (value == true) {
      return background ? extension.successBackground : extension.success;
    }

    return null;
  }

  Color? _getErrorColor(SmoothColorsThemeExtension extension,
      {bool background = false}) {
    if (value == false) {
      return background ? extension.errorBackground : extension.error;
    }

    return null;
  }
}
