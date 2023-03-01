import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/language_selector.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_card.dart';
import 'package:smooth_app/main.dart';
import 'package:smooth_app/pages/onboarding/country_selector.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';
import 'package:smooth_app/pages/scan/camera_modes.dart';
import 'package:smooth_app/services/smooth_services.dart';
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
        _CameraSettings(),
        _ProductsSettings(),
        _MiscellaneousSettings(),
        _PrivacySettings(),
        _RateUs(),
        _ShareWithFriends(),
      ];
}

class _RateUs extends StatelessWidget {
  const _RateUs();
  Future<void> _redirect(BuildContext context) async {
    try {
      await ApplicationStore.openAppDetails();
    } on PlatformException {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appLocalizations.error_occurred,
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String getImagePath() {
    final String appFlavour = flavour;
    String imagePath = '';
    switch (appFlavour) {
      case 'zxing-uri':
        imagePath = 'assets/app/f-droid.png';
        break;
      case 'ml-ios':
        imagePath = 'assets/app/app-store.png';
        break;
      default:
        imagePath = 'assets/app/playstore.png';
    }
    return imagePath;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        ListTile(
          leading: Padding(
            padding: const EdgeInsets.all(SMALL_SPACE),
            child: SizedBox(
              height: DEFAULT_ICON_SIZE,
              width: DEFAULT_ICON_SIZE,
              child: Image.asset(getImagePath()),
            ),
          ),
          title: Text(
            appLocalizations.app_rating_dialog_positive_action,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () => _redirect(context),
        ),
        const SizedBox(
          height: SMALL_SPACE,
        ),
        const UserPreferencesListItemDivider(),
      ],
    );
  }
}

class _ShareWithFriends extends StatelessWidget {
  const _ShareWithFriends();

  Future<void> _shareApp(BuildContext context) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    try {
      await Share.share(appLocalizations.contribute_share_content);
    } on PlatformException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appLocalizations.error,
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.adaptive.share),
          title: Text(
            AppLocalizations.of(context).contribute_share_header,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () => _shareApp(context),
        ),
        const SizedBox(
          height: SMALL_SPACE,
        ),
      ],
    );
  }
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
          padding: const EdgeInsets.only(
            left: LARGE_SPACE,
            top: MEDIUM_SPACE,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                appLocalizations.darkmode,
                style: themeData.textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            right: LARGE_SPACE,
            bottom: MEDIUM_SPACE,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
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
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          subtitle: LanguageSelectorSettings(
            userPreferences: userPreferences,
            appLocalizations: appLocalizations,
          ),
          minVerticalPadding: MEDIUM_SPACE,
        ),
        const UserPreferencesListItemDivider(),
        Padding(
          padding: const EdgeInsets.only(
            left: LARGE_SPACE,
            top: MEDIUM_SPACE,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                appLocalizations.choose_image_source_title,
                style: themeData.textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            right: LARGE_SPACE,
            bottom: MEDIUM_SPACE,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              DropdownButton<UserPictureSource>(
                value: userPreferences.userPictureSource,
                elevation: 16,
                onChanged: (final UserPictureSource? newValue) async =>
                    userPreferences.setUserPictureSource(newValue!),
                items: <DropdownMenuItem<UserPictureSource>>[
                  DropdownMenuItem<UserPictureSource>(
                    value: UserPictureSource.SELECT,
                    child: Text(appLocalizations.user_picture_source_select),
                  ),
                  DropdownMenuItem<UserPictureSource>(
                    value: UserPictureSource.CAMERA,
                    child: Text(appLocalizations.settings_app_camera),
                  ),
                  DropdownMenuItem<UserPictureSource>(
                    value: UserPictureSource.GALLERY,
                    child: Text(appLocalizations.gallery_source_label),
                  )
                ],
              ),
            ],
          ),
        ),
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
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      subtitle: CountrySelector(
        initialCountryCode: userPreferences.userCountryCode,
        textStyle: Theme.of(context).textTheme.bodyMedium,
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
        const UserPreferencesListItemDivider(),
        const _AdvancedSettings(),
        const UserPreferencesListItemDivider(),
      ],
    );
  }
}

class _AdvancedSettings extends StatelessWidget {
  const _AdvancedSettings({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: ListTile(
            onTap: () async {
              await AppSettings.openAppSettings();
            },
            title: Text(
              appLocalizations.native_app_settings,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: SMALL_SPACE),
              child: Text(
                appLocalizations.native_app_description,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
            trailing: const Padding(
              padding: EdgeInsets.only(
                right: LARGE_SPACE,
              ),
              child: Icon(
                CupertinoIcons.settings_solid,
              ),
            ),
            minVerticalPadding: MEDIUM_SPACE,
          ),
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
        if (CameraModes.supportBothModes) ...<Widget>[
          const _CameraModesSelectorSetting(),
          const UserPreferencesListItemDivider(),
        ],
        const _CameraPlayScanSoundSetting(),
      ],
    );
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

/// This setting will act as a toggle between the two camera modes.
class _CameraModesSelectorSetting extends StatelessWidget {
  const _CameraModesSelectorSetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    CameraMode mode;

    if (userPreferences.useFileBasedCameraMode == true) {
      mode = CameraMode.FILE_BASED;
    } else if (userPreferences.useFileBasedCameraMode == false) {
      mode = CameraMode.BYTES_ARRAY;
    } else {
      mode = CameraModes.defaultCameraMode;
    }

    // File-based mode is called "Safe mode" for users
    // Bytes array mode is called "Quick mode"
    return UserPreferencesSwitchItem(
      title: appLocalizations.camera_mode_title,
      subtitle: appLocalizations.camera_mode_subtitle(
        mode == CameraMode.FILE_BASED
            ? appLocalizations.camera_mode_file_based
            : appLocalizations.camera_mode_bytes_array_based,
      ),
      value: mode == CameraMode.FILE_BASED,
      onChanged: (final bool value) {
        userPreferences.setUseFileBasedCameraMode(value);
      },
    );
  }
}

class _ProductsSettings extends StatelessWidget {
  const _ProductsSettings({Key? key}) : super(key: key);

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
          label: appLocalizations.settings_app_products,
        ),
        _ExpandPanelHelper(
          title: appLocalizations.expand_nutrition_facts,
          subtitle: appLocalizations.expand_nutrition_facts_body,
          panelId: KnowledgePanelCard.PANEL_NUTRITION_TABLE_ID,
        ),
        const UserPreferencesListItemDivider(),
        _ExpandPanelHelper(
          title: appLocalizations.expand_ingredients,
          subtitle: appLocalizations.expand_ingredients_body,
          panelId: KnowledgePanelCard.PANEL_INGREDIENTS_ID,
        ),
      ],
    );
  }
}

class _MiscellaneousSettings extends StatelessWidget {
  const _MiscellaneousSettings({Key? key}) : super(key: key);

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
          label: appLocalizations.settings_app_miscellaneous,
        ),
        const _HapticFeedbackSetting(),
      ],
    );
  }
}

class _HapticFeedbackSetting extends StatelessWidget {
  const _HapticFeedbackSetting();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    return UserPreferencesSwitchItem(
      title: appLocalizations.app_haptic_feedback_title,
      subtitle: appLocalizations.app_haptic_feedback_subtitle,
      value: userPreferences.hapticFeedbackEnabled,
      onChanged: (final bool value) async {
        await userPreferences.setHapticFeedbackEnabled(value);
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
