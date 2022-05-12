import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences/abstract_collapsible_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/widgets/attribute_button.dart';

/// Collapsed/expanded display of an attribute group for the preferences page.
class UserPreferencesAttributeGroup extends AbstractCollapsibleUserPreferences {
  UserPreferencesAttributeGroup({
    required this.productPreferences,
    required this.group,
    required final Function(Function()) setState,
    required final BuildContext context,
    required final UserPreferences userPreferences,
    required final AppLocalizations appLocalizations,
    required final ThemeData themeData,
  }) : super(
          setState: setState,
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );

  final ProductPreferences productPreferences;
  final AttributeGroup group;

  @override
  PreferencePageType? getPreferencePageType() => null;

  @override
  String getPreferenceFlagKey() => 'attribute:${group.id}';

  @override
  String getTitleString() => group.name ?? appLocalizations.unknown;

  @override
  Widget getTitle() => Text(
        getTitleString(),
        style: themeData.textTheme.headline6,
      );

  @override
  Widget? getSubtitle() => null;

  @override
  List<Widget> getBody() {
    final List<Widget> result = <Widget>[];
    if (group.warning != null) {
      result.add(
        Container(
          color: SmoothTheme.getColor(
            Theme.of(context).colorScheme,
            WARNING_COLOR,
            ColorDestination.BUTTON_BACKGROUND,
          ),
          width: double.infinity,
          padding: const EdgeInsets.all(LARGE_SPACE),
          margin: const EdgeInsets.all(LARGE_SPACE),
          child: Text(
            group.warning ?? appLocalizations.unknown,
            style: TextStyle(
              color: SmoothTheme.getColor(
                Theme.of(context).colorScheme,
                WARNING_COLOR,
                ColorDestination.BUTTON_FOREGROUND,
              ),
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
