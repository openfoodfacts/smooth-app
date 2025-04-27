import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_badge.dart';
import 'package:smooth_app/background/background_task_language_refresh.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_osm_location.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/locations/search_location_helper.dart';
import 'package:smooth_app/pages/locations/search_location_preloaded_item.dart';
import 'package:smooth_app/pages/offline_data_page.dart';
import 'package:smooth_app/pages/offline_tasks_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_search_page.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/toggle_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/value_edition_preference_tile.dart';
import 'package:smooth_app/pages/search/search_page.dart';
import 'package:smooth_app/query/product_query.dart';

class DevModeRoot extends PreferencesRoot {
  DevModeRoot({required super.title});

  static const String userPreferencesFlagProd = '__devWorkingOnProd';
  static const String userPreferencesFlagPriceProd = '__devWorkingOnPricesProd';
  static const String userPreferencesTestEnvDomain = '__testEnvHost';
  static const String userPreferencesFolksonomyHost = '__folksonomyHost';
  static const String userPreferencesFlagEditIngredients = '__editIngredients';
  static const String userPreferencesFlagHideFolksonomy = '__hideFolksonomy';
  static const String userPreferencesFlagBoostedComparison =
      '__boostedComparison';
  static const String userPreferencesFlagProductListImport =
      '__productListImport';
  static const String userPreferencesEnumScanMode = '__scanMode';
  static const String userPreferencesAppLanguageCode = '__appLanguage';
  static const String userPreferencesFlagAccessibilityNoColor =
      '__accessibilityNoColor';
  static const String userPreferencesFlagAccessibilityEmoji =
      '__accessibilityEmoji';
  static const String userPreferencesFlagUserOrderedKP = '__userOrderedKP';
  static const String userPreferencesFlagPricesReceiptMultiSelection =
      '__pricesReceiptMultiSelection';
  static const String userPreferencesFlagSpellCheckerOnOcr =
      '__spellcheckerOcr';
  static const String userPreferencesFlagBulkProofUpload = '__bulkProofUpload';
  static const String userPreferencesCustomNewsJSONURI = '__newsJsonURI';

  final TextEditingController _textFieldController = TextEditingController();

