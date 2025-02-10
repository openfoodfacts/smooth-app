import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_card.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_advanced_settings.dart';
import 'package:smooth_app/pages/preferences/user_preferences_choose_accent_color.dart';
import 'package:smooth_app/pages/preferences/user_preferences_choose_app_theme.dart';
import 'package:smooth_app/pages/preferences/user_preferences_choose_text_color_contrast.dart';
import 'package:smooth_app/pages/preferences/user_preferences_country_selector.dart';
import 'package:smooth_app/pages/preferences/user_preferences_currency_selector.dart';
import 'package:smooth_app/pages/preferences/user_preferences_image_source.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences/user_preferences_language_selector.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_share_with_friends.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Collapsed/expanded display of settings for the preferences page.
class UserPreferencesSettings extends AbstractUserPreferences {
  UserPreferencesSettings({
    required super.context,
    required super.userPreferences,
    required super.appLocalizations,
    required super.themeData,
    required this.themeProvider,
  });

  final ThemeProvider themeProvider;

  @override
  PreferencePageType getPreferencePageType() => PreferencePageType.SETTINGS;

  @override
  String getTitleString() => appLocalizations.myPreferences_settings_title;

  @override
  String getSubtitleString() =>
      appLocalizations.myPreferences_settings_subtitle;

  @override
  IconData getLeadingIconData() => Icons.handyman;

  @override
  List<UserPreferencesItem> getChildren() {
    final UserPreferences userPreferences = context.read<UserPreferences>();
    return <UserPreferencesItem>[
      _getTitle(
        label: appLocalizations.settings_app_app,
        addExtraPadding: false,
      ),
      UserPreferencesChooseAppTheme.getUserPreferencesItem(context),
      if (themeProvider.currentTheme == THEME_AMOLED)
        UserPreferencesChooseAccentColor.getUserPreferencesItem(context),
      if (themeProvider.currentTheme == THEME_AMOLED)
        UserPreferencesChooseTextColorContrast.getUserPreferencesItem(context),
      _getDivider(),
      UserPreferencesCountrySelector.getUserPreferencesItem(context),
      _getDivider(),
      UserPreferencesCurrencySelector.getUserPreferencesItem(context),
      _getDivider(),
      UserPreferencesLanguageSelector.getUserPreferencesItem(context),
      _getDivider(),
      UserPreferencesImageSource.getUserPreferencesItem(context),
      if (CameraHelper.hasACamera)
        _getTitle(
          label: appLocalizations.settings_app_camera,
        ),
      if (CameraHelper.hasACamera)
        UserPreferencesItemSwitch(
          title: appLocalizations.camera_play_sound_title,
          subtitle: appLocalizations.camera_play_sound_subtitle,
          value: userPreferences.playCameraSound,
          onChanged: (final bool value) async =>
              userPreferences.setPlayCameraSound(value),
        ),
      _getTitle(
        label: appLocalizations.settings_app_products,
      ),
      _getExpandPanel(
        title: appLocalizations.expand_nutrition_facts,
        subtitle: appLocalizations.expand_nutrition_facts_body,
        panelId: KnowledgePanelCard.PANEL_NUTRITION_TABLE_ID,
      ),
      _getDivider(),
      _getExpandPanel(
        title: appLocalizations.expand_ingredients,
        subtitle: appLocalizations.expand_ingredients_body,
        panelId: KnowledgePanelCard.PANEL_INGREDIENTS_ID,
      ),
      _getDivider(),
      UserPreferencesItemSwitch(
        title: appLocalizations.search_product_filter_visibility_title,
        subtitle: appLocalizations.search_product_filter_visibility_subtitle,
        value: userPreferences.searchProductTypeFilterVisible,
        onChanged: (final bool visible) async =>
            userPreferences.setSearchProductTypeFilter(visible),
      ),
      if (CameraHelper.hasACamera)
        _getTitle(
          label: appLocalizations.settings_app_miscellaneous,
        ),
      if (CameraHelper.hasACamera)
        UserPreferencesItemSwitch(
          title: appLocalizations.app_haptic_feedback_title,
          subtitle: appLocalizations.app_haptic_feedback_subtitle,
          value: userPreferences.hapticFeedbackEnabled,
          onChanged: (final bool value) async =>
              userPreferences.setHapticFeedbackEnabled(value),
        ),
      _getTitle(label: appLocalizations.settings_app_data),
      UserPreferencesItemSwitch(
        title: appLocalizations.crash_reporting_toggle_title,
        subtitle: appLocalizations.crash_reporting_toggle_subtitle,
        value: userPreferences.crashReports,
        onChanged: (final bool value) async =>
            userPreferences.setCrashReports(value),
      ),
      _getDivider(),
      UserPreferencesItemSwitch(
        title: appLocalizations.send_anonymous_data_toggle_title,
        subtitle: appLocalizations.send_anonymous_data_toggle_subtitle,
        value: userPreferences.userTracking,
        onChanged: (final bool allow) async =>
            userPreferences.setUserTracking(allow),
      ),
      _getDivider(),
      UserPreferencesAdvancedSettings.getUserPreferencesItem(context),
      _getDivider(),
      UserPreferencesShareWithFriends.getUserPreferencesItem(context),
    ];
  }

  UserPreferencesItem _getTitle({
    required final String label,
    final bool addExtraPadding = true,
  }) =>
      UserPreferencesItemSimple(
        labels: <String>[label],
        builder: (_) => _UserPreferencesTitle(
          label: label,
          addExtraPadding: addExtraPadding,
        ),
      );

  UserPreferencesItem _getDivider() => UserPreferencesItemSimple(
        labels: <String>[],
        builder: (_) => const UserPreferencesListItemDivider(),
      );

  UserPreferencesItem _getExpandPanel({
    required String title,
    required String subtitle,
    required String panelId,
  }) =>
      UserPreferencesItemSimple(
        labels: <String>[title, subtitle],
        builder: (_) {
          final String flagTag = KnowledgePanelCard.getExpandFlagTag(panelId);
          return UserPreferencesSwitchWidget(
            title: title,
            subtitle: subtitle,
            value: userPreferences.getFlag(flagTag) ?? false,
            onChanged: (final bool value) async =>
                userPreferences.setFlag(flagTag, value),
          );
        },
      );
}

class _UserPreferencesTitle extends StatelessWidget {
  const _UserPreferencesTitle({
    required this.label,
    this.addExtraPadding = true,
  }) : assert(label.length > 0);

  final String label;
  final bool addExtraPadding;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            top: addExtraPadding ? LARGE_SPACE : LARGE_SPACE,
            bottom: SMALL_SPACE,
            // Horizontal = same as ListTile
            start: LARGE_SPACE,
            end: LARGE_SPACE,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ),
      );
}
