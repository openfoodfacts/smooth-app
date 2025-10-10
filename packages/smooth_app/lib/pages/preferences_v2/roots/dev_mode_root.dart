import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_badge.dart';
import 'package:smooth_app/background/background_task_language_refresh.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/dao_osm_location.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/locations/search_location_helper.dart';
import 'package:smooth_app/pages/locations/search_location_preloaded_item.dart';
import 'package:smooth_app/pages/offline_data_page.dart';
import 'package:smooth_app/pages/offline_tasks_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/toggle_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/value_edition_preference_tile.dart';
import 'package:smooth_app/pages/search/search_page.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class DevModeRoot extends PreferencesRoot {
  const DevModeRoot({required super.title});

  @override
  List<PreferenceCard> getCards(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    return <PreferenceCard>[
      PreferenceCard(
        title: appLocalizations.preferences_dev_mode_app_settings_title,
        tiles: <PreferenceTile>[
          _buildResetLanguageTile(context, appLocalizations, userPreferences),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_dev_mode_section_data,
        tiles: <PreferenceTile>[
          _buildBackgroundTaskTile(context, appLocalizations),
          _buildOfflineDataTile(context, appLocalizations),
          _buildRefreshProductsTile(context, appLocalizations),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_dev_mode_demo_mode_title,
        tiles: <PreferenceTile>[
          _buildAddCardsTile(context, appLocalizations),
          _buildResetOnboardingTile(context, appLocalizations, userPreferences),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.dev_mode_section_server,
        tiles: <PreferenceTile>[
          _buildEnvironmentSwitchTile(appLocalizations, userPreferences),
          if (userPreferences.getFlag(
                UserPreferencesDevMode.userPreferencesFlagProd,
              ) ==
              false)
            _buildTestEnvironmentTile(
              context,
              appLocalizations,
              userPreferences,
            ),
          _buildPriceEnvironmentSwitchTile(appLocalizations, userPreferences),
          _buildFolksonomyHostTile(context, appLocalizations, userPreferences),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.dev_mode_section_news,
        tiles: <PreferenceTile>[
          _buildCustomNewsUrlTile(appLocalizations, userPreferences),
          _buildNewsProviderStatusTile(context, appLocalizations),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.dev_mode_section_product_page,
        tiles: <PreferenceTile>[
          _buildEditIngredientsTile(context, appLocalizations, userPreferences),
        ],
      ),
      PreferenceCard(
        title: appLocalizations
            .preferences_dev_mode_accessibility_experiments_title,
        tiles: <PreferenceTile>[
          _buildAccessibilityNoColorTile(
            context,
            appLocalizations,
            userPreferences,
          ),
          _buildAccessibilityEmojiTile(
            context,
            appLocalizations,
            userPreferences,
          ),
        ],
      ),
      PreferenceCard(
        title: 'Open Prices',
        tiles: <PreferenceTile>[
          _buildBulkProofUploadTile(appLocalizations, userPreferences),
          _buildMultiProductsSelectionTile(
            context,
            appLocalizations,
            userPreferences,
          ),
          _buildUserOrderedKpTile(context, appLocalizations, userPreferences),
          _buildLocationSearchTile(context, appLocalizations),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.dev_mode_section_experimental_features,
        tiles: <PreferenceTile>[
          _buildSpellCheckerOcrTile(appLocalizations, userPreferences),
          _buildBoostedComparisonTile(
            context,
            appLocalizations,
            userPreferences,
          ),
          _buildProductListImportTile(
            context,
            appLocalizations,
            userPreferences,
          ),
        ],
      ),
    ];
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _showSuccessMessage(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(appLocalizations.dev_preferences_button_positive)),
  );

  // Demo Mode section methods
  PreferenceTile _buildAddCardsTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      title: appLocalizations.dev_mode_add_demo_cards_language_title,
      icon: const icons.Cards(),
      onTap: () async {
        final ContinuousScanModel model = context.read<ContinuousScanModel>();

        const List<String> barcodes = <String>[
          '5449000000996',
          '3017620425035',
          '3175680011480',
        ];
        for (int i = 0; i < barcodes.length; i++) {
          await model.onScan(barcodes[i]);
        }
      },
    );
  }

  PreferenceTile _buildResetOnboardingTile(
    BuildContext context,
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
  ) {
    return PreferenceTile(
      title: appLocalizations.dev_preferences_reset_onboarding_title,
      icon: const icons.Flag.checked(),
      onTap: () async {
        await userPreferences.resetOnboarding();
      },
    );
  }

  // Server section methods
  PreferenceTile _buildEnvironmentSwitchTile(
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
  ) {
    return PreferenceTile(
      title: appLocalizations.dev_preferences_environment_switch_title,
      icon: const icons.Search.database(),
      trailing: DropdownButton<bool>(
        value:
            userPreferences.getFlag(
              UserPreferencesDevMode.userPreferencesFlagProd,
            ) ??
            true,
        elevation: 16,
        onChanged: (bool? newValue) async {
          await userPreferences.setFlag(
            UserPreferencesDevMode.userPreferencesFlagProd,
            newValue,
          );
          ProductQuery.setQueryType(userPreferences);
        },
        items: const <DropdownMenuItem<bool>>[
          DropdownMenuItem<bool>(value: true, child: Text('PROD')),
          DropdownMenuItem<bool>(value: false, child: Text('TEST')),
        ],
      ),
    );
  }

  PreferenceTile _buildTestEnvironmentTile(
    BuildContext context,
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
  ) {
    return ValueEditionPreferenceTile(
      title: appLocalizations.dev_preferences_test_environment_title,
      dialogAction: appLocalizations.dev_preferences_test_environment_subtitle(
        ProductQuery.getTestUriProductHelper(
          userPreferences,
        ).getPostUri(path: '').toString(),
      ),
      onNewValue: (String newServer) async {
        await userPreferences.setDevModeString(
          UserPreferencesDevMode.userPreferencesTestEnvDomain,
          newServer,
        );
        ProductQuery.setQueryType(userPreferences);
      },
    );
  }

  PreferenceTile _buildPriceEnvironmentSwitchTile(
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
  ) {
    return PreferenceTile(
      title: appLocalizations.dev_mode_openprices_switch_env_title,
      icon: const icons.Search.database(),
      trailing: DropdownButton<bool>(
        value:
            userPreferences.getFlag(
              UserPreferencesDevMode.userPreferencesFlagPriceProd,
            ) ??
            true,
        elevation: 16,
        onChanged: (bool? newValue) async {
          await userPreferences.setFlag(
            UserPreferencesDevMode.userPreferencesFlagPriceProd,
            newValue,
          );
          ProductQuery.setQueryType(userPreferences);
        },
        items: const <DropdownMenuItem<bool>>[
          DropdownMenuItem<bool>(value: true, child: Text('PROD')),
          DropdownMenuItem<bool>(value: false, child: Text('TEST')),
        ],
      ),
    );
  }

  PreferenceTile _buildFolksonomyHostTile(
    BuildContext context,
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
  ) {
    return ValueEditionPreferenceTile(
      title: appLocalizations.preferences_dev_mode_folksonomy_host_title,
      icon: const icons.Search.database(),
      dialogAction: appLocalizations
          .preferences_dev_mode_folksonomy_host_subtitle(
            userPreferences.getDevModeString(
                  UserPreferencesDevMode.userPreferencesFolksonomyHost,
                ) ??
                '-',
          ),
      onNewValue: (String host) async {
        await userPreferences.setDevModeString(
          UserPreferencesDevMode.userPreferencesFolksonomyHost,
          host,
        );
        ProductQuery.setQueryType(userPreferences);
      },
    );
  }

  // News section methods
  ValueEditionPreferenceTile _buildCustomNewsUrlTile(
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
  ) {
    return ValueEditionPreferenceTile(
      title: appLocalizations.dev_preferences_news_custom_url_title,
      subtitleWithEmptyValue:
          appLocalizations.dev_preferences_news_custom_url_empty_value,
      icon: const icons.News.paper(),
      dialogAction: appLocalizations.dev_preferences_news_custom_url_subtitle,
      value: userPreferences.getDevModeString(
        UserPreferencesDevMode.userPreferencesCustomNewsJSONURI,
      ),
      onNewValue: (String newUrl) => userPreferences.setDevModeString(
        UserPreferencesDevMode.userPreferencesCustomNewsJSONURI,
        newUrl,
      ),
      validator: (String value) => value.isEmpty || Uri.tryParse(value) != null,
    );
  }

  PreferenceTile _buildNewsProviderStatusTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      title: appLocalizations.dev_preferences_news_provider_status_title,
      subtitle: Consumer<AppNewsProvider>(
        builder: (_, AppNewsProvider provider, _) {
          return Text(switch (provider.state) {
            AppNewsStateLoading() => appLocalizations.loading,
            AppNewsStateLoaded(lastUpdate: final DateTime date) =>
              appLocalizations.dev_preferences_news_provider_status_subtitle(
                DateFormat.yMd().format(date),
              ),
            AppNewsStateError(exception: final dynamic e) => 'Error $e',
          });
        },
      ),
      icon: const icons.Status(),
      trailing: IconButton(
        icon: const icons.Reload(),
        onPressed: () =>
            context.read<AppNewsProvider>().loadLatestNews(forceUpdate: true),
      ),
    );
  }

  // Product Page section methods
  TogglePreferenceTile _buildEditIngredientsTile(
    BuildContext context,
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
  ) {
    return TogglePreferenceTile(
      title: appLocalizations.dev_preferences_edit_ingredients_title,
      icon: const icons.Ingredients(),
      state:
          userPreferences.getFlag(
            UserPreferencesDevMode.userPreferencesFlagEditIngredients,
          ) ??
          false,
      onToggle: (bool value) async {
        await userPreferences.setFlag(
          UserPreferencesDevMode.userPreferencesFlagEditIngredients,
          value,
        );

        if (!context.mounted) {
          return;
        }

        _showSuccessMessage(context, appLocalizations);
      },
    );
  }

  // Accessibility section methods
  TogglePreferenceTile _buildAccessibilityNoColorTile(
    BuildContext context,
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
  ) {
    return TogglePreferenceTile(
      title: appLocalizations.preferences_accessibility_remove_colors,
      icon: const icons.Eye.visuallyImpaired(),
      state:
          userPreferences.getFlag(
            UserPreferencesDevMode.userPreferencesFlagAccessibilityNoColor,
          ) ??
          false,
      onToggle: (bool value) async {
        await userPreferences.setFlag(
          UserPreferencesDevMode.userPreferencesFlagAccessibilityNoColor,
          value,
        );

        if (!context.mounted) {
          return;
        }

        _showSuccessMessage(context, appLocalizations);
      },
    );
  }

  TogglePreferenceTile _buildAccessibilityEmojiTile(
    BuildContext context,
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
  ) {
    return TogglePreferenceTile(
      title: appLocalizations.preferences_accessibility_show_emoji,
      icon: const icons.Milk.happy(),
      state:
          userPreferences.getFlag(
            UserPreferencesDevMode.userPreferencesFlagAccessibilityEmoji,
          ) ??
          false,
      onToggle: (bool value) async {
        await userPreferences.setFlag(
          UserPreferencesDevMode.userPreferencesFlagAccessibilityEmoji,
          value,
        );

        if (!context.mounted) {
          return;
        }

        _showSuccessMessage(context, appLocalizations);
      },
    );
  }

  // Open Prices section methods
  TogglePreferenceTile _buildBulkProofUploadTile(
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
  ) {
    return TogglePreferenceTile(
      title: appLocalizations.prices_bulk_proof_upload_title,
      icon: const icons.Upload.bulk(),
      state:
          userPreferences.getFlag(
            UserPreferencesDevMode.userPreferencesFlagBulkProofUpload,
          ) ??
          false,
      onToggle: (bool value) async => userPreferences.setFlag(
        UserPreferencesDevMode.userPreferencesFlagBulkProofUpload,
        value,
      ),
    );
  }

  TogglePreferenceTile _buildMultiProductsSelectionTile(
    BuildContext context,
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
  ) {
    return TogglePreferenceTile(
      title:
          appLocalizations.preferences_dev_mode_multi_products_selection_title,
      icon: const icons.CheckList.twoLines(),
      state:
          userPreferences.getFlag(
            UserPreferencesDevMode
                .userPreferencesFlagPricesReceiptMultiSelection,
          ) ??
          false,
      onToggle: (bool value) async {
        await userPreferences.setFlag(
          UserPreferencesDevMode.userPreferencesFlagPricesReceiptMultiSelection,
          value,
        );

        if (!context.mounted) {
          return;
        }

        _showSuccessMessage(context, appLocalizations);
      },
    );
  }

  TogglePreferenceTile _buildUserOrderedKpTile(
    BuildContext context,
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
  ) {
    return TogglePreferenceTile(
      title: appLocalizations.preferences_dev_mode_user_ordered_kp_title,
      icon: const icons.Panel(),
      state:
          userPreferences.getFlag(
            UserPreferencesDevMode.userPreferencesFlagUserOrderedKP,
          ) ??
          false,
      onToggle: (bool value) async {
        await userPreferences.setFlag(
          UserPreferencesDevMode.userPreferencesFlagUserOrderedKP,
          value,
        );

        if (!context.mounted) {
          return;
        }

        _showSuccessMessage(context, appLocalizations);
      },
    );
  }

  PreferenceTile _buildLocationSearchTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      title: appLocalizations.preferences_dev_mode_location_search_title,
      icon: const icons.World.location(),
      onTap: () async {
        final LocalDatabase localDatabase = context.read<LocalDatabase>();
        final DaoOsmLocation daoOsmLocation = DaoOsmLocation(localDatabase);
        final List<OsmLocation> osmLocations = await daoOsmLocation.getAll();
        if (!context.mounted) {
          return;
        }
        final List<SearchLocationPreloadedItem> preloadedList =
            <SearchLocationPreloadedItem>[];
        for (final OsmLocation osmLocation in osmLocations) {
          preloadedList.add(
            SearchLocationPreloadedItem(osmLocation, popFirst: false),
          );
        }
        final OsmLocation? osmLocation = await Navigator.push<OsmLocation>(
          context,
          MaterialPageRoute<OsmLocation>(
            builder: (BuildContext context) => SearchPage(
              SearchLocationHelper(),
              preloadedList: preloadedList,
              autofocus: false,
            ),
          ),
        );
        if (osmLocation == null) {
          return;
        }
        await daoOsmLocation.put(osmLocation);
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              osmLocation.getTitle() ??
                  osmLocation.getSubtitle() ??
                  osmLocation.getLatLng().toString(),
            ),
          ),
        );
      },
    );
  }

  // Experimental Features section methods
  TogglePreferenceTile _buildSpellCheckerOcrTile(
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
  ) {
    return TogglePreferenceTile(
      title: appLocalizations.dev_mode_spellchecker_for_ocr_title,
      subtitleText: appLocalizations.dev_mode_spellchecker_for_ocr_subtitle,
      icon: const icons.SpellChecker(),
      state:
          userPreferences.getFlag(
            UserPreferencesDevMode.userPreferencesFlagSpellCheckerOnOcr,
          ) ??
          false,
      onToggle: (bool value) async => userPreferences.setFlag(
        UserPreferencesDevMode.userPreferencesFlagSpellCheckerOnOcr,
        value,
      ),
    );
  }

  TogglePreferenceTile _buildBoostedComparisonTile(
    BuildContext context,
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
  ) {
    return TogglePreferenceTile(
      title: appLocalizations.preferences_dev_mode_comparison_title,
      icon: const icons.Compare.alt(),
      state:
          userPreferences.getFlag(
            UserPreferencesDevMode.userPreferencesFlagBoostedComparison,
          ) ??
          false,
      onToggle: (bool value) async {
        await userPreferences.setFlag(
          UserPreferencesDevMode.userPreferencesFlagBoostedComparison,
          value,
        );

        if (!context.mounted) {
          return;
        }

        _showSuccessMessage(context, appLocalizations);
      },
    );
  }

  TogglePreferenceTile _buildProductListImportTile(
    BuildContext context,
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
  ) {
    return TogglePreferenceTile(
      title: appLocalizations.preferences_dev_mode_product_list_import_title,
      icon: const icons.Import(),
      state:
          userPreferences.getFlag(
            UserPreferencesDevMode.userPreferencesFlagProductListImport,
          ) ??
          false,
      onToggle: (bool value) async {
        await userPreferences.setFlag(
          UserPreferencesDevMode.userPreferencesFlagProductListImport,
          value,
        );

        if (!context.mounted) {
          return;
        }

        _showSuccessMessage(context, appLocalizations);
      },
    );
  }

  // App Settings section
  PreferenceTile _buildResetLanguageTile(
    BuildContext context,
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
  ) {
    return PreferenceTile(
      title: appLocalizations.dev_mode_reset_app_language_title,
      icon: const icons.Reset(),
      onTap: () async {
        userPreferences.setAppLanguageCode(null);
        ProductQuery.setLanguage(context, userPreferences);
      },
    );
  }

  // Data section
  PreferenceTile _buildBackgroundTaskTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      title: appLocalizations.background_task_title,
      subtitleText: appLocalizations.background_task_subtitle,
      icon: const BackgroundTaskBadge(child: icons.HourGlass()),
      onTap: () async => Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const OfflineTaskPage(),
        ),
      ),
    );
  }

  PreferenceTile _buildOfflineDataTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      title: appLocalizations.offline_data,
      subtitleText: appLocalizations.preferences_dev_mode_offline_data_subtitle,
      icon: const icons.Offline(),
      onTap: () => Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const OfflineDataPage(),
        ),
      ),
    );
  }

  PreferenceTile _buildRefreshProductsTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      title: appLocalizations.preferences_dev_mode_refresh_products_title,
      subtitleText:
          appLocalizations.preferences_dev_mode_refresh_products_subtitle,
      icon: const icons.Reset.reinit(),
      onTap: () async {
        final LocalDatabase localDatabase = context.read<LocalDatabase>();
        final DaoProduct daoProduct = DaoProduct(localDatabase);
        await daoProduct.clearAllLanguages();
        await BackgroundTaskLanguageRefresh.addTask(localDatabase);

        if (!context.mounted) {
          return;
        }

        _showSuccessMessage(context, appLocalizations);
      },
    );
  }
}
