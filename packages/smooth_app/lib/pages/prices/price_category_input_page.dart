import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/input/smooth_autocomplete_text_field.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page that lets the user type in and select a single category for prices.
class PriceCategoryInputPage extends StatefulWidget {
  const PriceCategoryInputPage();

  @override
  State<PriceCategoryInputPage> createState() => _PriceCategoryInputPageState();
}

class _PriceCategoryInputPageState extends State<PriceCategoryInputPage> {
  late final TextEditingController _controller;
  final AbstractSimpleInputPageHelper _helper = SimpleInputPageCategoryHelper();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final Key _autocompleteKey = UniqueKey();
  late final FocusNode _focusNode;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothScaffold(
      fixKeyboard: true,
      appBar: AppBar(
        title: Text(appLocalizations.prices_category_enter),
      ),
      body: Padding(
        padding: const EdgeInsets.all(SMALL_SPACE),
        child: LayoutBuilder(
          builder: (_,
              BoxConstraints constraints,) =>
              SmoothAutocompleteTextField(
                autocompleteKey: _autocompleteKey,
                focusNode: _focusNode,
                constraints: constraints,
                onSelected: (final String selected) =>
                    Navigator.of(context).pop(selected),
                manager: AutocompleteManager(
                  TagTypeAutocompleter(
                    tagType: _helper.getTagType()!,
                    language: ProductQuery.getLanguage(),
                    country: ProductQuery.getCountry(),
                    categories: null,
                    shape: null,
                    user: ProductQuery.getReadUser(),
                    limit: 15,
                    uriHelper: ProductQuery.getUriProductHelper(
                      productType: ProductType.food,
                    ),
                  ),
                ),
                textCapitalization: _helper.getTextCapitalization(),
                allowEmojis: _helper.getAllowEmojis(),
                hintText: _helper.getAddHint(appLocalizations),
                controller: _controller,
                padding: const EdgeInsets.symmetric(
                  horizontal: LARGE_SPACE,
                  vertical: MEDIUM_SPACE,
                ),
                borderRadius: CIRCULAR_BORDER_RADIUS,
              ),
        ),
      ),
    );
  }
}
