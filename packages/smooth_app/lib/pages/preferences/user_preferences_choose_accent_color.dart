import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/color_schemes.dart';

class UserPreferencesChooseAccentColor extends StatelessWidget {
  const UserPreferencesChooseAccentColor();

  static UserPreferencesItem getUserPreferencesItem(
    final BuildContext context,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Map<String, String> labels = _localizedNames(appLocalizations);
    return UserPreferencesItemSimple(
      labels: <String>[appLocalizations.select_accent_color, ...labels.values],
      builder: (_) => const UserPreferencesChooseAccentColor(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ColorProvider colorProvider = context.watch<ColorProvider>();
    final Map<String, String> labels = _localizedNames(appLocalizations);

    return UserPreferencesMultipleChoicesItem<String>(
      title: appLocalizations.select_accent_color,
      leadingBuilder: labels.keys.map(
        (String key) =>
            (_) => CircleAvatar(
              backgroundColor: getColorValue(key),
              radius: SMALL_SPACE,
            ),
      ),
      labels: labels.values,
      values: labels.keys,
      currentValue: colorProvider.currentColor,
      onChanged: (String? newValue) => colorProvider.setColor(newValue!),
    );
  }

  static Map<String, String> _localizedNames(
    AppLocalizations appLocalizations,
  ) => <String, String>{
    'Blue': appLocalizations.color_blue,
    'Cyan': appLocalizations.color_cyan,
    'Green': appLocalizations.color_green,
    'Default': appLocalizations.color_light_brown,
    'Magenta': appLocalizations.color_magenta,
    'Orange': appLocalizations.color_orange,
    'Pink': appLocalizations.color_pink,
    'Red': appLocalizations.color_red,
    'Rust': appLocalizations.color_rust,
    'Teal': appLocalizations.color_teal,
  };
}
