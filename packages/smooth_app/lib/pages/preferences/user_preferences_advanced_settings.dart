import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';

class UserPreferencesAdvancedSettings extends StatelessWidget {
  const UserPreferencesAdvancedSettings();

  static UserPreferencesItem getUserPreferencesItem(
    final BuildContext context,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return UserPreferencesItemSimple(
      labels: <String>[
        appLocalizations.native_app_settings,
        appLocalizations.native_app_description,
      ],
      builder: (_) => const UserPreferencesAdvancedSettings(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return UserPreferenceListTile(
      onTap: (_) async => AppSettings.openAppSettings(),
      title: appLocalizations.native_app_settings,
      subTitle: appLocalizations.native_app_description,
      leading: const Icon(CupertinoIcons.settings_solid),
      showDivider: true,
    );
  }
}
