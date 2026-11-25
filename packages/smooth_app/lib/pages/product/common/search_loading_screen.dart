import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/common/search_empty_screen.dart';
import 'package:smooth_app/resources/app_animations.dart';
import 'package:smooth_app/widgets/text/text_highlighter.dart';

/// Common search loading screen.
class SearchLoadingScreen extends StatelessWidget {
  const SearchLoadingScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SearchEmptyScreen(
      name: title,
      includeAppBar: false,
      emptiness: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double animationSize = constraints.hasBoundedHeight
              ? math.min(
                  constraints.maxWidth * 0.2,
                  math.max(48.0, constraints.maxHeight * 0.35),
                )
              : constraints.maxWidth * 0.2;

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
                  widthFactor: 0.75,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      vertical: MEDIUM_SPACE,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SearchEyeAnimation(size: animationSize),
                        const SizedBox(height: VERY_LARGE_SPACE * 2),
                        TextHighlighter(
                          text: appLocalizations.product_search_loading_message(
                            title,
                          ),
                          filter: title,
                          softWrap: true,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
