import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/settings_page.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/widgets/attribute_button.dart';

/// Preferences page for attribute importances
class UserPreferencesPage extends StatelessWidget {
  const UserPreferencesPage();

  static const List<String> _ORDERED_ATTRIBUTE_GROUP_IDS = <String>[
    AttributeGroup.ATTRIBUTE_GROUP_NUTRITIONAL_QUALITY,
    AttributeGroup.ATTRIBUTE_GROUP_INGREDIENT_ANALYSIS,
    AttributeGroup.ATTRIBUTE_GROUP_ENVIRONMENT,
    AttributeGroup.ATTRIBUTE_GROUP_PROCESSING,
    AttributeGroup.ATTRIBUTE_GROUP_LABELS,
    AttributeGroup.ATTRIBUTE_GROUP_ALLERGENS,
  ];

  static const double _TYPICAL_PADDING_OR_MARGIN = 12;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final List<AttributeGroup> groups =
        _reorderGroups(productPreferences.attributeGroups!);
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.myPreferences),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.rotate_left),
            tooltip: appLocalizations.reset,
            onPressed: () => _confirmReset(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: appLocalizations.settingsTitle,
            onPressed: () => Navigator.push<Widget>(
              context,
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) => const ProfilePage(),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: List<Widget>.generate(
          groups.length,
          (int index) => _generateGroup(
            context,
            index,
            groups[index],
            userPreferences,
            productPreferences,
          ),
        ),
      ),
    );
  }

  Widget _generateGroup(
    final BuildContext context,
    int index,
    final AttributeGroup group,
    final UserPreferences userPreferences,
    final ProductPreferences productPreferences,
  ) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(_TYPICAL_PADDING_OR_MARGIN),
          child: ListTile(
            title: Text(
              group.name ?? 'Unknown',
              style: theme.textTheme.headline3,
            ),
            trailing: index != 0
                ? null
                : Text(
                    localizations.important,
                    style: theme.textTheme.headline3,
                  ),
          ),
        ),
        if (group.warning != null)
          Container(
            color: SmoothTheme.getColor(
              theme.colorScheme,
              AttributeButton.WARNING_COLOR,
              ColorDestination.BUTTON_BACKGROUND,
            ),
            width: double.infinity,
            padding: const EdgeInsets.all(_TYPICAL_PADDING_OR_MARGIN),
            margin: const EdgeInsets.all(_TYPICAL_PADDING_OR_MARGIN),
            child: Text(
              group.warning ?? 'Unknown',
              style: TextStyle(
                color: SmoothTheme.getColor(
                  theme.colorScheme,
                  AttributeButton.WARNING_COLOR,
                  ColorDestination.BUTTON_FOREGROUND,
                ),
              ),
            ),
          ),
        ...List<Widget>.generate(
          group.attributes!.length,
          (int index) => Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: _AttributeListTile(group.attributes![index]),
          ),
        ),
      ],
    );
  }

  void _confirmReset(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.confirmResetPreferences),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.yes),
              onPressed: () async {
                await context.read<ProductPreferences>().resetImportances();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(localizations.no),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  List<AttributeGroup> _reorderGroups(List<AttributeGroup> groups) {
    final List<AttributeGroup> result = <AttributeGroup>[];
    for (final String id in _ORDERED_ATTRIBUTE_GROUP_IDS) {
      result.addAll(groups.where((AttributeGroup g) => g.id == id));
    }
    result.addAll(groups.where(
        (AttributeGroup g) => !_ORDERED_ATTRIBUTE_GROUP_IDS.contains(g.id)));
    return result;
  }
}

class _AttributeListTile extends StatelessWidget {
  const _AttributeListTile(this.attribute);

  final Attribute attribute;

  @override
  Widget build(BuildContext context) {
    final ProductPreferences preferences = context.watch<ProductPreferences>();
    final bool isImportant =
        preferences.getImportanceIdForAttributeId(attribute.id!) !=
            PreferenceImportance.ID_NOT_IMPORTANT;
    return SwitchListTile(
      title: Text(attribute.name!),
      secondary: SvgCache(attribute.iconUrl, width: 40),
      value: isImportant,
      onChanged: (bool value) => _setImportance(context, value),
    );
  }

  void _setImportance(BuildContext context, bool isImportant) {
    final ProductPreferences preferences = context.read<ProductPreferences>();
    preferences.setImportance(
      attribute.id!,
      isImportant
          ? PreferenceImportance.ID_IMPORTANT
          : PreferenceImportance.ID_NOT_IMPORTANT,
    );
  }
}
