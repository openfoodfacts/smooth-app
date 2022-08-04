import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/TagType.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/product/autocomplete.dart';
import 'package:smooth_app/pages/product/explanation_widget.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/query/product_query.dart';

/// Simple input widget: we have a list of terms, we add, we remove.
class SimpleInputWidget extends StatefulWidget {
  const SimpleInputWidget({
    required this.helper,
    required this.product,
    required this.controller,
  });

  final AbstractSimpleInputPageHelper helper;
  final Product product;
  final TextEditingController controller;

  @override
  State<SimpleInputWidget> createState() => _SimpleInputWidgetState();
}

class _SimpleInputWidgetState extends State<SimpleInputWidget> {
  final FocusNode _focusNode = FocusNode();
  final Key _autocompleteKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    widget.helper.reInit(widget.product);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          leading: widget.helper.getIcon(),
          title: Text(
            widget.helper.getTitle(appLocalizations),
            style: themeData.textTheme.headline3,
          ),
        ),
        ExplanationWidget(widget.helper.getAddExplanations(appLocalizations)),
        LayoutBuilder(
          builder: (_, BoxConstraints constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: LARGE_SPACE),
                    child: RawAutocomplete<String>(
                      key: _autocompleteKey,
                      focusNode: _focusNode,
                      textEditingController: widget.controller,
                      optionsBuilder: (final TextEditingValue value) async {
                        final List<String> result = <String>[];
                        final String input = value.text.trim();
                        if (input.isEmpty) {
                          return result;
                        }
                        final TagType? tagType = widget.helper.getTagType();
                        if (tagType == null) {
                          return result;
                        }
                        // TODO(monsieurtanuki): ask off-dart to return Strings instead of dynamic?
                        final List<dynamic> data =
                            await OpenFoodAPIClient.getAutocompletedSuggestions(
                          tagType,
                          language: ProductQuery.getLanguage()!,
                          limit:
                              1000000, // lower max count on the server anyway
                          input: value.text.trim(),
                        );
                        for (final dynamic item in data) {
                          result.add(item.toString());
                        }
                        result.sort();
                        return result;
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
                            borderRadius: CIRCULAR_BORDER_RADIUS,
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: SMALL_SPACE,
                            vertical: SMALL_SPACE,
                          ),
                          hintText: widget.helper.getAddHint(appLocalizations),
                        ),
                        autofocus: true,
                        focusNode: focusNode,
                      ),
                      optionsViewBuilder: (
                        BuildContext context,
                        AutocompleteOnSelected<String> onSelected,
                        Iterable<String> options,
                      ) =>
                          AutocompleteOptions<String>(
                        displayStringForOption:
                            RawAutocomplete.defaultStringForOption,
                        onSelected: onSelected,
                        options: options,
                        // Width = Row width - horizontal padding
                        maxOptionsWidth:
                            constraints.maxWidth - (LARGE_SPACE * 2),
                        maxOptionsHeight:
                            MediaQuery.of(context).size.height / 2,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (widget.helper
                        .addItemsFromController(widget.controller)) {
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.add_circle),
                ),
              ],
            );
          },
        ),
        Divider(color: themeData.colorScheme.onBackground),
        Column(
          children: List<Widget>.generate(
            widget.helper.terms.length,
            (final int index) {
              final String term = widget.helper.terms[index];
              return ListTile(
                leading: const Icon(Icons.delete),
                title: Text(term),
                onTap: () async {
                  if (widget.helper.removeTerm(term)) {
                    setState(() {});
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
