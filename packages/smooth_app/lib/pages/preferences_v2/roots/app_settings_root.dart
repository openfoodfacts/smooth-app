import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/onboarding/currency_selector.dart';
import 'package:smooth_app/pages/preferences/country_selector/country_selector.dart';
import 'package:smooth_app/pages/preferences/language_selector/language_selector.dart';
import 'package:smooth_app/pages/preferences/user_preferences_choose_app_theme.dart';
import 'package:smooth_app/pages/preferences/user_preferences_image_source.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/toggle_preference_tile.dart';

class AppSettingsRoot extends PreferencesRoot {
  const AppSettingsRoot({required super.title});

  @override
  List<PreferenceCard> getCards(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    return <PreferenceCard>[
      PreferenceCard(
        title: appLocalizations.settings_app_app,
        tiles: <PreferenceTile>[
          PreferenceTile(
            title: appLocalizations.darkmode,
            subtitle: const UserPreferencesChooseAppTheme(hideTitle: true),
          ),
          PreferenceTile(
            title: appLocalizations.country_picker_label,
            subtitle: const CountrySelector(forceCurrencyChange: false),
          ),
          PreferenceTile(
            title: appLocalizations.currency_picker_label,
            subtitle: CurrencySelector(),
          ),
          PreferenceTile(
            title: appLocalizations.language_picker_label,
            subtitle: const LanguageSelector(),
          ),
          PreferenceTile(
            title: appLocalizations.choose_image_source_title,
            subtitle: const UserPreferencesImageSource(hideTitle: true),
          ),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_app_settings_products,
        tiles: <PreferenceTile>[
          TogglePreferenceTile(
            title: appLocalizations.expand_nutrition_facts,
            subtitleText: appLocalizations.expand_nutrition_facts_body,
            state:
                userPreferences.getFlag(
                  KnowledgePanelCard.getExpandFlagTag(
                    KnowledgePanelCard.PANEL_NUTRITION_TABLE_ID,
                  ),
                ) ??
                false,
            onToggle: (bool value) {
              userPreferences.setFlag(
                KnowledgePanelCard.getExpandFlagTag(
                  KnowledgePanelCard.PANEL_NUTRITION_TABLE_ID,
                ),
                value,
              );
            },
          ),
          TogglePreferenceTile(
            title: appLocalizations.expand_ingredients,
            subtitleText: appLocalizations.expand_ingredients_body,
            state:
                userPreferences.getFlag(
                  KnowledgePanelCard.getExpandFlagTag(
                    KnowledgePanelCard.PANEL_INGREDIENTS_ID,
                  ),
                ) ??
                false,
            onToggle: (bool value) {
              userPreferences.setFlag(
                KnowledgePanelCard.getExpandFlagTag(
                  KnowledgePanelCard.PANEL_INGREDIENTS_ID,
                ),
                value,
              );
            },
          ),
          TogglePreferenceTile(
            title: appLocalizations.search_product_filter_visibility_title,
            subtitleText:
                appLocalizations.search_product_filter_visibility_subtitle,
            state: userPreferences.searchProductTypeFilterVisible,
            onToggle: (final bool visible) async =>
                userPreferences.setSearchProductTypeFilter(visible),
          ),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.crash_reporting_toggle_title,
        tiles: <PreferenceTile>[
          TogglePreferenceTile(
            title: appLocalizations.crash_reporting_toggle_title,
            subtitleText: appLocalizations.crash_reporting_toggle_subtitle,
            state: userPreferences.crashReports,
            onToggle: (bool value) {
              userPreferences.setCrashReports(value);
            },
          ),
          TogglePreferenceTile(
            title: appLocalizations.send_anonymous_data_toggle_title,
            subtitleText: appLocalizations.send_anonymous_data_toggle_subtitle,
            state: userPreferences.userTracking,
            onToggle: (bool value) {
              userPreferences.setUserTracking(value);
            },
          ),
        ],
      ),
    ];
  }
}
