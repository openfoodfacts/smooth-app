import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/language_selector.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_card.dart';
import 'package:smooth_app/pages/onboarding/country_selector.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';
import 'package:smooth_app/pages/scan/camera_controller.dart';
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

  @override
  PreferencePageType? getPreferencePageType() => PreferencePageType.SETTINGS;

  @override
  String getTitleString() => appLocalizations.myPreferences_settings_title;

  @override
  Widget? getSubtitle() =>
      Text(appLocalizations.myPreferences_settings_subtitle);

  @override
  IconData getLeadingIconData() => Icons.handyman;

  @override
  List<Widget> getBody() => const <Widget>[
        _ApplicationSettings(),
        UserPreferencesListItemDivider(),
        _CameraSettings(),
        UserPreferencesListItemDivider(),
        _PrivacySettings(),
      ];
}

class _ApplicationSettings extends StatelessWidget {
  const _ApplicationSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final ThemeData themeData = Theme.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    return Column(
      children: <Widget>[
        UserPreferencesTitle(
          label: appLocalizations.settings_app_app,
        ),
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
        const UserPreferencesListItemDivider(),
        const _CountryPickerSetting(),
        const UserPreferencesListItemDivider(),
        ListTile(
          title: Text(
            appLocalizations.choose_app_language,
            style: Theme.of(context).textTheme.headline4,
          ),
          subtitle: LanguageSelectorSettings(
            userPreferences: userPreferences,
            appLocalizations: appLocalizations,
          ),
          minVerticalPadding: MEDIUM_SPACE,
        ),
        const UserPreferencesListItemDivider(),
      ],
    );
  }
}

class _CountryPickerSetting extends StatelessWidget {
  const _CountryPickerSetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    return ListTile(
      title: Text(
        appLocalizations.country_chooser_label,
        style: Theme.of(context).textTheme.headline4,
      ),
      subtitle: CountrySelector(
        initialCountryCode: userPreferences.userCountryCode,
        textStyle: Theme.of(context).textTheme.bodyText2,
      ),
      minVerticalPadding: MEDIUM_SPACE,
    );
  }
}

class _PrivacySettings extends StatelessWidget {
  const _PrivacySettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        UserPreferencesTitle(
          label: appLocalizations.settings_app_data,
        ),
        const _CrashReportingSetting(),
        const UserPreferencesListItemDivider(),
        const _SendAnonymousDataSetting(),
        _ExpandPanelHelper(
          title: appLocalizations.expand_nutrition_facts,
          subtitle: appLocalizations.expand_nutrition_facts_body,
          panelId: KnowledgePanelCard.PANEL_NUTRITION_TABLE_ID,
        ),
        _ExpandPanelHelper(
          title: appLocalizations.expand_ingredients,
          subtitle: appLocalizations.expand_ingredients_body,
          panelId: KnowledgePanelCard.PANEL_INGREDIENTS_ID,
        ),
      ],
    );
  }
}

class _SendAnonymousDataSetting extends StatefulWidget {
  const _SendAnonymousDataSetting({Key? key}) : super(key: key);

  @override
  State<_SendAnonymousDataSetting> createState() =>
      _SendAnonymousDataSettingState();
}

class _SendAnonymousDataSettingState extends State<_SendAnonymousDataSetting> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return UserPreferencesSwitchItem(
      title: appLocalizations.send_anonymous_data_toggle_title,
      subtitle: appLocalizations.send_anonymous_data_toggle_subtitle,
      value: !MatomoTracker.instance.getOptOut(),
      onChanged: (final bool allow) async {
        await AnalyticsHelper.setAnalyticsReports(allow);
        setState(() {});
      },
    );
  }
}

class _CrashReportingSetting extends StatelessWidget {
  const _CrashReportingSetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    return UserPreferencesSwitchItem(
      title: appLocalizations.crash_reporting_toggle_title,
      subtitle: appLocalizations.crash_reporting_toggle_subtitle,
      value: userPreferences.crashReports,
      onChanged: (final bool value) async {
        await userPreferences.setCrashReports(value);
        AnalyticsHelper.setCrashReports(value);
      },
    );
  }
}

class _CameraSettings extends StatelessWidget {
  const _CameraSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!CameraHelper.hasACamera) {
      return const SizedBox.shrink();
    }

    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        UserPreferencesTitle(
          label: appLocalizations.settings_app_camera,
        ),
        const _CameraHighResolutionPresetSetting(),
        const UserPreferencesListItemDivider(),
        const _CameraPlayScanSoundSetting(),
        const UserPreferencesListItemDivider(),
        if (Platform.isAndroid) ...const <Widget>[
          _CameraFocusModeSetting(),
          UserPreferencesListItemDivider(),
        ],
      ],
    );
  }
}

