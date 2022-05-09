import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/abstract_user_preferences.dart';
import 'package:smooth_app/pages/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/user_preferences_food.dart';
import 'package:smooth_app/pages/user_preferences_profile.dart';
import 'package:smooth_app/pages/user_preferences_settings.dart';
import 'package:smooth_app/themes/theme_provider.dart';

enum PreferencePageType {
  PROFILE,
  FOOD,
  DEV_MODE,
  SETTINGS,
}

/// Preferences page: main or detailed.
class UserPreferencesPage extends StatefulWidget {
  const UserPreferencesPage({this.type});

  /// Detailed page if not null, or else main page.
  final PreferencePageType? type;

  @override
  State<UserPreferencesPage> createState() => _UserPreferencesPageState();
}

class _UserPreferencesPageState extends State<UserPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final ThemeData themeData = Theme.of(context);
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();

    AbstractUserPreferences getUserPreferences(final PreferencePageType type) {
      switch (type) {
        case PreferencePageType.PROFILE:
          return UserPreferencesProfile(
            setState: setState,
            context: context,
            userPreferences: userPreferences,
            appLocalizations: appLocalizations,
            themeData: themeData,
          );
        case PreferencePageType.FOOD:
          return UserPreferencesFood(
            productPreferences: productPreferences,
            setState: setState,
            context: context,
            userPreferences: userPreferences,
            appLocalizations: appLocalizations,
            themeData: themeData,
          );
        case PreferencePageType.SETTINGS:
          return UserPreferencesSettings(
            themeProvider: themeProvider,
            setState: setState,
            context: context,
            userPreferences: userPreferences,
            appLocalizations: appLocalizations,
            themeData: themeData,
          );
        case PreferencePageType.DEV_MODE:
          return UserPreferencesDevMode(
            setState: setState,
            context: context,
            userPreferences: userPreferences,
            appLocalizations: appLocalizations,
            themeData: themeData,
          );
      }
    }

    final String appBarTitle;
    final List<Widget> children = <Widget>[];
    if (widget.type == null) {
      final List<PreferencePageType> items = <PreferencePageType>[
        PreferencePageType.PROFILE,
        PreferencePageType.FOOD,
        PreferencePageType.SETTINGS,
        if (userPreferences.devMode > 0) PreferencePageType.DEV_MODE,
      ];
      for (final PreferencePageType type in items) {
        children.add(getUserPreferences(type).getOnlyHeader());
      }
      appBarTitle = appLocalizations.myPreferences;
    } else {
      final AbstractUserPreferences abstractUserPreferences =
          getUserPreferences(widget.type!);
      children.addAll(abstractUserPreferences.getContent(withHeader: false));
      appBarTitle = abstractUserPreferences.getTitleString();
    }
    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0.0, MEDIUM_SPACE, 0.0, 0.0),
        children: children,
      ),
    );
  }
}
