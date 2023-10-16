import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/product/autocomplete.dart';
import 'package:smooth_app/query/product_query.dart';

/// Simple input text field, with autocompletion.
class SimpleInputTextField extends StatefulWidget {
  const SimpleInputTextField({
    required this.focusNode,
    required this.autocompleteKey,
    required this.constraints,
    required this.tagType,
    required this.hintText,
    required this.controller,
    this.withClearButton = false,
    this.minLengthForSuggestions = 1,
    this.categories,
    this.shapeProvider,
    this.padding,
  });

  final FocusNode focusNode;
  final Key autocompleteKey;
  final BoxConstraints constraints;
  final TagType? tagType;
  final String hintText;
  final TextEditingController controller;
  final bool withClearButton;
  final int minLengthForSuggestions;
  final String? categories;
  final String? Function()? shapeProvider;
  final EdgeInsetsGeometry? padding;

  @override
  State<SimpleInputTextField> createState() => _SimpleInputTextFieldState();
}

class _SimpleInputTextFieldState extends State<SimpleInputTextField> {
  final Map<String, _SearchResults> _suggestions = <String, _SearchResults>{};
  bool _loading = false;

  late _DebouncedTextEditingController _debouncedController;
  late SuggestionManager? _manager;

  @override
  void initState() {
    super.initState();

    _debouncedController = _DebouncedTextEditingController(widget.controller);

    _manager = widget.tagType == null
        ? null
        : SuggestionManager(
            widget.tagType!,
            language: ProductQuery.getLanguage(),
            country: ProductQuery.getCountry(),
            categories: widget.categories,
            shape: widget.shapeProvider?.call(),
            user: ProductQuery.getUser(),
            // number of suggestions the user can scroll through: compromise between quantity and readability of the suggestions
            limit: 15,
          );
  }

  @override
  void didUpdateWidget(SimpleInputTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _debouncedController.replaceWith(widget.controller);
  }

  Future<_SearchResults> _getSuggestions(String search) async {
    final DateTime start = DateTime.now();

    if (_suggestions[search] != null) {
      return _suggestions[search]!;
    } else if (_manager == null ||
        search.length < widget.minLengthForSuggestions) {
      _suggestions[search] = _SearchResults.empty();
      return _suggestions[search]!;
    }

    _setLoading(true);

    try {
      _suggestions[search] =
          _SearchResults(await _manager!.getSuggestions(search));
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ??
          const EdgeInsetsDirectional.only(start: LARGE_SPACE),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: RawAutocomplete<String>(
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
                controller: widget.controller,
                decoration: InputDecoration(
                  filled: true,
                  border: const OutlineInputBorder(
                    borderRadius: ANGULAR_BORDER_RADIUS,
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: SMALL_SPACE,
                    vertical: SMALL_SPACE,
                  ),
                  hintText: widget.hintText,
                  suffix: Offstage(
                    offstage: !_loading,
                    child: SizedBox(
                      width:
                          Theme.of(context).textTheme.titleMedium?.fontSize ??
                              15,
                      height:
                          Theme.of(context).textTheme.titleMedium?.fontSize ??
                              15,
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
              optionsViewBuilder: (
                BuildContext lContext,
                AutocompleteOnSelected<String> onSelected,
                Iterable<String> options,
              ) {
                final double screenHeight = MediaQuery.of(context).size.height;
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
                  displayStringForOption:
                      RawAutocomplete.defaultStringForOption,
                  onSelected: onSelected,
                  options: options,
                  // Width = Row width - horizontal padding
                  maxOptionsWidth:
                      widget.constraints.maxWidth - (LARGE_SPACE * 2),
                  maxOptionsHeight: screenHeight / 3,
                  search: input,
                );
              },
            ),
          ),
          if (widget.withClearButton)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => widget.controller.text = '',
            ),
        ],
      ),
    );
  }

  String get _searchInput => widget.controller.text.trim();

  void _setLoading(bool loading) {
    if (_loading != loading) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => setState(() => _loading = loading),
      );
    }
  }

  @override
  void dispose() {
    _debouncedController.dispose();
    super.dispose();
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

/// Allows to unfocus TextField (and dismiss the keyboard) when user tap outside the TextField and inside this widget.
/// Therefore, this widget should be put before the Scaffold to make the TextField unfocus when tapping anywhere.
class UnfocusWhenTapOutside extends StatelessWidget {
  const UnfocusWhenTapOutside({Key? key, required this.child})
      : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: child,
    );
  }
}

class _DebouncedTextEditingController extends TextEditingController {
  _DebouncedTextEditingController(TextEditingController controller) {
    replaceWith(controller);
  }

  TextEditingController? _controller;
  Timer? _debounce;

  void replaceWith(TextEditingController controller) {
    _controller?.removeListener(_onWrappedTextEditingControllerChanged);
    _controller = controller;
    _controller?.addListener(_onWrappedTextEditingControllerChanged);
  }

  void _onWrappedTextEditingControllerChanged() {
    if (_debounce?.isActive == true) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      super.notifyListeners();
    });
  }

  @override
  set text(String newText) => _controller?.value = value;

  @override
  String get text => _controller?.text ?? '';

  @override
  TextEditingValue get value => _controller?.value ?? TextEditingValue.empty;

  @override
  set value(TextEditingValue newValue) => _controller?.value = newValue;

  @override
  void clear() => _controller?.clear();

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
