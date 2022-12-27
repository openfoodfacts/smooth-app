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
          minLeadingWidth: 0.0,
          horizontalTitleGap: 12.0,
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
                  child: SimpleInputWidgetField(
                    autocompleteKey: _autocompleteKey,
                    focusNode: _focusNode,
                    constraints: constraints,
                    tagType: widget.helper.getTagType(),
                    hintText: widget.helper.getAddHint(appLocalizations),
                    controller: widget.controller,
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
                )
              ],
            );
          },
        ),
        Divider(color: themeData.colorScheme.onBackground),
        ListView.builder(
          itemCount: widget.helper.terms.length,
          itemBuilder: (BuildContext context, int position) {
            final String term = widget.helper.terms[position];
            return KeyedSubtree(
              key: ValueKey<String>(term),
              child: ListTile(
                trailing: Tooltip(
                  message: appLocalizations
                      .edit_product_form_item_remove_item_tooltip,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      if (widget.helper.removeTerm(term)) {
                        setState(() {});
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MEDIUM_SPACE,
                        vertical: SMALL_SPACE,
                      ),
                      child: Icon(Icons.delete),
                    ),
                  ),
                ),
                contentPadding: const EdgeInsetsDirectional.only(
                  start: LARGE_SPACE,
                ),
                title: Text(term),
              ),
            );
          },
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
      ],
    );
  }
}

// TODO(monsieurtanuki): put it in its own file as it's not private anymore.
class SimpleInputWidgetField extends StatelessWidget {
  const SimpleInputWidgetField({
    required this.focusNode,
    required this.autocompleteKey,
    required this.constraints,
    required this.tagType,
    required this.hintText,
    required this.controller,
  });

  final FocusNode focusNode;
  final Key autocompleteKey;
  final BoxConstraints constraints;
  final TagType? tagType;
  final String hintText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: LARGE_SPACE),
      child: RawAutocomplete<String>(
        key: autocompleteKey,
        focusNode: focusNode,
        textEditingController: controller,
        optionsBuilder: (final TextEditingValue value) async {
          final List<String> result = <String>[];
          final String input = value.text.trim();

          if (input.isEmpty) {
            return result;
          }

          if (tagType == null) {
            return result;
          }

          // TODO(monsieurtanuki): ask off-dart to return Strings instead of dynamic?
          final List<dynamic> data =
              await OpenFoodAPIClient.getAutocompletedSuggestions(
            tagType!,
            language: ProductQuery.getLanguage()!,
            limit: 1000000, // lower max count on the server anyway
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
              borderRadius: ANGULAR_BORDER_RADIUS,
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: SMALL_SPACE,
              vertical: SMALL_SPACE,
            ),
            hintText: hintText,
          ),
          autofocus: true,
          focusNode: focusNode,
        ),
        optionsViewBuilder: (
          BuildContext lContext,
          AutocompleteOnSelected<String> onSelected,
          Iterable<String> options,
        ) {
          final double screenHeight = MediaQuery.of(context).size.height;
          final double keyboardHeight =
              MediaQuery.of(lContext).viewInsets.bottom;

          final double widgetPosition =
              (context.findRenderObject() as RenderBox?)
                      ?.localToGlobal(Offset.zero)
                      .dy ??
                  0.0;

          return AutocompleteOptions<String>(
            displayStringForOption: RawAutocomplete.defaultStringForOption,
            onSelected: onSelected,
            options: options,
            // Width = Row width - horizontal padding
            maxOptionsWidth: constraints.maxWidth - (LARGE_SPACE * 2),
            maxOptionsHeight: screenHeight -
                (keyboardHeight == 0
                    ? kBottomNavigationBarHeight
                    : keyboardHeight) -
                widgetPosition -
                // Vertical padding
                (LARGE_SPACE * 2) -
                // Height of the TextField
                (DefaultTextStyle.of(context).style.fontSize ?? 0) -
                // Elevation
                4.0,
          );
        },
      ),
    );
  }
}
