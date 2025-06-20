import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class UserPreferencesChooseAppTheme extends StatelessWidget {
  const UserPreferencesChooseAppTheme();

  static UserPreferencesItem getUserPreferencesItem(
    final BuildContext context,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return UserPreferencesItemSimple(
      labels: <String>[
        appLocalizations.darkmode,
        appLocalizations.darkmode_system_default,
        appLocalizations.darkmode_light,
        appLocalizations.darkmode_dark,
        appLocalizations.theme_amoled,
      ],
      builder: (_) => const UserPreferencesChooseAppTheme(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();

    return UserPreferencesMultipleChoicesItem<String>(
      title: appLocalizations.darkmode,
      leadingBuilder: <WidgetBuilder>[
        (_) => const Icon(Icons.brightness_medium),
        (_) => const Icon(Icons.light_mode),
        (_) => const Icon(Icons.dark_mode_outlined),
        (_) => const Icon(Icons.dark_mode),
      ],
      labels: <String>[
        appLocalizations.darkmode_system_default,
        appLocalizations.darkmode_light,
        appLocalizations.darkmode_dark,
        appLocalizations.theme_amoled,
      ],
      values: const <String>[
        THEME_SYSTEM_DEFAULT,
        THEME_LIGHT,
        THEME_DARK,
        THEME_AMOLED,
      ],
      currentValue: themeProvider.currentTheme,
      onChanged: (String? newValue) => themeProvider.setTheme(newValue!),
    );
  }
}
