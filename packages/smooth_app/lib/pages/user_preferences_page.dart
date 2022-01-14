import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/abstract_user_preferences.dart';
import 'package:smooth_app/pages/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/user_preferences_food.dart';
import 'package:smooth_app/pages/user_preferences_profile.dart';
import 'package:smooth_app/pages/user_preferences_settings.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Preferences page for attribute importances
class UserPreferencesPage extends StatefulWidget {
  const UserPreferencesPage();

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

    final List<AbstractUserPreferences> items = <AbstractUserPreferences>[
      UserPreferencesProfile(
        setState: setState,
        context: context,
        userPreferences: userPreferences,
        appLocalizations: appLocalizations,
        themeData: themeData,
      ),
      UserPreferencesFood(
        productPreferences: productPreferences,
        setState: setState,
        context: context,
        userPreferences: userPreferences,
        appLocalizations: appLocalizations,
        themeData: themeData,
      ),
      UserPreferencesSettings(
        themeProvider: themeProvider,
        setState: setState,
        context: context,
        userPreferences: userPreferences,
        appLocalizations: appLocalizations,
        themeData: themeData,
      ),
    ];
    if (userPreferences.devMode > 0) {
      items.add(
        UserPreferencesDevMode(
          setState: setState,
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        ),
      );
    }
    final List<Widget> children = <Widget>[];
    for (final AbstractUserPreferences abstractUserPreferences in items) {
      children.addAll(abstractUserPreferences.getContent());
    }
    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.myPreferences)),
      body: ListView(children: children),
    );
  }
}
