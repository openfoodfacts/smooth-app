import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/food_preferences/models/pending_preferences.dart';
import 'package:smooth_app/pages/input/smooth_autocomplete_text_field.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class UnwantedIngredientsInput extends StatefulWidget {
  const UnwantedIngredientsInput({required this.pendingPreferences, super.key});

  final PendingPreferences pendingPreferences;

  @override
  State<UnwantedIngredientsInput> createState() =>
      _UnwantedIngredientsInputState();
}

class _UnwantedIngredientsInputState extends State<UnwantedIngredientsInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final AutocompleteManager _autocompleteManager;
  final Key _autocompleteKey = UniqueKey();

  PendingPreferences get _pendingPreferences => widget.pendingPreferences;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _autocompleteManager = AutocompleteManager(
      TagTypeAutocompleter(
        tagType: TagType.INGREDIENTS,
        language: ProductQuery.getLanguage(),
        country: ProductQuery.getCountry(),
        user: ProductQuery.getReadUser(),
        limit: 15,
        uriHelper: ProductQuery.getUriProductHelper(
          productType: ProductType.food,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final List<String> unwantedIngredients =
        _pendingPreferences.unwantedIngredients;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: SmoothAutocompleteTextField(
                focusNode: _focusNode,
                controller: _controller,
                autocompleteKey: _autocompleteKey,
                hintText:
                    appLocalizations.food_preferences_search_ingredients_hint,
                manager: _autocompleteManager,
                constraints: const BoxConstraints(maxHeight: 48.0),
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: MEDIUM_SPACE,
                  vertical: SMALL_SPACE,
                ),
                onSelected: _addIngredient,
              ),
            ),
          ],
        ),
        if (unwantedIngredients.isNotEmpty) ...<Widget>[
          const SizedBox(height: SMALL_SPACE),
          Wrap(
            spacing: SMALL_SPACE,
            runSpacing: SMALL_SPACE,
            children: unwantedIngredients
                .map((String ingredient) {
                  return Chip(
                    label: Text(ingredient),
                    deleteIcon: const Icon(Icons.close, size: 18.0),
                    onDeleted: () => _removeIngredient(ingredient),
                    backgroundColor: theme.primaryMedium,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                })
                .toList(growable: false),
          ),
        ],
      ],
    );
  }

  void _addIngredient(String ingredient) {
    ingredient = ingredient.trim();
    if (ingredient.isEmpty) {
      return;
    }

    if (_pendingPreferences.isIngredientExcluded(ingredient)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).food_preferences_ingredient_already_added,
          ),
        ),
      );
      return;
    }

    _pendingPreferences.addUnwantedIngredient(ingredient);
    _controller.clear();
    _focusNode.unfocus();
  }

  void _removeIngredient(String ingredient) {
    _pendingPreferences.removeUnwantedIngredient(ingredient);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
