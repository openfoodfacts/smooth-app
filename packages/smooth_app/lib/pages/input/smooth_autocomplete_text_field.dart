import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/strings_helper.dart';
import 'package:smooth_app/pages/input/debounced_text_editing_controller.dart';
import 'package:smooth_app/pages/product/autocomplete.dart';

/// Autocomplete text field.
class SmoothAutocompleteTextField extends StatefulWidget {
  const SmoothAutocompleteTextField({
    required this.focusNode,
    required this.controller,
    required this.autocompleteKey,
    required this.hintText,
    required this.constraints,
    required this.manager,
    this.minLengthForSuggestions = 1,
    this.allowEmojis = true,
    this.suffixIcon,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.textCapitalization,
    this.onSelected,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final Key autocompleteKey;
  final String hintText;
  final BoxConstraints constraints;
  final int minLengthForSuggestions;
  final AutocompleteManager? manager;
  final bool allowEmojis;
  final Widget? suffixIcon;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final TextCapitalization? textCapitalization;

  /// Additional specific action when a suggested item is selected.
  final Function(String)? onSelected;

  @override
  State<SmoothAutocompleteTextField> createState() =>
      _SmoothAutocompleteTextFieldState();
}

class _SmoothAutocompleteTextFieldState
    extends State<SmoothAutocompleteTextField> {
  final Map<String, _SearchResults> _suggestions = <String, _SearchResults>{};
  bool _loading = false;
  String? _selectedSearch;

  late DebouncedTextEditingController _debouncedController;

  @override
  void initState() {
    super.initState();
    _debouncedController = DebouncedTextEditingController(
      controller: widget.controller,
    );
  }

  @override
  void dispose() {
    _debouncedController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(final SmoothAutocompleteTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _debouncedController.replaceWith(widget.controller);
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      key: widget.autocompleteKey,
      focusNode: widget.focusNode,
      textEditingController: _debouncedController,
      optionsBuilder: (final TextEditingValue value) {
        return _getSuggestions(value.text);
      },
      fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) =>
          TextField(
        maxLines: 1,
        controller: widget.controller,
        onChanged: (_) {
          if (mounted) {
            setState(() => _selectedSearch = null);
          }
        },
        inputFormatters: <TextInputFormatter>[
          if (!widget.allowEmojis)
            FilteringTextInputFormatter.deny(TextHelper.emojiRegex),
        ],
        textCapitalization:
            widget.textCapitalization ?? TextCapitalization.none,
        style: widget.textStyle ??
            DefaultTextStyle.of(context).style.copyWith(fontSize: 15.0),
        decoration: InputDecoration(
          contentPadding: widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: SMALL_SPACE,
                vertical: SMALL_SPACE,
              ),
          isDense: widget.padding != null,
          suffixIcon: widget.suffixIcon,
          filled: true,
          hintStyle: SmoothTextFormField.defaultHintTextStyle(context),
          hintText: widget.hintText,
          border: OutlineInputBorder(
            borderRadius: widget.borderRadius ?? ANGULAR_BORDER_RADIUS,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: widget.borderRadius ?? CIRCULAR_BORDER_RADIUS,
            borderSide: const BorderSide(
              color: Colors.transparent,
              width: 5.0,
            ),
          ),
          suffix: Offstage(
            offstage: !_loading,
            child: SizedBox(
              width: Theme.of(context).textTheme.titleMedium?.fontSize ?? 15,
              height: Theme.of(context).textTheme.titleMedium?.fontSize ?? 15,
              child: const CircularProgressIndicator.adaptive(
                strokeWidth: 1.0,
              ),
            ),
          ),
        ),
        // a lot of confusion if set to `true`
        autofocus: false,
        focusNode: focusNode,
      ),
      onSelected: (String search) {
        _selectedSearch = search;
        _setLoading(false);
        widget.onSelected?.call(search);
      },
      optionsViewBuilder: (
        BuildContext lContext,
        AutocompleteOnSelected<String> onSelected,
        Iterable<String> options,
      ) {
        final double screenHeight = MediaQuery.sizeOf(context).height;
        String input = '';

        for (final String key in _suggestions.keys) {
          if (_suggestions[key].hashCode == options.hashCode) {
            input = key;
            break;
          }
        }

        if (input == _searchInput) {
          _setLoading(false);
        }

        return AutocompleteOptions<String>(
          displayStringForOption: RawAutocomplete.defaultStringForOption,
          onSelected: onSelected,
          options: options,
          // Width = Row width - horizontal padding
          maxOptionsWidth: widget.constraints.maxWidth - (LARGE_SPACE * 2),
          maxOptionsHeight: screenHeight / 3,
          search: input,
        );
      },
    );
  }

  String get _searchInput => widget.controller.text.trim();

  void _setLoading(bool loading) {
    if (_loading != loading) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          if (mounted) {
            setState(() => _loading = loading);
          }
        },
      );
    }
  }

  Future<_SearchResults> _getSuggestions(String search) async {
    if (search == _selectedSearch) {
      return _SearchResults.empty();
    }

    final DateTime start = DateTime.now();

    if (_suggestions[search] != null) {
      return _suggestions[search]!;
    } else if (widget.manager == null ||
        search.length < widget.minLengthForSuggestions) {
      _suggestions[search] = _SearchResults.empty();
      return _suggestions[search]!;
    }

    _setLoading(true);

    try {
      _suggestions[search] =
          _SearchResults(await widget.manager!.getSuggestions(search));
    } catch (_) {}

    if (_suggestions[search]?.isEmpty ?? true && search == _searchInput) {
      _setLoading(false);
    }

    if (_searchInput != search &&
        start.difference(DateTime.now()).inSeconds > 5) {
      // Ignore this request, it's too long and this is not even the current search
      return _SearchResults.empty();
    } else {
      return _suggestions[search] ?? _SearchResults.empty();
    }
  }
}

@immutable
class _SearchResults extends DelegatingList<String> {
  _SearchResults(List<String>? results) : super(results ?? <String>[]);

  _SearchResults.empty() : super(<String>[]);
  final int _uniqueId = DateTime.now().millisecondsSinceEpoch;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SearchResults &&
          runtimeType == other.runtimeType &&
          _uniqueId == other._uniqueId;

  @override
  int get hashCode => _uniqueId;
}
