import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/common/search_empty_screen.dart';
import 'package:smooth_app/resources/app_animations.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

/// Common search loading screen.
class SearchLoadingScreen extends StatelessWidget {
  const SearchLoadingScreen({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SearchEmptyScreen(
      name: title,
      includeAppBar: false,
      emptiness: FractionallySizedBox(
        widthFactor: 0.75,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SearchEyeAnimation(
              size: MediaQuery.sizeOf(context).width * 0.2,
            ),
            const SizedBox(height: VERY_LARGE_SPACE * 2),
            TextHighlighter(
              text: appLocalizations.product_search_loading_message(title),
              filter: title,
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
