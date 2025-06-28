import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

/// The default Material-style Autocomplete options.
///
/// Was copied from material/autocomplete.dart as they were not kind enough
/// to make it public.
/// Inspiration was found in https://stackoverflow.com/questions/66935362
class AutocompleteOptions<T extends Object> extends StatelessWidget {
  const AutocompleteOptions({
    super.key,
    required this.displayStringForOption,
    required this.onSelected,
    required this.options,
    required this.maxOptionsHeight,
    required this.maxOptionsWidth,
    this.search,
  }) : assert(maxOptionsHeight >= 0),
       assert(maxOptionsWidth >= 0);

  final AutocompleteOptionToString<T> displayStringForOption;
  final AutocompleteOnSelected<T> onSelected;

  final Iterable<T> options;
  final double maxOptionsWidth;
  final double maxOptionsHeight;
  final String? search;

  @override
  Widget build(BuildContext context) {
    final int highlightedOption = AutocompleteHighlightedOption.of(context);

    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Material(
        elevation: 4.0,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxOptionsHeight,
            maxWidth: maxOptionsWidth,
            minWidth: 100.0,
          ),
          child: Scrollbar(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final T option = options.elementAt(index);

                return _AutocompleteOptionsItem<T>(
                  key: Key(index.toString()),
                  option: option,
                  search: search,
                  highlight: highlightedOption == index,
                  onSelected: onSelected,
                  displayStringForOption: displayStringForOption,
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1.0),
            ),
          ),
        ),
      ),
    );
  }
}

class _AutocompleteOptionsItem<T extends Object> extends StatelessWidget {
  const _AutocompleteOptionsItem({
    required this.option,
    required this.highlight,
    required this.displayStringForOption,
    required this.onSelected,
    this.search,
    super.key,
  });

  final T option;
  final String? search;
  final bool highlight;
  final AutocompleteOptionToString<T> displayStringForOption;
  final AutocompleteOnSelected<T> onSelected;

  @override
  Widget build(BuildContext context) {
    if (highlight) {
      SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
        Scrollable.ensureVisible(context, alignment: 0.5);
      });
    }

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => onSelected(option),
        child: Ink(
          color: highlight ? Theme.of(context).focusColor : null,
          padding: const EdgeInsets.all(LARGE_SPACE),
          child: TextHighlighter(
            text: displayStringForOption(option),
            filter: search ?? '',
          ),
        ),
      ),
    );
  }
}
