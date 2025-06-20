import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/simple_input/simple_input_page_helpers.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SimpleInputListSuggestions extends StatelessWidget {
  const SimpleInputListSuggestions(
    this.onSelected,
  );

  final Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<SimpleInputSuggestionsState> state =
        context.watch<ValueNotifier<SimpleInputSuggestionsState>>();

    if (state.value is! SimpleInputSuggestionsLoaded) {
      return EMPTY_WIDGET;
    }

    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return Padding(
      padding: const EdgeInsetsDirectional.only(top: SMALL_SPACE),
      child: ColoredBox(
        color: lightTheme ? extension.primaryMedium : extension.primarySemiDark,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 22.0,
            end: VERY_SMALL_SPACE,
          ),
          child: Column(
            children:
                (state.value as SimpleInputSuggestionsLoaded).suggestions.map(
              (String suggestion) {
                return _SimpleInputListSuggestionItem(suggestion, () {
                  onSelected(suggestion);
                });
              },
            ).toList(growable: false),
          ),
        ),
      ),
    );
  }
}

class _SimpleInputListSuggestionItem extends StatelessWidget {
  const _SimpleInputListSuggestionItem(
    this.label,
    this.onSelected,
  );

  final String label;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    return Row(
      children: <Widget>[
        ExcludeSemantics(
          child: icons.Sparkles(
            color: extension.success,
            size: 18.0,
          ),
        ),
        const SizedBox(width: SMALL_SPACE),
        Expanded(
          child: Text(
            label,
            style: TextTheme.of(context).bodyLarge?.copyWith(
                  color: extension.success,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Tooltip(
          message: AppLocalizations.of(context)
              .edit_product_form_item_add_suggestion,
          child: IconButton(
            onPressed: onSelected,
            icon: const icons.Add(size: 20.0),
          ),
        )
      ],
    );
  }
}
