import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/text/text_highlighter.dart';

class EmptyScreenLayout extends StatelessWidget {
  const EmptyScreenLayout({
    required this.icon,
    required this.title,
    required this.explanation,
    super.key,
  }) : assert(title.length > 0),
       assert(explanation.length > 0);

  final Widget icon;
  final String title;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    final TextStyle textStyle = DefaultTextStyle.of(
      context,
    ).style.copyWith(fontSize: 15.0);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double circleDimension = constraints.hasBoundedHeight
            ? math.min(150.0, math.max(72.0, constraints.maxHeight * 0.35))
            : 150.0;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
              minHeight: constraints.hasBoundedHeight
                  ? constraints.maxHeight
                  : 0.0,
            ),
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(BALANCED_SPACE),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: MEDIUM_SPACE,
                    children: <Widget>[
                      SizedBox.square(
                        dimension: circleDimension,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: lightTheme
                                ? extension.primaryMedium
                                : extension.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: IconTheme.merge(
                              data: IconThemeData(
                                color: extension.primaryBlack,
                                size: circleDimension * 0.4,
                              ),
                              child: icon,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: LARGE_SPACE),
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2.0),
                      TextWithBubbleParts(
                        text: explanation,
                        textStyle: textStyle,
                        textAlign: TextAlign.center,
                        bubblePadding: const EdgeInsetsDirectional.only(
                          start: BALANCED_SPACE,
                          end: BALANCED_SPACE,
                          top: 3.5,
                          bottom: 5.0,
                        ),
                        backgroundColor: extension.primaryMedium,
                        bubbleTextStyle: textStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: extension.primaryBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
