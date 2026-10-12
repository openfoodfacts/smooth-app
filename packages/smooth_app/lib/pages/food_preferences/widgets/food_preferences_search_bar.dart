import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/common/search_helper.dart';
import 'package:smooth_app/pages/search/search_field.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class FoodPreferencesSearchHelper extends SearchHelper {
  FoodPreferencesSearchHelper({this.onSearchChanged});

  final void Function(String query)? onSearchChanged;

  @override
  String get historyKey => 'food_preferences_search';

  @override
  String getHintText(AppLocalizations appLocalizations) =>
      appLocalizations.search;

  @override
  String getHelpText(AppLocalizations appLocalizations) => '';

  @override
  void search(
    BuildContext context,
    String query, {
    required SearchQueryCallback searchQueryCallback,
  }) => onSearchChanged?.call(query);
}

class FoodPreferencesSearchBar extends StatefulWidget {
  const FoodPreferencesSearchBar({
    required this.controller,
    this.onSearchChanged,
    super.key,
  });

  final TextEditingController controller;

  final void Function(String query)? onSearchChanged;

  @override
  State<FoodPreferencesSearchBar> createState() =>
      _FoodPreferencesSearchBarState();
}

class _FoodPreferencesSearchBarState extends State<FoodPreferencesSearchBar> {
  late final FoodPreferencesSearchHelper _searchHelper;

  @override
  void initState() {
    super.initState();
    _searchHelper = FoodPreferencesSearchHelper(
      onSearchChanged: widget.onSearchChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    return ChangeNotifierProvider<TextEditingController>.value(
      value: widget.controller,
      child: SearchField(
        searchHelper: _searchHelper,
        showClearButton: true,
        searchOnChange: true,
        backgroundColor: theme.primaryMedium,
        borderColor: theme.primaryDark,
      ),
    );
  }
}
