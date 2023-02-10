import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/product/explanation_widget.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/pages/product/simple_input_text_field.dart';

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
    final String? explanations =
        widget.helper.getAddExplanations(appLocalizations);

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
            style: themeData.textTheme.displaySmall,
          ),
        ),
        if (explanations != null) ExplanationWidget(explanations),
        LayoutBuilder(
          builder: (_, BoxConstraints constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: SimpleInputTextField(
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