  @override
  List<PreferenceCard> getCards(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    return <PreferenceCard>[
      PreferenceCard(
        title: appLocalizations.dev_mode_section_data,
        tiles: <PreferenceTile>[
          PreferenceTile(
            icon: Icons.temple_buddhist,
            title: appLocalizations.background_task_title,
            subtitleText: appLocalizations.background_task_subtitle,
            trailing: const BackgroundTaskBadge(
              child: Icon(Icons.edit_notifications_outlined),
            ),
            onTap: () async => Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const OfflineTaskPage(),
              ),
            ),
          ),
          PreferenceTile(
            icon: Icons.temple_buddhist,
            title: appLocalizations.offline_data,
            onTap: () => Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const OfflineDataPage(),
              ),
            ),
          ),
          PreferenceTile(
            icon: Icons.temple_buddhist,
            title: appLocalizations.dev_preferences_export_history_title,
            subtitleText: appLocalizations.clipboard_barcode_copy,
            onTap: () async {
              final LocalDatabase localDatabase = context.read<LocalDatabase>();
              final Map<String, dynamic> export =
                  await DaoProductList(localDatabase).export(
                ProductList.history(),
              );
              final List<Widget> children = <Widget>[];
              for (final String barcode in export.keys) {
                final bool? exists = export[barcode] as bool?;
                children.add(
                  ListTile(
                    leading: Icon(exists == null
                        ? Icons.error
                        : exists
                            ? Icons.check
                            : Icons.help_outline),
                    title: Text(barcode),
                    subtitle: Text(exists == null
                        ? appLocalizations
                            .dev_preferences_export_history_progress_error
                        : exists
                            ? appLocalizations
                                .dev_preferences_export_history_progress_found
                            : appLocalizations
                                .dev_preferences_export_history_progress_not_found),
                  ),
                );
              }

              if (!context.mounted) {
                return;
              }
              await showDialog<void>(
                context: context,
                builder: (BuildContext context) => SmoothAlertDialog(
                  title: appLocalizations
                      .dev_preferences_export_history_dialog_title,
                  body: SizedBox(
                    height: 400,
                    width: 300,
                    child: ListView(children: children),
                  ),
                  negativeAction: SmoothActionButton(
                    text: appLocalizations.copy_to_clipboard,
                    onPressed: () async {
                      final StringBuffer data = StringBuffer();

                      for (final String key in export.keys) {
                        data.write('$key, ');
                      }

                      await Clipboard.setData(
                        ClipboardData(text: data.toString()),
                      );
                    },
                  ),
                  positiveAction: SmoothActionButton(
                    text: appLocalizations.okay,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
          PreferenceTile(
            icon: Icons.temple_buddhist,
            title: 'Refresh all products from server (cf. Nutriscore v2)',
            trailing: const Icon(Icons.refresh),
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
          ),
          PreferenceTile(
            icon: Icons.temple_buddhist,
            title: 'Reset app language',
            onTap: () async {
              userPreferences.setAppLanguageCode(null);
              ProductQuery.setLanguage(context, userPreferences);
            },
          ),
          PreferenceTile(
            icon: Icons.temple_buddhist,
            title: 'Add cards to scanner',
            subtitleText: 'Adds 3 sample products to the scanner',
            onTap: () async {
              final ContinuousScanModel model =
                  context.read<ContinuousScanModel>();

              const List<String> barcodes = <String>[
                '5449000000996',
                '3017620425035',
                '3175680011480',
              ];
              for (int i = 0; i < barcodes.length; i++) {
                await model.onScan(barcodes[i]);
              }
            },
          ),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.dev_mode_section_server,
        tiles: <PreferenceTile>[
          PreferenceTile(
            icon: Icons.temple_buddhist,
            title: appLocalizations.dev_preferences_environment_switch_title,
            trailing: DropdownButton<bool>(
              value: userPreferences.getFlag(userPreferencesFlagProd) ?? true,
              elevation: 16,
              onChanged: (bool? newValue) async {
                await userPreferences.setFlag(
                    userPreferencesFlagProd, newValue);
                ProductQuery.setQueryType(userPreferences);
              },
              items: const <DropdownMenuItem<bool>>[
                DropdownMenuItem<bool>(
                  value: true,
                  child: Text('PROD'),
                ),
                DropdownMenuItem<bool>(
                  value: false,
                  child: Text('TEST'),
                ),
              ],
            ),
          ),
          if (userPreferences.getFlag(userPreferencesFlagProd) == false)
            PreferenceTile(
              icon: Icons.temple_buddhist,
              title: appLocalizations.dev_preferences_test_environment_title,
              subtitleText:
                  appLocalizations.dev_preferences_test_environment_subtitle(
                ProductQuery.getTestUriProductHelper(userPreferences)
                    .getPostUri(path: '')
                    .toString(),
              ),
              onTap: () async => _changeTestEnvDomain(
                context,
                userPreferences,
                appLocalizations,
              ),
            ),
        ],
      ),
      PreferenceCard(
        title: 'Prices Server configuration',
        tiles: <PreferenceTile>[
          PreferenceTile(
            icon: Icons.temple_buddhist,
            title:
                'Switch between prices.openfoodfacts.org (PROD) and test env',
            trailing: DropdownButton<bool>(
              value:
                  userPreferences.getFlag(userPreferencesFlagPriceProd) ?? true,
              elevation: 16,
              onChanged: (bool? newValue) async {
                await userPreferences.setFlag(
                  userPreferencesFlagPriceProd,
                  newValue,
                );
                ProductQuery.setQueryType(userPreferences);
              },
              items: const <DropdownMenuItem<bool>>[
                DropdownMenuItem<bool>(
                  value: true,
                  child: Text('PROD'),
                ),
                DropdownMenuItem<bool>(
                  value: false,
                  child: Text('TEST'),
                ),
              ],
            ),
          ),
          TogglePreferenceTile(
            icon: Icons.public,
            title: appLocalizations.send_anonymous_data_toggle_title,
            subtitleText: appLocalizations.send_anonymous_data_toggle_subtitle,
            state: userPreferences.userTracking,
            onToggle: (bool value) {
              userPreferences.setUserTracking(value);
            },
          )
        ],
      ),
      PreferenceCard(
        title: 'Folksonomy Server configuration',
        tiles: <PreferenceTile>[
          PreferenceTile(
            icon: Icons.temple_buddhist,
            title: 'Folksonomy host',
            subtitleText: ProductQuery.uriFolksonomyHelper.host,
            onTap: () async => _changeFolksonomyHost(
              context,
              userPreferences,
              appLocalizations,
            ),
          ),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.dev_mode_section_news,
        tiles: <PreferenceTile>[
          ValueEditionPreferenceTile(
            icon: Icons.temple_buddhist,
            title: appLocalizations.dev_preferences_news_custom_url_title,
            subtitleWithEmptyValue:
                appLocalizations.dev_preferences_news_custom_url_empty_value,
            dialogAction:
                appLocalizations.dev_preferences_news_custom_url_subtitle,
            value: userPreferences
                .getDevModeString(userPreferencesCustomNewsJSONURI),
            onNewValue: (String newUrl) => userPreferences.setDevModeString(
              userPreferencesCustomNewsJSONURI,
              newUrl,
            ),
            validator: (String value) =>
                value.isEmpty || Uri.tryParse(value) != null,
          ),
          PreferenceTile(
            icon: Icons.temple_buddhist,
            title: appLocalizations.dev_preferences_news_provider_status_title,
            subtitle: Consumer<AppNewsProvider>(
              builder: (_, AppNewsProvider provider, __) {
                return Text(switch (provider.state) {
                  AppNewsStateLoading() => 'Loading…',
                  AppNewsStateLoaded(lastUpdate: final DateTime date) =>
                    appLocalizations
                        .dev_preferences_news_provider_status_subtitle(
                      DateFormat.yMd().format(date),
                    ),
                  AppNewsStateError(exception: final dynamic e) => 'Error $e',
                });
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context
                  .read<AppNewsProvider>()
                  .loadLatestNews(forceUpdate: true),
            ),
          ),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.dev_mode_section_product_page,
        tiles: <PreferenceTile>[
          TogglePreferenceTile(
            icon: Icons.temple_buddhist,
            title: appLocalizations.dev_preferences_edit_ingredients_title,
            state:
                userPreferences.getFlag(userPreferencesFlagEditIngredients) ??
                    false,
            onToggle: (bool value) async {
              await userPreferences.setFlag(
                  userPreferencesFlagEditIngredients, value);

              if (!context.mounted) {
                return;
              }

              _showSuccessMessage(context, appLocalizations);
            },
          ),
          TogglePreferenceTile(
            icon: Icons.temple_buddhist,
            title: appLocalizations.dev_mode_hide_environmental_score_title,
            state: userPreferences
                .getExcludedAttributeIds()
                .contains(Attribute.ATTRIBUTE_ECOSCORE),
            onToggle: (bool value) async {
              const String tag = Attribute.ATTRIBUTE_ECOSCORE;
              final List<String> list =
                  userPreferences.getExcludedAttributeIds();
              list.removeWhere((final String element) => element == tag);
              if (value) {
                list.add(tag);
              }
              await userPreferences.setExcludedAttributeIds(list);
            },
          ),
          TogglePreferenceTile(
            icon: Icons.temple_buddhist,
            title: appLocalizations.dev_preferences_show_folksonomy_title,
            state: userPreferences.getFlag(userPreferencesFlagHideFolksonomy) ??
                true,
            onToggle: (bool value) async {
              await userPreferences.setFlag(
                userPreferencesFlagHideFolksonomy,
                value,
              );

              if (!context.mounted) {
                return;
              }

              _showSuccessMessage(context, appLocalizations);
            },
          ),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.dev_mode_section_ui,
        tiles: <PreferenceTile>[
          PreferenceTile(
            icon: Icons.temple_buddhist,
            title: appLocalizations.dev_preferences_reset_onboarding_title,
            subtitleText:
                appLocalizations.dev_preferences_reset_onboarding_subtitle,
            onTap: () async {
              await userPreferences.resetOnboarding();

              if (!context.mounted) {
                return;
              }

              _showSuccessMessage(context, appLocalizations);
            },
          ),
          TogglePreferenceTile(
            icon: Icons.temple_buddhist,
            title: 'Accessibility: remove colors',
            state: userPreferences
                    .getFlag(userPreferencesFlagAccessibilityNoColor) ??
                false,
            onToggle: (bool value) async {
              await userPreferences.setFlag(
                  userPreferencesFlagAccessibilityNoColor, value);

              if (!context.mounted) {
                return;
              }

              _showSuccessMessage(context, appLocalizations);
            },
          ),
          TogglePreferenceTile(
            icon: Icons.temple_buddhist,
            title: 'Accessibility: show emoji',
            state: userPreferences
                    .getFlag(userPreferencesFlagAccessibilityEmoji) ??
                false,
            onToggle: (bool value) async {
              await userPreferences.setFlag(
                  userPreferencesFlagAccessibilityEmoji, value);

              if (!context.mounted) {
                return;
              }

              _showSuccessMessage(context, appLocalizations);
            },
          ),
          TogglePreferenceTile(
            icon: Icons.temple_buddhist,
            title: appLocalizations.dev_mode_spellchecker_for_ocr_title,
            subtitleText:
                appLocalizations.dev_mode_spellchecker_for_ocr_subtitle,
            state:
                userPreferences.getFlag(userPreferencesFlagSpellCheckerOnOcr) ??
                    false,
            onToggle: (bool value) async => userPreferences.setFlag(
              userPreferencesFlagSpellCheckerOnOcr,
              value,
            ),
          ),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.dev_mode_section_experimental_features,
        tiles: <PreferenceTile>[
          TogglePreferenceTile(
            icon: Icons.temple_buddhist,
            title: appLocalizations.prices_bulk_proof_upload_title,
            state:
                userPreferences.getFlag(userPreferencesFlagBulkProofUpload) ??
                    false,
            onToggle: (bool value) async => userPreferences.setFlag(
              userPreferencesFlagBulkProofUpload,
              value,
            ),
          ),
          TogglePreferenceTile(
            icon: Icons.temple_buddhist,
            title: 'Multi-products selection for prices',
            state: userPreferences
                    .getFlag(userPreferencesFlagPricesReceiptMultiSelection) ??
                false,
            onToggle: (bool value) async {
              await userPreferences.setFlag(
                userPreferencesFlagPricesReceiptMultiSelection,
                value,
              );

              if (!context.mounted) {
                return;
              }

              _showSuccessMessage(context, appLocalizations);
            },
          ),
          TogglePreferenceTile(
            icon: Icons.temple_buddhist,
            title: 'User ordered knowledge panels',
            state: userPreferences.getFlag(userPreferencesFlagUserOrderedKP) ??
                false,
            onToggle: (bool value) async {
              await userPreferences.setFlag(
                  userPreferencesFlagUserOrderedKP, value);

              if (!context.mounted) {
                return;
              }

              _showSuccessMessage(context, appLocalizations);
            },
          ),
          PreferenceTile(
            icon: Icons.temple_buddhist,
            title: 'Temporary access to location search',
            onTap: () async {
              final LocalDatabase localDatabase = context.read<LocalDatabase>();
              final DaoOsmLocation daoOsmLocation =
                  DaoOsmLocation(localDatabase);
              final List<OsmLocation> osmLocations =
                  await daoOsmLocation.getAll();
              if (!context.mounted) {
                return;
              }
              final List<SearchLocationPreloadedItem> preloadedList =
                  <SearchLocationPreloadedItem>[];
              for (final OsmLocation osmLocation in osmLocations) {
                preloadedList.add(
                  SearchLocationPreloadedItem(
                    osmLocation,
                    popFirst: false,
                  ),
                );
              }
              final OsmLocation? osmLocation =
                  await Navigator.push<OsmLocation>(
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
          ),
          PreferenceTile(
            icon: Icons.temple_buddhist,
            title: 'Preference Search...',
            onTap: () async => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) =>
                    const UserPreferencesSearchPage(),
              ),
            ),
          ),
          TogglePreferenceTile(
            icon: Icons.temple_buddhist,
            title: 'Side by side comparison for 2 or 3 products',
            state:
                userPreferences.getFlag(userPreferencesFlagBoostedComparison) ??
                    false,
            onToggle: (bool value) async {
              await userPreferences.setFlag(
                  userPreferencesFlagBoostedComparison, value);

              if (!context.mounted) {
                return;
              }

              _showSuccessMessage(context, appLocalizations);
            },
          ),
          TogglePreferenceTile(
            icon: Icons.temple_buddhist,
            title: 'Product list import',
            state:
                userPreferences.getFlag(userPreferencesFlagProductListImport) ??
                    false,
            onToggle: (bool value) async {
              await userPreferences.setFlag(
                  userPreferencesFlagProductListImport, value);

              if (!context.mounted) {
                return;
              }

              _showSuccessMessage(context, appLocalizations);
            },
          ),
        ],
      ),
    ];
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _showSuccessMessage(
          BuildContext context, AppLocalizations appLocalizations) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.dev_preferences_button_positive),
        ),
      );

  Future<void> _changeTestEnvDomain(
    BuildContext context,
    UserPreferences userPreferences,
    AppLocalizations appLocalizations,
  ) async {
    _textFieldController.text =
        userPreferences.getDevModeString(userPreferencesTestEnvDomain) ??
            uriHelperFoodTest.domain;
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (final BuildContext context) => SmoothAlertDialog(
        title: appLocalizations.dev_preferences_test_environment_dialog_title,
        body: TextField(controller: _textFieldController),
        negativeAction: SmoothActionButton(
          text: appLocalizations.cancel,
          onPressed: () => Navigator.pop(context, false),
        ),
        positiveAction: SmoothActionButton(
          text: appLocalizations.okay,
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
    );
    if (result == true) {
      await userPreferences.setDevModeString(
          userPreferencesTestEnvDomain, _textFieldController.text);
      ProductQuery.setQueryType(userPreferences);
    }
  }

  Future<void> _changeFolksonomyHost(
    BuildContext context,
    UserPreferences userPreferences,
    AppLocalizations appLocalizations,
  ) async {
    _textFieldController.text = ProductQuery.uriFolksonomyHelper.host;
    final String? result = await showDialog<String>(
      context: context,
      builder: (final BuildContext context) => SmoothAlertDialog(
        title: 'Folksonomy host',
        body: TextField(controller: _textFieldController),
        negativeAction: SmoothActionButton(
          text: appLocalizations.cancel,
          onPressed: () => Navigator.pop(context),
        ),
        positiveAction: SmoothActionButton(
          text: appLocalizations.okay,
          onPressed: () => Navigator.pop(context, _textFieldController.text),
        ),
      ),
    );
    if (result != null) {
      await userPreferences.setDevModeString(
        userPreferencesFolksonomyHost,
        result,
      );
      ProductQuery.setQueryType(userPreferences);
    }
  }
}
