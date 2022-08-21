import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/TagType.dart';
import 'package:provider/provider.dart';
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
  });

  final AbstractSimpleInputPageHelper helper;
  final Product product;

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
                  child: _SimpleInputWidgetField(
                    autocompleteKey: _autocompleteKey,
                    focusNode: _focusNode,
                    constraints: constraints,
                  ),
                ),
                const _SimpleInputWidgetFieldButton()
              ],
            );
          },
        ),
        Divider(color: themeData.colorScheme.onBackground),
        const _SimpleInputWidgetItems()
      ],
    );
  }

  static AbstractSimpleInputPageHelper helper(BuildContext context) =>
      Provider.of<AbstractSimpleInputPageHelper>(context, listen: false);

  static TextEditingController controller(
    BuildContext context, {
    bool listen = false,
  }) =>
      Provider.of<TextEditingController>(
        context,
        listen: listen,
      );
}

class _SimpleInputWidgetField extends StatelessWidget {
  const _SimpleInputWidgetField({
    required this.focusNode,
    required this.autocompleteKey,
    required this.constraints,
    Key? key,
  }) : super(key: key);

  final FocusNode focusNode;
  final Key autocompleteKey;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final AbstractSimpleInputPageHelper helper = _SimpleInputWidgetState.helper(
      context,
    );

    return Padding(
      padding: const EdgeInsets.only(left: LARGE_SPACE),
      child: RawAutocomplete<String>(
        key: autocompleteKey,
        focusNode: focusNode,
        textEditingController: _SimpleInputWidgetState.controller(
          context,
          listen: true,
        ),
        optionsBuilder: (final TextEditingValue value) async {
          final List<String> result = <String>[];
          final String input = value.text.trim();

          if (input.isEmpty) {
            return result;
          }

          final TagType? tagType = helper.getTagType();
          if (tagType == null) {
            return result;
          }

          // TODO(monsieurtanuki): ask off-dart to return Strings instead of dynamic?
          final List<dynamic> data =
              await OpenFoodAPIClient.getAutocompletedSuggestions(
            tagType,
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
            hintText: helper.getAddHint(appLocalizations),
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
          displayStringForOption: RawAutocomplete.defaultStringForOption,
          onSelected: onSelected,
          options: options,
          // Width = Row width - horizontal padding
          maxOptionsWidth: constraints.maxWidth - (LARGE_SPACE * 2),
          maxOptionsHeight: MediaQuery.of(context).size.height / 2,
        ),
      ),
    );
  }
}

class _SimpleInputWidgetFieldButton extends StatelessWidget {
  const _SimpleInputWidgetFieldButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TextEditingController>(
      builder: (BuildContext context, TextEditingController controller,
          Widget? child) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);
        final bool hasValue = controller.text.trim().isNotEmpty;

        return Tooltip(
          message: !hasValue
              ? appLocalizations.edit_product_form_item_add_invalid_item_tooltip
              : appLocalizations.edit_product_form_item_add_valid_item_tooltip,
          child: IconButton(
            onPressed: hasValue
                ? () {
                    _SimpleInputWidgetState.helper(context)
                        .addItemsFromController(
                      controller,
                    );
                  }
                : null,
            icon: const Icon(Icons.add_circle),
          ),
        );
      },
    );
  }
}

class _SimpleInputWidgetItems extends StatelessWidget {
  const _SimpleInputWidgetItems();

  @override
  Widget build(BuildContext context) {
    return Consumer<AbstractSimpleInputPageHelper>(
      builder: (BuildContext context, AbstractSimpleInputPageHelper helper, _) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);

        return ListView.builder(
          itemCount: helper.terms.length,
          itemBuilder: (BuildContext context, int position) {
            final String term = helper.terms[position];
            return KeyedSubtree(
              key: ValueKey<String>(term),
              child: ListTile(
                trailing: Tooltip(
                  message: appLocalizations
                      .edit_product_form_item_remove_item_tooltip,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => helper.removeTerm(term),
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
        );
      },
    );
  }
}
