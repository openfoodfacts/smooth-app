import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_card.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_advanced_settings.dart';
import 'package:smooth_app/pages/preferences/user_preferences_camera_sound.dart';
import 'package:smooth_app/pages/preferences/user_preferences_choose_accent_color.dart';
import 'package:smooth_app/pages/preferences/user_preferences_choose_app_theme.dart';
import 'package:smooth_app/pages/preferences/user_preferences_choose_text_color_contrast.dart';
import 'package:smooth_app/pages/preferences/user_preferences_country_selector.dart';
import 'package:smooth_app/pages/preferences/user_preferences_crash_reporting.dart';
import 'package:smooth_app/pages/preferences/user_preferences_haptic_feedback.dart';
import 'package:smooth_app/pages/preferences/user_preferences_image_source.dart';
import 'package:smooth_app/pages/preferences/user_preferences_language_selector.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_rate_us.dart';
import 'package:smooth_app/pages/preferences/user_preferences_send_anonymous.dart';
import 'package:smooth_app/pages/preferences/user_preferences_share_with_friends.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Collapsed/expanded display of settings for the preferences page.
class UserPreferencesSettings extends AbstractUserPreferences {
  UserPreferencesSettings({
    required final BuildContext context,
    required final UserPreferences userPreferences,
    required final AppLocalizations appLocalizations,
    required final ThemeData themeData,
    required this.themeProvider,
  }) : super(
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );

  final ThemeProvider themeProvider;

  @override
  PreferencePageType getPreferencePageType() => PreferencePageType.SETTINGS;

  @override
  String getTitleString() => appLocalizations.myPreferences_settings_title;

  @override
  Widget? getSubtitle() =>
      Text(appLocalizations.myPreferences_settings_subtitle);

  @override
  IconData getLeadingIconData() => Icons.handyman;

  @override
  List<Widget> getBody() => <Widget>[
        UserPreferencesTitle.firstItem(
          label: appLocalizations.settings_app_app,
        ),
        const UserPreferencesChooseAppTheme(),
        if (themeProvider.currentTheme == THEME_AMOLED)
          const UserPreferencesChooseAccentColor(),
        if (themeProvider.currentTheme == THEME_AMOLED)
          const UserPreferencesChooseTextColorContrast(),
        const UserPreferencesListItemDivider(),
        const UserPreferencesCountrySelector(),
        const UserPreferencesListItemDivider(),
        const UserPreferencesLanguageSelector(),
        const UserPreferencesListItemDivider(),
        const UserPreferencesImageSource(),
        if (CameraHelper.hasACamera)
          UserPreferencesTitle(
            label: appLocalizations.settings_app_camera,
          ),
        if (CameraHelper.hasACamera) const UserPreferencesCameraSound(),
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
        if (CameraHelper.hasACamera)
          UserPreferencesTitle(
            label: appLocalizations.settings_app_miscellaneous,
          ),
        if (CameraHelper.hasACamera) const UserPreferencesHapticFeedback(),
        UserPreferencesTitle(label: appLocalizations.settings_app_data),
        const UserPreferencesCrashReporting(),
        const UserPreferencesListItemDivider(),
        const UserPreferencesSendAnonymous(),
        const UserPreferencesListItemDivider(),
        const UserPreferencesAdvancedSettings(),
        const UserPreferencesListItemDivider(),
        const UserPreferencesRateUs(),
        const UserPreferencesShareWithFriends(),
      ];
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
