import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/onboarding/currency_selector_helper.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/app_settings_tiles/country_selector/country_selector_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/app_settings_tiles/language_selector/language_selector_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/multiple_choices_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/toggle_preference_tile.dart';
import 'package:smooth_app/pages/prices/currency_extension.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/theme_provider.dart';

class AppSettingsRoot extends PreferencesRoot {
  const AppSettingsRoot({required super.title});

  @override
  List<PreferenceCard> getCards(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final ThemeData theme = Theme.of(context);

    final Color iconColor = context.lightTheme()
        ? theme.primaryColor
        : Colors.white;

    final CurrencySelectorHelper currencyHelper = CurrencySelectorHelper();
    final Currency selectedCurrency = currencyHelper.getSelected(
      userPreferences.userCurrencyCode,
    );

    return <PreferenceCard>[
      PreferenceCard(
        title:
            appLocalizations.preferences_app_settings_graphical_interface_title,
        tiles: <PreferenceTile>[
          _buildThemeTile(appLocalizations, themeProvider, iconColor),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.settings_app_app,
        tiles: <PreferenceTile>[
          _buildLanguageTile(appLocalizations),
          _buildCountryTile(appLocalizations),
          _buildCurrencyTile(
            appLocalizations,
            selectedCurrency,
            currencyHelper,
            context,
            iconColor,
          ),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_app_settings_media_title,
        tiles: <PreferenceTile>[
          _buildImageSourceTile(appLocalizations, userPreferences, iconColor),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_app_settings_products,
        tiles: <PreferenceTile>[
          _buildExpandNutritionTile(
            appLocalizations,
            userPreferences,
            iconColor,
          ),
          _buildExpandIngredientsTile(
            appLocalizations,
            userPreferences,
            iconColor,
          ),
          _buildSearchFilterTile(appLocalizations, userPreferences),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.crash_reporting_toggle_title,
        tiles: <PreferenceTile>[
          _buildCrashReportingTile(
            appLocalizations,
            userPreferences,
            iconColor,
          ),
          _buildAnonymousDataTile(appLocalizations, userPreferences, iconColor),
        ],
      ),
    ];
  }

  // Graphical Interface section
  MultipleChoicesTile<String> _buildThemeTile(
    AppLocalizations appLocalizations,
    ThemeProvider themeProvider,
    Color iconColor,
  ) {
    return MultipleChoicesTile<String>(
      title: appLocalizations.darkmode,
      leadingBuilder: <WidgetBuilder>[
        (_) => Icon(Icons.brightness_medium, color: iconColor),
        (_) => Icon(Icons.light_mode, color: iconColor),
        (_) => Icon(Icons.dark_mode_outlined, color: iconColor),
        (_) => Icon(Icons.dark_mode, color: iconColor),
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
      onChanged: (String? newValue) => themeProvider.setTheme(newValue!),
    );
  }

  // App Settings section
  LanguageSelectorTile _buildLanguageTile(AppLocalizations appLocalizations) {
    return LanguageSelectorTile(
      title: appLocalizations.language_picker_label,
      autoValidate: false,
    );
  }

  CountrySelectorTile _buildCountryTile(AppLocalizations appLocalizations) {
    return CountrySelectorTile(
      title: appLocalizations.country_picker_label,
      forceCurrencyChange: false,
      autoValidate: false,
    );
  }

  PreferenceTile _buildCurrencyTile(
    AppLocalizations appLocalizations,
    Currency selectedCurrency,
    CurrencySelectorHelper currencyHelper,
    BuildContext context,
    Color iconColor,
  ) {
    return PreferenceTile(
      leading: icons.Currency(color: iconColor),
      title: appLocalizations.currency_picker_label,
      subtitleText: selectedCurrency.getFullName(),
      onTap: () => currencyHelper.openCurrencySelector(
        context: context,
        selected: selectedCurrency,
      ),
      trailing: icons.Edit(color: iconColor, size: 18.0),
    );
  }

  // Media section
  MultipleChoicesTile<UserPictureSource> _buildImageSourceTile(
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
    Color iconColor,
  ) {
    return MultipleChoicesTile<UserPictureSource>(
      title: appLocalizations.choose_image_source_title,
      leadingBuilder: <WidgetBuilder>[
        (_) => Icon(Icons.edit_note_rounded, color: iconColor),
        (_) => Icon(Icons.camera, color: iconColor),
        (_) => Icon(Icons.image, color: iconColor),
      ],
      labels: <String>[
        appLocalizations.user_picture_source_ask,
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
    );
  }

  // Products section
  TogglePreferenceTile _buildExpandNutritionTile(
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
    Color iconColor,
  ) {
    return TogglePreferenceTile(
      leading: icons.NutritionFacts.alt(color: iconColor),
      title: appLocalizations.expand_nutrition_facts,
      subtitleText: appLocalizations.expand_nutrition_facts_body,
      state:
          userPreferences.getFlag(
            KnowledgePanelCard.getExpandFlagTag(
              KnowledgePanelCard.PANEL_NUTRITION_TABLE_ID,
            ),
          ) ??
          false,
      onToggle: (final bool value) => userPreferences.setFlag(
        KnowledgePanelCard.getExpandFlagTag(
          KnowledgePanelCard.PANEL_NUTRITION_TABLE_ID,
        ),
        value,
      ),
    );
  }

  TogglePreferenceTile _buildExpandIngredientsTile(
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
    Color iconColor,
  ) {
    return TogglePreferenceTile(
      leading: icons.Ingredients.basket(color: iconColor),
      title: appLocalizations.expand_ingredients,
      subtitleText: appLocalizations.expand_ingredients_body,
      state:
          userPreferences.getFlag(
            KnowledgePanelCard.getExpandFlagTag(
              KnowledgePanelCard.PANEL_INGREDIENTS_ID,
            ),
          ) ??
          false,
      onToggle: (final bool value) => userPreferences.setFlag(
        KnowledgePanelCard.getExpandFlagTag(
          KnowledgePanelCard.PANEL_INGREDIENTS_ID,
        ),
        value,
      ),
    );
  }

  TogglePreferenceTile _buildSearchFilterTile(
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
  ) {
    return TogglePreferenceTile(
      leading: const icons.Sort(),
      title: appLocalizations.search_product_filter_visibility_title,
      subtitleText: appLocalizations.search_product_filter_visibility_subtitle,
      state: userPreferences.searchProductTypeFilterVisible,
      onToggle: (final bool visible) async =>
          userPreferences.setSearchProductTypeFilter(visible),
    );
  }

  // Data Collection section
  TogglePreferenceTile _buildCrashReportingTile(
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
    Color iconColor,
  ) {
    return TogglePreferenceTile(
      leading: icons.Crash(color: iconColor),
      title: appLocalizations.crash_reporting_toggle_title,
      subtitleText: appLocalizations.crash_reporting_toggle_subtitle,
      state: userPreferences.crashReports,
      onToggle: (final bool value) => userPreferences.setCrashReports(value),
    );
  }

  TogglePreferenceTile _buildAnonymousDataTile(
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
    Color iconColor,
  ) {
    return TogglePreferenceTile(
      leading: icons.Incognito(color: iconColor),
      title: appLocalizations.send_anonymous_data_toggle_title,
      subtitleText: appLocalizations.send_anonymous_data_toggle_subtitle,
      state: userPreferences.userTracking,
      onToggle: (final bool value) => userPreferences.setUserTracking(value),
    );
  }
}
