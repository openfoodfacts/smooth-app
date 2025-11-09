import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/attributes_card_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/user_preferences_food_search_helper.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
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
            horizontal: SMALL_SPACE,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(top: SMALL_SPACE),
            child: InkWell(
              borderRadius: const BorderRadius.vertical(top: ROUNDED_RADIUS),
              onTap: () => collapsed == true
                  ? userPreferences.setActiveAttributeGroup(group.id!)
                  : null,
              child: ListTile(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadiusDirectional.vertical(
                    top: ROUNDED_RADIUS,
                  ),
                ),

                tileColor: extension.primaryBlack,
                leading: const Padding(
                  padding: EdgeInsetsDirectional.only(start: 8.5),
                  child: SizedBox.square(
                    dimension: 14.0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadiusDirectional.all(
                          ROUNDED_RADIUS,
                        ),
                      ),
                    ),
                  ),
                ),
                title: Padding(
                  padding: const EdgeInsetsDirectional.only(start: SMALL_SPACE),
                  child: Text(
                    group.name ?? appLocalizations.unknown,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                trailing: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 7.0),
                  child: icons.AppIconTheme(
                    size: 10.0,
                    color: Colors.white,
                    child: collapsed!
                        ? const icons.Chevron.up()
                        : const icons.Chevron.down(),
                  ),
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
              padding: const EdgeInsetsDirectional.all(BALANCED_SPACE),
              margin: const EdgeInsetsDirectional.symmetric(
                horizontal: SMALL_SPACE,
              ),
              child: Text(
                group.warning!,
                style: TextStyle(color: colorScheme.onError),
                textAlign: TextAlign.center,
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
              horizontal: SMALL_SPACE,
            ),
            child: SmoothCard(
              elevation: 8.0,
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

  List<PreferenceTile> searchTiles(
    BuildContext context,
    UserPreferencesFoodSearchHelper helper,
  ) {
    final List<PreferenceTile> result = <PreferenceTile>[];

    if (group.name != null &&
        (helper.matches(<String?>[group.name, group.warning]))) {
      result.add(
        helper.getPreferenceTile(title: group.name!, context: context),
      );
    }
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    final Color backgroundColor = context.lightTheme()
        ? theme.primarySemiDark
        : theme.primaryUltraBlack;

    final List<String> excludedAttributeIds = userPreferences
        .getExcludedAttributeIds();
    for (final Attribute attribute in group.attributes!) {
      if (excludedAttributeIds.contains(attribute.id)) {
        continue;
      }
      if (attribute.name != null &&
          helper.matches(<String?>[
            attribute.settingNote,
            attribute.settingName,
            attribute.id,
            attribute.name,
          ])) {
        result.add(
          helper.getPreferenceTile(
            title: attribute.name!,
            context: context,
            icon: getAttributeDisplayIcon(
              attribute,
              context: context,
              isFoodPreferences: true,
              foregroundColor: Colors.white,
              backgroundColor: backgroundColor,
              size: 20.0,
            ),
          ),
        );
      }
    }
    return result;
  }
}
