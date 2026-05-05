import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/food_preferences/models/pending_preferences.dart';
import 'package:smooth_app/pages/food_preferences/widgets/food_preference_attribute_row.dart';
import 'package:smooth_app/pages/food_preferences/widgets/food_preferences_search_bar.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/widgets/smooth_banner.dart';

class AttributeGroupPage extends StatefulWidget {
  const AttributeGroupPage({
    required this.attributeGroup,
    this.showSearchBar = true,
    super.key,
  });

  final AttributeGroup attributeGroup;
  final bool showSearchBar;

  @override
  State<AttributeGroupPage> createState() => _AttributeGroupPageState();
}

class _AttributeGroupPageState extends State<AttributeGroupPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<PendingPreferences>(
      builder:
          (
            BuildContext context,
            PendingPreferences pendingPreferences,
            Widget? child,
          ) {
            final List<Attribute> allAttributes =
                widget.attributeGroup.attributes ?? <Attribute>[];

            if (allAttributes.isEmpty) {
              return _buildEmptyState();
            }

            final List<Attribute> filteredAttributes = _filterAttributes(
              allAttributes,
              _searchQuery,
            );

            return Column(
              children: <Widget>[
                if (widget.showSearchBar) _buildSearchBar(context),
                Expanded(
                  child: filteredAttributes.isEmpty && _searchQuery.isNotEmpty
                      ? _buildNoResultsState()
                      : _buildAttributeList(
                          context,
                          pendingPreferences,
                          filteredAttributes,
                        ),
                ),
                if (widget.attributeGroup.warning != null)
                  _buildWarningBanner(context, widget.attributeGroup.warning!),
              ],
            );
          },
    );
  }

  Widget _buildWarningBanner(BuildContext context, String warning) {
    return SmoothBanner(
      icon: const icons.Info(size: DEFAULT_ICON_SIZE),
      content: warning,
      borderRadius: const BorderRadiusDirectional.vertical(top: ROUNDED_RADIUS),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: SMALL_SPACE,
        end: SMALL_SPACE,
        top: MEDIUM_SPACE,
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

    return attributes
        .where((Attribute attribute) {
          final String name = (attribute.name ?? '').toLowerCase();
          final String settingName = (attribute.settingName ?? '')
              .toLowerCase();
          final String settingNote = (attribute.settingNote ?? '')
              .toLowerCase();
          final String id = (attribute.id ?? '').toLowerCase();

          return name.contains(query) ||
              settingName.contains(query) ||
              settingNote.contains(query) ||
              id.contains(query);
        })
        .toList(growable: false);
  }

  Widget _buildEmptyState() {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(LARGE_SPACE),
        child: Text(appLocalizations.food_preferences_empty_state),
      ),
    );
  }

  Widget _buildNoResultsState() {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(LARGE_SPACE),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: MEDIUM_SPACE,
          children: <Widget>[
            const icons.Search(size: 48.0, color: Colors.grey),
            Text(
              appLocalizations.no_product_found,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeList(
    BuildContext context,
    PendingPreferences pendingPreferences,
    List<Attribute> attributes,
  ) {
    return ListView.builder(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: VERY_LARGE_SPACE,
        vertical: MEDIUM_SPACE,
      ),
      itemCount: attributes.length,
      itemBuilder: (BuildContext context, int index) {
        final Attribute attribute = attributes[index];
        return FoodPreferenceAttributeRow(
          attribute: attribute,
          pendingPreferences: pendingPreferences,
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
