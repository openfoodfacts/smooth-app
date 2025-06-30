import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
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
    for (final UserPreferencesItem item in getItems()) {
      result.add(item.builder(context));
    }
    return result;
  }

  List<UserPreferencesItem> getItems({bool? collapsed}) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    collapsed ??= _isCollapsed;
    final List<UserPreferencesItem> result = <UserPreferencesItem>[];
    result.add(
      UserPreferencesItemSimple(
        labels: <String>[],
        builder: (_) => Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: LARGE_SPACE,
          ),
          child: SmoothCard(
            padding: EdgeInsetsDirectional.zero,
            margin: const EdgeInsetsDirectional.only(top: LARGE_SPACE),
            child: InkWell(
              onTap: () async =>
                  userPreferences.setActiveAttributeGroup(group.id!),
              child: ListTile(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadiusDirectional.vertical(
                    top: ROUNDED_RADIUS,
                  ),
                ),
                tileColor: extension.primaryBlack,
                leading: const SizedBox.square(
                  dimension: 18.0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadiusDirectional.all(ROUNDED_RADIUS),
                    ),
                  ),
                ),
                title: Text(
                  group.name ?? appLocalizations.unknown,
                  style: themeData.textTheme.titleLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: collapsed!
                    ? const Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
              ),
            ),
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
              padding: const EdgeInsetsDirectional.all(LARGE_SPACE),
              margin: const EdgeInsetsDirectional.all(LARGE_SPACE),
              child: Text(
                group.warning!,
                style: TextStyle(color: colorScheme.onError),
              ),
            );
          },
        ),
      );
    }
    final List<String> excludedAttributeIds = userPreferences
        .getExcludedAttributeIds();
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
          builder: (_) => Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: LARGE_SPACE,
            ),
            child: SmoothCard(
              elevation: 8,
              padding: EdgeInsetsDirectional.zero,
              borderRadius: const BorderRadiusDirectional.vertical(
                bottom: ROUNDED_RADIUS,
              ),
              color: extension.primaryBlack,
              margin: EdgeInsetsDirectional.zero,
              child: AttributeButton(
                attribute,
                productPreferences,
                isFirst:
                    attribute == group.attributes!.first &&
                    group.warning == null,
                isLast: attribute == group.attributes!.last,
              ),
            ),
          ),
        ),
      );
    }
    return result;
  }
}
