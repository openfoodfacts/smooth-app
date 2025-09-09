import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/widgets/text/text_extensions.dart';

class SmoothHtmlFakeButton extends StatelessWidget {
  const SmoothHtmlFakeButton({required this.children, super.key});

  final List<InlineSpan> children;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: extension.primaryMedium,
          borderRadius: ANGULAR_BORDER_RADIUS,
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2.0,
              offset: Offset(0.0, 2.0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: VERY_LARGE_SPACE,
            vertical: LARGE_SPACE,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: SelectableText.rich(
                  TextSpan(
                    children: children.map((InlineSpan span) {
                      if (span is TextSpan) {
                        return span.copyWith(
                          style: span.style?.copyWith(
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        );
                      }

                      return span;
                    }).toList(),
                  ),
                ),
              ),
              icons.ExternalLink(
                color: _getIconColor(Theme.of(context)),
                size: 16.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns the standard icon color for external link icons.
  /// 
  /// Ensures proper visibility in both light and dark modes.
  Color _getIconColor(ThemeData theme) {
    switch (theme.brightness) {
      case Brightness.light:
        return Colors.black45;
      case Brightness.dark:
        return Colors.white;
    }
  }
}
