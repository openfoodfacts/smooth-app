import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/input/smooth_autocomplete_text_field.dart';
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
    required this.productType,
    this.suffixIcon,
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
  final ProductType? productType;
  final Widget? suffixIcon;

  @override
  State<SimpleInputTextField> createState() => _SimpleInputTextFieldState();
}

class _SimpleInputTextFieldState extends State<SimpleInputTextField> {
  late final AutocompleteManager? _manager;

  @override
  void initState() {
    super.initState();
    _manager = widget.tagType == null
        ? null
        : AutocompleteManager(
            TagTypeAutocompleter(
              tagType: widget.tagType!,
              language: ProductQuery.getLanguage(),
              country: ProductQuery.getCountry(),
              categories: widget.categories,
              shape: widget.shapeProvider?.call(),
              user: ProductQuery.getReadUser(),
              // number of suggestions the user can scroll through: compromise between quantity and readability of the suggestions
              limit: 15,
              uriHelper: ProductQuery.getUriProductHelper(
                productType: widget.productType,
              ),
            ),
          );
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
            child: SmoothAutocompleteTextField(
              focusNode: widget.focusNode,
              controller: widget.controller,
              autocompleteKey: widget.autocompleteKey,
              hintText: widget.hintText,
              constraints: widget.constraints,
              manager: _manager,
              suffixIcon: widget.suffixIcon,
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
}
