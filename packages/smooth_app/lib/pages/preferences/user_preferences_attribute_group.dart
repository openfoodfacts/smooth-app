import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences/attribute_group_list_tile.dart';
import 'package:smooth_app/widgets/attribute_button.dart';

/// Collapsed/expanded display of an attribute group for the preferences page.
class UserPreferencesAttributeGroup {
  UserPreferencesAttributeGroup({
    required this.productPreferences,
    required this.group,
    required this.context,
    required this.userPreferences,
    required this.appLocalizations,
    required this.themeData,
  });

  final BuildContext context;
  final UserPreferences userPreferences;
  final AppLocalizations appLocalizations;
  final ThemeData themeData;

  final ProductPreferences productPreferences;
  final AttributeGroup group;

  bool get _isCollapsed => userPreferences.activeAttributeGroup != group.id;

  List<Widget> getContent() {
    final List<Widget> result = <Widget>[];
    result.add(
      InkWell(
        onTap: () async => userPreferences.setActiveAttributeGroup(group.id!),
        child: AttributeGroupListTile(
          title: Text(
            group.name ?? appLocalizations.unknown,
            style: themeData.textTheme.titleLarge,
          ),
          icon: _isCollapsed
              ? const Icon(Icons.keyboard_arrow_right)
              : const Icon(Icons.keyboard_arrow_down),
        ),
      ),
    );
    if (_isCollapsed) {
      return result;
    }
    if (group.warning != null) {
      result.add(
        Container(
          color: Theme.of(context).colorScheme.error,
          width: double.infinity,
          padding: const EdgeInsets.all(LARGE_SPACE),
          margin: const EdgeInsets.all(LARGE_SPACE),
          child: Text(
            group.warning ?? appLocalizations.unknown,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
        ),
      );
    }
    final List<String> excludedAttributeIds =
        userPreferences.getExcludedAttributeIds();
    for (final Attribute attribute in group.attributes!) {
      if (excludedAttributeIds.contains(attribute.id)) {
        continue;
      }
      result.add(AttributeButton(attribute, productPreferences));
    }
    return result;
  }
}
