import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences/attribute_group_list_tile.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
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

  // TODO(monsieurtanuki): double-check if it could be used/useful
  List<String> getLabels() {
    final List<String> result = <String>[];
    if (group.name != null) {
      result.add(group.name!);
    }
    if (group.warning != null) {
      result.add(group.warning!);
    }
    final List<String> excludedAttributeIds =
        userPreferences.getExcludedAttributeIds();
    for (final Attribute attribute in group.attributes!) {
      if (excludedAttributeIds.contains(attribute.id)) {
        continue;
      }
      if (attribute.settingNote != null) {
        result.add(attribute.settingNote!);
      }
      if (attribute.settingName != null) {
        result.add(attribute.settingName!);
      }
      if (attribute.id != null) {
        result.add(attribute.id!);
      }
      if (attribute.name != null) {
        result.add(attribute.name!);
      }
    }
    return result;
  }

  List<Widget> getContent() {
    final List<Widget> result = <Widget>[];
    for (final UserPreferencesItem item in getItems()) {
      result.add(item.builder(context));
    }
    return result;
  }

  List<UserPreferencesItem> getItems({bool? collapsed}) {
    collapsed ??= _isCollapsed;
    final List<UserPreferencesItem> result = <UserPreferencesItem>[];
    result.add(
      UserPreferencesItemSimple(
        labels: <String>[],
        builder: (_) => InkWell(
          onTap: () async => userPreferences.setActiveAttributeGroup(group.id!),
          child: AttributeGroupListTile(
            title: Text(
              group.name ?? appLocalizations.unknown,
              style: themeData.textTheme.titleLarge,
            ),
            icon: collapsed!
                ? const Icon(Icons.keyboard_arrow_right)
                : const Icon(Icons.keyboard_arrow_down),
          ),
        ),
      ),
    );
    if (collapsed) {
      return result;
    }
    if (group.warning != null) {
      result.add(
        UserPreferencesItemSimple(
          labels: <String>[group.warning!],
          builder: (final BuildContext context) {
            final ColorScheme colorScheme = Theme.of(context).colorScheme;
            return Container(
              color: colorScheme.error,
              width: double.infinity,
              padding: const EdgeInsets.all(LARGE_SPACE),
              margin: const EdgeInsets.all(LARGE_SPACE),
              child: Text(
                group.warning!,
                style: TextStyle(
                  color: colorScheme.onError,
                ),
              ),
            );
          },
        ),
      );
    }
    final List<String> excludedAttributeIds =
        userPreferences.getExcludedAttributeIds();
    for (final Attribute attribute in group.attributes!) {
      if (excludedAttributeIds.contains(attribute.id)) {
        continue;
      }
      result.add(
        UserPreferencesItemSimple(
          labels: <String>[
            if (attribute.settingNote != null) attribute.settingNote!,
            if (attribute.settingName != null) attribute.settingName!,
            if (attribute.id != null) attribute.id!,
            if (attribute.name != null) attribute.name!,
          ],
          builder: (_) => AttributeButton(attribute, productPreferences),
        ),
      );
    }
    return result;
  }
}
