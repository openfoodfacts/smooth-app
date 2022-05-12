import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Collapsed/expanded display of settings for the preferences page.
class UserPreferencesSettings extends AbstractUserPreferences {
  UserPreferencesSettings({
    required final Function(Function()) setState,
    required final BuildContext context,
    required final UserPreferences userPreferences,
    required final AppLocalizations appLocalizations,
    required final ThemeData themeData,
    required this.themeProvider,
  }) : super(
          setState: setState,
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );

  final ThemeProvider themeProvider;

  static const List<String> _ORDERED_COLOR_TAGS = <String>[
    SmoothTheme.COLOR_TAG_BLUE,
    SmoothTheme.COLOR_TAG_GREEN,
    SmoothTheme.COLOR_TAG_BROWN,
  ];

  @override
  PreferencePageType? getPreferencePageType() => PreferencePageType.SETTINGS;

  @override
  String getTitleString() => appLocalizations.myPreferences_settings_title;

  @override
  Widget? getSubtitle() =>
      Text(appLocalizations.myPreferences_settings_subtitle);
  @override
  List<Widget> getBody() => <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LARGE_SPACE,
            vertical: MEDIUM_SPACE,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                appLocalizations.darkmode,
                style: themeData.textTheme.headline4,
              ),
              DropdownButton<String>(
                value: themeProvider.currentTheme,
                elevation: 16,
                onChanged: (String? newValue) {
                  themeProvider.setTheme(newValue!);
                },
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: THEME_SYSTEM_DEFAULT,
                    child: Text(appLocalizations.darkmode_system_default),
                  ),
                  DropdownMenuItem<String>(
                    value: THEME_LIGHT,
                    child: Text(appLocalizations.darkmode_light),
                  ),
                  DropdownMenuItem<String>(
                    value: THEME_DARK,
                    child: Text(appLocalizations.darkmode_dark),
                  )
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: LARGE_SPACE),
          child: Text(
            appLocalizations.main_app_color,
            style: themeData.textTheme.headline4,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LARGE_SPACE,
            vertical: VERY_SMALL_SPACE,
          ),
          child: Wrap(
            spacing: 8.0,
            children: List<Widget>.generate(
              _ORDERED_COLOR_TAGS.length,
              (final int index) => _getColorButton(
                themeData.colorScheme,
                _ORDERED_COLOR_TAGS[index],
                themeProvider,
              ),
            ),
          ),
        ),
      ];

  Widget _getColorButton(
    final ColorScheme colorScheme,
    final String colorTag,
    final ThemeProvider themeProvider,
  ) =>
      TextButton(
        onPressed: () async => themeProvider.setColorTag(colorTag),
        style: TextButton.styleFrom(
          backgroundColor: SmoothTheme.getColor(
            colorScheme,
            SmoothTheme.MATERIAL_COLORS[colorTag]!,
            ColorDestination.BUTTON_BACKGROUND,
          ),
        ),
        child: Icon(
          Icons.palette,
          color: SmoothTheme.getColor(
            colorScheme,
            SmoothTheme.MATERIAL_COLORS[colorTag]!,
            ColorDestination.BUTTON_FOREGROUND,
          ),
        ),
      );
}
