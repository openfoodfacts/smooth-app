import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/product/autocomplete.dart';
import 'package:smooth_app/query/product_query.dart';

/// Simple input text field, with autocompletion.
class SimpleInputTextField extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: LARGE_SPACE),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: RawAutocomplete<String>(
                key: autocompleteKey,
                focusNode: focusNode,
                textEditingController: controller,
                optionsBuilder: (final TextEditingValue value) async {
                  if (tagType == null) {
                    return <String>[];
                  }

                  final String input = value.text.trim();
                  if (input.length < minLengthForSuggestions) {
                    return <String>[];
                  }
                  
                  return OpenFoodAPIClient.getSuggestions(
                    tagType!,
                    language: ProductQuery.getLanguage()!,
                    country: ProductQuery.getCountry(),
                    categories: categories,
                    shape: shapeProvider?.call(),
                    user: ProductQuery.getUser(),
                    limit: 15, // number of suggestions the user can scroll through: compromise between quantity and readability of the suggestions
                    input: input,
                  );
                },
                fieldViewBuilder: (BuildContext context,
                        TextEditingController textEditingController,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted) =>
                    TextField(
                  controller: textEditingController,
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
                    hintText: hintText,
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
                  final double screenHeight =
                      MediaQuery.of(context).size.height;
                  final double keyboardHeight =
                      MediaQuery.of(lContext).viewInsets.bottom;

                  final double widgetPosition =
                      (context.findRenderObject() as RenderBox?)
                              ?.localToGlobal(Offset.zero)
                              .dy ??
                          0.0;

                  return AutocompleteOptions<String>(
                    displayStringForOption:
                        RawAutocomplete.defaultStringForOption,
                    onSelected: onSelected,
                    options: options,
                    // Width = Row width - horizontal padding
                    maxOptionsWidth: constraints.maxWidth - (LARGE_SPACE * 2),
                    maxOptionsHeight: screenHeight/3,
                  );
                },
              ),
            ),
            if (withClearButton)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => controller.text = '',
              ),
          ],
        ),
      );
}
