import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/language_selector.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/helpers/entry_points_helper.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_card.dart';
import 'package:smooth_app/pages/onboarding/country_selector.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/services/smooth_services.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/color_schemes.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
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
      final ThemeData themeData = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appLocalizations.error_occurred,
            textAlign: TextAlign.center,
            style: TextStyle(color: themeData.colorScheme.background),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: themeData.colorScheme.onBackground,
        ),
      );
    }
  }

  String getImagePath() {
    String imagePath = '';
    switch (GlobalVars.storeLabel) {
      case StoreLabel.FDroid:
        imagePath = 'assets/app/f-droid.png';
        break;
      case StoreLabel.AppleAppStore:
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

    final Widget leading = SizedBox(
      key: const Key('settings.rate_us'),
      height: DEFAULT_ICON_SIZE,
      width: DEFAULT_ICON_SIZE,
      child: Image.asset(getImagePath()),
    );

    final String title = appLocalizations.rate_app;

    return UserPreferenceListTile(
      title: title,
      leading: leading,
      onTap: _redirect,
      showDivider: true,
    );
  }
}

class _ShareWithFriends extends StatelessWidget {
  const _ShareWithFriends();

  Future<void> _shareApp(BuildContext context) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    try {
      await Share.share(appLocalizations.contribute_share_content);
    } on PlatformException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appLocalizations.error,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: themeData.colorScheme.background,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: themeData.colorScheme.onBackground,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget leading = Icon(
      key: const Key('settings.share_app'),
      Icons.adaptive.share,
    );

    final String title = AppLocalizations.of(context).contribute_share_header;

    return UserPreferenceListTile(
      title: title,
      leading: leading,
      onTap: _shareApp,
      showDivider: false,
    );
  }
}

class _ApplicationSettings extends StatelessWidget {
  const _ApplicationSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    return Column(
      children: <Widget>[
        UserPreferencesTitle.firstItem(
          label: appLocalizations.settings_app_app,
        ),
        const _ChooseAppTheme(),
        const UserPreferencesListItemDivider(),
        ListTile(
          title: Text(
            appLocalizations.country_chooser_label,
            style: themeData.textTheme.headlineMedium,
          ),
          subtitle: Padding(
            padding: const EdgeInsetsDirectional.only(
              top: SMALL_SPACE,
              bottom: SMALL_SPACE,
            ),
            child: CountrySelector(
              textStyle: themeData.textTheme.bodyMedium,
              icon: Icons.edit,
              padding: const EdgeInsetsDirectional.only(
                start: SMALL_SPACE,
              ),
            ),
          ),
          minVerticalPadding: MEDIUM_SPACE,
        ),
        const UserPreferencesListItemDivider(),
        ListTile(
          title: Text(
            appLocalizations.language_picker_label,
            style: themeData.textTheme.headlineMedium,
          ),
          subtitle: Padding(
            padding: const EdgeInsetsDirectional.only(
              top: SMALL_SPACE,
              bottom: SMALL_SPACE,
            ),
            child: LanguageSelector(
              setLanguage: (final OpenFoodFactsLanguage? language) async {
                if (language != null) {
                  ProductQuery.setLanguage(
                    context,
                    userPreferences,
                    languageCode: language.code,
                  );
                }
              },
              selectedLanguages: <OpenFoodFactsLanguage>[
                ProductQuery.getLanguage(),
              ],
              icon: Icons.edit,
              padding: const EdgeInsetsDirectional.only(
                start: SMALL_SPACE,
              ),
            ),
          ),
          minVerticalPadding: MEDIUM_SPACE,
        ),
        const UserPreferencesListItemDivider(),
        UserPreferencesMultipleChoicesItem<UserPictureSource>(
          title: appLocalizations.choose_image_source_title,
          leadingBuilder: <WidgetBuilder>[
            (_) => const Icon(Icons.edit_note_rounded),
            (_) => const Icon(Icons.camera),
            (_) => const Icon(Icons.image),
          ],
          labels: <String>[
            appLocalizations.user_picture_source_select,
            appLocalizations.settings_app_camera,
            appLocalizations.gallery_source_label,
          ],
          values: const <UserPictureSource>[
            UserPictureSource.SELECT,
            UserPictureSource.CAMERA,
            UserPictureSource.GALLERY,
          ],
          currentValue: userPreferences.userPictureSource,
          onChanged: (final UserPictureSource? newValue) async =>
              userPreferences.setUserPictureSource(newValue!),
        ),
      ],
    );
  }
}

class _ChooseAppTheme extends StatelessWidget {
  const _ChooseAppTheme();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();

    final Widget child = UserPreferencesMultipleChoicesItem<String>(
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
      onChanged: (String? newValue) {
        themeProvider.setTheme(newValue!);
      },
    );

    if (themeProvider.currentTheme == THEME_AMOLED) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          child,
          const _ChooseAccentColor(),
          const _ChooseTextColorContrast(),
        ],
      );
    } else {
      return child;
    }
  }
}

class _ChooseAccentColor extends StatelessWidget {
  const _ChooseAccentColor();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ColorProvider colorProvider = context.watch<ColorProvider>();
    final Map<String, String> labels = localizedNames(appLocalizations);

    return UserPreferencesMultipleChoicesItem<String>(
      title: appLocalizations.select_accent_color,
      leadingBuilder: labels.keys.map(
        (String key) => (_) => CircleAvatar(
              backgroundColor: getColorValue(key),
              radius: SMALL_SPACE,
            ),
      ),
      labels: labels.values,
      values: labels.keys,
      currentValue: colorProvider.currentColor,
      onChanged: (String? newValue) {
        colorProvider.setColor(newValue!);
      },
    );
  }

  Map<String, String> localizedNames(AppLocalizations appLocalizations) =>
      <String, String>{
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

class _ChooseTextColorContrast extends StatelessWidget {
  const _ChooseTextColorContrast();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final TextContrastProvider textContrastProvider =
        context.watch<TextContrastProvider>();

    return UserPreferencesMultipleChoicesItem<String>(
      title: appLocalizations.text_contrast_mode,
      values: const <String>[
        CONTRAST_HIGH,
        CONTRAST_MEDIUM,
        CONTRAST_LOW,
      ],
      labels: <String>[
        appLocalizations.contrast_high,
        appLocalizations.contrast_medium,
        appLocalizations.contrast_low,
      ],
      currentValue: textContrastProvider.currentContrastLevel,
      onChanged: (String? contrast) =>
          textContrastProvider.setContrast(contrast!),
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
          child: UserPreferenceListTile(
            onTap: (_) async {
              await AppSettings.openAppSettings();
            },
            title: appLocalizations.native_app_settings,
            subTitle: appLocalizations.native_app_description,
            leading: const Icon(CupertinoIcons.settings_solid),
            showDivider: true,
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
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    return UserPreferencesSwitchItem(
      title: appLocalizations.send_anonymous_data_toggle_title,
      subtitle: appLocalizations.send_anonymous_data_toggle_subtitle,
      value: userPreferences.userTracking,
      onChanged: (final bool allow) async {
        await userPreferences.setUserTracking(allow);
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
      },
    );
  }
}

class _CameraSettings extends StatelessWidget {
  const _CameraSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!CameraHelper.hasACamera) {
      return EMPTY_WIDGET;
    }

    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        UserPreferencesTitle(
          label: appLocalizations.settings_app_camera,
        ),
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

class _ProductsSettings extends StatelessWidget {
  const _ProductsSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!CameraHelper.hasACamera) {
      return EMPTY_WIDGET;
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
      return EMPTY_WIDGET;
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
