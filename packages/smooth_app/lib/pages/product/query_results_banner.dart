import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class QueryResultsBanner extends StatelessWidget {
  const QueryResultsBanner({
    required this.mainText,
    this.extraLines,
    this.leading,
    this.trailing,
    this.margin,
    super.key,
  });

  final String mainText;
  final List<String>? extraLines;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return Padding(
      padding: margin ?? const EdgeInsetsDirectional.only(top: SMALL_SPACE),
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: lightTheme
                ? extension.primaryMedium
                : extension.primaryBlack,
            borderRadius: ANGULAR_BORDER_RADIUS,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
            child: Row(
              children: <Widget>[
                ?leading,
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: mainText,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (extraLines != null)
                          ...extraLines!.map(
                            (String line) => TextSpan(text: '\n$line'),
                          ),
                      ],
                      style: DefaultTextStyle.of(context).style.copyWith(
                        color: lightTheme ? Colors.black : Colors.white,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