class _CameraHighResolutionPresetSetting extends StatelessWidget {
  const _CameraHighResolutionPresetSetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    return UserPreferencesSwitchItem(
      title: appLocalizations.camera_high_resolution_preset_toggle_title,
      subtitle: appLocalizations.camera_high_resolution_preset_toggle_subtitle,
      value: userPreferences.useVeryHighResolutionPreset,
      onChanged: (final bool value) async {
        await userPreferences.setUseVeryHighResolutionPreset(value);
      },
    );
  }
}

class _CameraFocusModeSetting extends StatelessWidget {
  const _CameraFocusModeSetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    return UserPreferencesMultipleChoicesItem<CameraFocusPointAlgorithm>(
      title: appLocalizations.camera_focus_point_algorithm_title,
      subtitle: appLocalizations.camera_focus_point_algorithm_subtitle(
        getReadableMode(
          appLocalizations,
          userPreferences.cameraFocusPointAlgorithm,
        ),
        getReadableDescription(
          appLocalizations,
          userPreferences.cameraFocusPointAlgorithm,
        ),
      ),
      values: CameraFocusPointAlgorithm.values,
      descriptions: getDescriptions(appLocalizations),
      labels: getLabels(appLocalizations),
      currentValue: userPreferences.cameraFocusPointAlgorithm,
      onChanged: (final CameraFocusPointAlgorithm value) async {
        await userPreferences.setCameraFocusAlgorithm(value);
      },
    );
  }

  String getReadableMode(
    AppLocalizations appLocalizations,
    CameraFocusPointAlgorithm cameraFocusPointAlgorithm,
  ) {
    switch (cameraFocusPointAlgorithm) {
      case CameraFocusPointAlgorithm.newAlgorithm:
        return appLocalizations
            .camera_focus_point_algorithm_value_new_algorithm_label;
      case CameraFocusPointAlgorithm.oldAlgorithm:
        return appLocalizations
            .camera_focus_point_algorithm_value_old_algorithm_label;
      case CameraFocusPointAlgorithm.auto:
      default:
        return appLocalizations.camera_focus_point_algorithm_value_auto_label;
    }
  }

  String getReadableDescription(
    AppLocalizations appLocalizations,
    CameraFocusPointAlgorithm cameraFocusPointAlgorithm,
  ) {
    switch (cameraFocusPointAlgorithm) {
      case CameraFocusPointAlgorithm.newAlgorithm:
        return appLocalizations
            .camera_focus_point_algorithm_value_new_algorithm_description;
      case CameraFocusPointAlgorithm.oldAlgorithm:
        return appLocalizations
            .camera_focus_point_algorithm_value_old_algorithm_description;
      case CameraFocusPointAlgorithm.auto:
      default:
        return appLocalizations
            .camera_focus_point_algorithm_value_auto_description;
    }
  }

  Iterable<String> getLabels(AppLocalizations appLocalizations) {
    return CameraFocusPointAlgorithm.values.map((CameraFocusPointAlgorithm e) {
      return getReadableMode(appLocalizations, e);
    });
  }

  Iterable<String> getDescriptions(AppLocalizations appLocalizations) {
    return CameraFocusPointAlgorithm.values.map((CameraFocusPointAlgorithm e) {
      return getReadableDescription(appLocalizations, e);
    });
  }
}

class _CameraPlayScanSoundSetting extends StatelessWidget {
  const _CameraPlayScanSoundSetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    return UserPreferencesSwitchItem(
      title: appLocalizations.camera_play_sound_title,
      subtitle: appLocalizations.camera_play_sound_subtitle,
      value: userPreferences.playCameraSound,
      onChanged: (final bool value) async {
        await userPreferences.setPlayCameraSound(value);
      },
    );
  }
}

class _ExpandPanelHelper extends StatelessWidget {
  const _ExpandPanelHelper({
    required this.title,
    required this.subtitle,
    required this.panelId,
  });

  final String title;
  final String subtitle;
  final String panelId;

  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final String flagTag = KnowledgePanelCard.getExpandFlagTag(panelId);
    return UserPreferencesSwitchItem(
      title: title,
      subtitle: subtitle,
      value: userPreferences.getFlag(flagTag) ?? false,
      onChanged: (final bool value) async =>
          userPreferences.setFlag(flagTag, value),
    );
  }
}
