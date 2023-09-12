import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';

class UserPreferencesCrashReporting extends StatelessWidget {
  const UserPreferencesCrashReporting();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    return UserPreferencesSwitchItem(
      title: appLocalizations.crash_reporting_toggle_title,
      subtitle: appLocalizations.crash_reporting_toggle_subtitle,
      value: userPreferences.crashReports,
      onChanged: (final bool value) async =>
          userPreferences.setCrashReports(value),
    );
  }
}
