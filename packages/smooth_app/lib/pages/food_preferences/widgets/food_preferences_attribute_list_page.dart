import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/food_preferences/food_preferences_controller.dart';
import 'package:smooth_app/pages/food_preferences/models/food_preferences_attribute_config.dart';
import 'package:smooth_app/pages/food_preferences/widgets/food_preference_attribute_row.dart';
import 'package:smooth_app/pages/food_preferences/widgets/food_preferences_search_bar.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class FoodPreferencesAttributeListPage extends StatefulWidget {
  const FoodPreferencesAttributeListPage({
    required this.pageType,
    this.headerWidget,
    this.footerWidget,
    this.emptyStateWidget,
    this.showSearchBar = true,
    super.key,
  });

  final FoodPreferencesPageType pageType;
  final Widget? headerWidget;
  final Widget? footerWidget;
  final Widget? emptyStateWidget;
  final bool showSearchBar;

  @override
  State<FoodPreferencesAttributeListPage> createState() =>
      _FoodPreferencesAttributeListPageState();
}

class _FoodPreferencesAttributeListPageState
    extends State<FoodPreferencesAttributeListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductPreferences>(
      builder:
          (
            BuildContext context,
            ProductPreferences productPreferences,
            Widget? child,
          ) {
            final List<AttributeGroup>? allGroups =
                productPreferences.attributeGroups;

            if (allGroups == null || allGroups.isEmpty) {
              return _buildLoadingState();
            }

            final List<Attribute> allAttributes =
                FoodPreferencesAttributeConfig.getAttributesForPage(
                  allGroups,
                  widget.pageType,
                );

            if (allAttributes.isEmpty) {
              return widget.emptyStateWidget ?? _buildEmptyState();
            }

            final List<Attribute> filteredAttributes = _filterAttributes(
              allAttributes,
              _searchQuery,
            );

            return Column(
              children: <Widget>[
                if (widget.headerWidget != null || widget.showSearchBar)
                  widget.headerWidget!,
                if (widget.showSearchBar) _buildSearchBar(context),
                Expanded(
                  child: filteredAttributes.isEmpty && _searchQuery.isNotEmpty
                      ? _buildNoResultsState()
                      : _buildAttributeList(
                          context,
                          productPreferences,
                          filteredAttributes,
                        ),
                ),
              ],
            );
          },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SMALL_SPACE,
        vertical: MEDIUM_SPACE,
      ),
      child: FoodPreferencesSearchBar(
        controller: _searchController,
        onSearchChanged: (String query) {
          setState(() {
            _searchQuery = query.toLowerCase().trim();
          });
        },
      ),
    );
  }

  List<Attribute> _filterAttributes(List<Attribute> attributes, String query) {
    if (query.isEmpty) {
      return attributes;
    }

    return attributes.where((Attribute attribute) {
      final String name = (attribute.name ?? '').toLowerCase();
      final String settingName = (attribute.settingName ?? '').toLowerCase();
      final String settingNote = (attribute.settingNote ?? '').toLowerCase();
      final String id = (attribute.id ?? '').toLowerCase();

      return name.contains(query) ||
          settingName.contains(query) ||
          settingNote.contains(query) ||
          id.contains(query);
    }).toList();
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(LARGE_SPACE),
        child: Text('No preferences available for this category.'),
      ),
    );
  }

  Widget _buildNoResultsState() {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LARGE_SPACE),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const icons.Search(size: 48.0, color: Colors.grey),
            const SizedBox(height: MEDIUM_SPACE),
            Text(
              appLocalizations.no_product_found,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeList(
    BuildContext context,
    ProductPreferences productPreferences,
    List<Attribute> attributes,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        vertical: MEDIUM_SPACE,
        horizontal: VERY_LARGE_SPACE,
      ),
      itemCount: _calculateItemCount(attributes.length),
      itemBuilder: (BuildContext context, int index) {
        if (widget.footerWidget != null && index >= attributes.length) {
          return widget.footerWidget!;
        }

        if (index < attributes.length) {
          final Attribute attribute = attributes[index];

          return _FoodPreferenceAttributeRowWithState(
            attribute: attribute,
            productPreferences: productPreferences,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  int _calculateItemCount(int attributeCount) {
    int count = attributeCount;
    if (widget.footerWidget != null) {
      count += 1;
    }
    return count;
  }
}

class _FoodPreferenceAttributeRowWithState extends StatelessWidget {
  const _FoodPreferenceAttributeRowWithState({
    required this.attribute,
    required this.productPreferences,
  });

  final Attribute attribute;
  final ProductPreferences productPreferences;

  static const String _enabledImportanceId = PreferenceImportance.ID_IMPORTANT;

  static const String _disabledImportanceId =
      PreferenceImportance.ID_NOT_IMPORTANT;

  @override
  Widget build(BuildContext context) {
    final String? attributeId = attribute.id;
    if (attributeId == null) {
      return const SizedBox.shrink();
    }

    final String currentImportanceId = productPreferences
        .getImportanceIdForAttributeId(attributeId);

    final bool isEnabled =
        currentImportanceId != PreferenceImportance.ID_NOT_IMPORTANT;

    return FoodPreferenceAttributeRow(
      attribute: attribute,
      isEnabled: isEnabled,
      onChanged: (bool value) {
        productPreferences.setImportance(
          attributeId,
          value ? _enabledImportanceId : _disabledImportanceId,
        );
      },
    );
  }
}
