import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_badge.dart';
import 'package:smooth_app/background/background_task_language_refresh.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
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
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_debug_info.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_search_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';
import 'package:smooth_app/pages/search/search_page.dart';
import 'package:smooth_app/query/product_query.dart';

/// Full page display of "dev mode" for the preferences page.
///
/// The dev mode is triggered by a switch in
/// Settings => FAQ => Develop => Clicking switch
class UserPreferencesDevMode extends AbstractUserPreferences {
  UserPreferencesDevMode({
    required super.context,
    required super.userPreferences,
    required super.appLocalizations,
    required super.themeData,
  });

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

  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      GlobalMaterialLocalizations.delegate;

  @override
  PreferencePageType getPreferencePageType() => PreferencePageType.DEV_MODE;

  @override
  String getTitleString() => appLocalizations.dev_preferences_screen_title;

  @override
  Widget getTitle() => Container(
        color: Colors.red,
        child: Text(
          getTitleString(),
          style:
              themeData.textTheme.displayMedium!.copyWith(color: Colors.white),
        ),
      );

  @override
  IconData getLeadingIconData() => Icons.settings;

  @override
  List<UserPreferencesItem> getChildren() => <UserPreferencesItem>[
        UserPreferencesItemSwitch(
          title: appLocalizations.contribute_develop_dev_mode_title,
          onChanged: (bool value) async {
            final NavigatorState navigator = Navigator.of(context);
            // resetting back to "no dev mode"
            await userPreferences.setDevMode(0);
            // resetting back to PROD
            await userPreferences.setFlag(userPreferencesFlagProd, true);
            ProductQuery.setQueryType(userPreferences);
            navigator.pop();
          },
          value: userPreferences.devMode == 1,
        ),
        UserPreferencesItemTile(
          title: 'Debugging information',
          onTap: () async => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (BuildContext context) =>
                  const UserPreferencesDebugInfo())),
        ),
        UserPreferencesItemSection(
          label: appLocalizations.dev_mode_section_data,
        ),
        UserPreferencesItemTile(
          title: appLocalizations.background_task_title,
          subtitle: appLocalizations.background_task_subtitle,
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
        UserPreferencesItemTile(
          title: appLocalizations.offline_data,
          onTap: () => Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const OfflineDataPage(),
            ),
          ),
        ),
        UserPreferencesItemTile(
          title: appLocalizations.dev_preferences_export_history_title,
          subtitle: appLocalizations.clipboard_barcode_copy,
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
        UserPreferencesItemTile(
          title: 'Refresh all products from server (cf. Nutriscore v2)',
          trailing: const Icon(Icons.refresh),
          onTap: () async {
            final LocalDatabase localDatabase = context.read<LocalDatabase>();
            final DaoProduct daoProduct = DaoProduct(localDatabase);
            await daoProduct.clearAllLanguages();
            await BackgroundTaskLanguageRefresh.addTask(localDatabase);
            _showSuccessMessage();
          },
        ),
        UserPreferencesItemTile(
          // Do not translate
          title: 'Reset app language',
          onTap: () async {
            userPreferences.setAppLanguageCode(null);
            ProductQuery.setLanguage(context, userPreferences);
          },
        ),
        UserPreferencesItemTile(
          title: 'Add cards to scanner',
          subtitle: 'Adds 3 sample products to the scanner',
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
        UserPreferencesItemSection(
          label: appLocalizations.dev_mode_section_server,
        ),
        UserPreferencesItemTile(
          title: appLocalizations.dev_preferences_environment_switch_title,
          trailing: DropdownButton<bool>(
            value: userPreferences.getFlag(userPreferencesFlagProd) ?? true,
            elevation: 16,
            onChanged: (bool? newValue) async {
              await userPreferences.setFlag(userPreferencesFlagProd, newValue);
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
        UserPreferencesItemTile(
          title: appLocalizations.dev_preferences_test_environment_title,
          subtitle: appLocalizations.dev_preferences_test_environment_subtitle(
            ProductQuery.getTestUriProductHelper(userPreferences)
                .getPostUri(path: '')
                .toString(),
          ),
          visibleWhen: (BuildContext context) {
            return userPreferences.getFlag(userPreferencesFlagProd) == false;
          },
          onTap: () async => _changeTestEnvDomain(),
        ),
        const UserPreferencesItemSection(
          label: 'Prices Server configuration',
        ),
        UserPreferencesItemTile(
          title: 'Switch between prices.openfoodfacts.org (PROD) and test env',
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
        const UserPreferencesItemSection(
          label: 'Folksonomy Server configuration',
        ),
        UserPreferencesItemTile(
          title: 'Folksonomy host',
          subtitle: ProductQuery.uriFolksonomyHelper.host,
          onTap: () async => _changeFolksonomyHost(),
        ),
        UserPreferencesItemSection(
          label: appLocalizations.dev_mode_section_news,
        ),
        UserPreferencesEditableItemTile(
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
        UserPreferencesItemTileBuilder(
          title: appLocalizations.dev_preferences_news_provider_status_title,
          subtitleBuilder: (BuildContext context) {
            return Consumer<AppNewsProvider>(
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
            });
          },
          trailingBuilder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context
                  .read<AppNewsProvider>()
                  .loadLatestNews(forceUpdate: true),
            );
          },
        ),
        UserPreferencesItemSection(
          label: appLocalizations.dev_mode_section_product_page,
        ),
        UserPreferencesItemSwitch(
          title: appLocalizations.dev_preferences_edit_ingredients_title,
          value: userPreferences.getFlag(userPreferencesFlagEditIngredients) ??
              false,
          onChanged: (bool value) async {
            await userPreferences.setFlag(
                userPreferencesFlagEditIngredients, value);
            _showSuccessMessage();
          },
        ),
        UserPreferencesItemSwitch(
          title: appLocalizations.dev_mode_hide_environmental_score_title,
          value: userPreferences
              .getExcludedAttributeIds()
              .contains(Attribute.ATTRIBUTE_ECOSCORE),
          onChanged: (bool value) async {
            const String tag = Attribute.ATTRIBUTE_ECOSCORE;
            final List<String> list = userPreferences.getExcludedAttributeIds();
            list.removeWhere((final String element) => element == tag);
            if (value) {
              list.add(tag);
            }
            await userPreferences.setExcludedAttributeIds(list);
          },
        ),
        UserPreferencesItemSwitch(
          title: appLocalizations.dev_preferences_show_folksonomy_title,
          value: userPreferences.getFlag(userPreferencesFlagHideFolksonomy) ??
              true,
          onChanged: (bool value) async {
            await userPreferences.setFlag(
              userPreferencesFlagHideFolksonomy,
              value,
            );
            _showSuccessMessage();
          },
        ),
        UserPreferencesItemSection(
          label: appLocalizations.dev_mode_section_ui,
        ),
        UserPreferencesItemTile(
          title: appLocalizations.dev_preferences_reset_onboarding_title,
          subtitle: appLocalizations.dev_preferences_reset_onboarding_subtitle,
          onTap: () async {
            await userPreferences.resetOnboarding();
            _showSuccessMessage();
          },
        ),
        UserPreferencesItemSwitch(
          title: 'Accessibility: remove colors',
          value: userPreferences
                  .getFlag(userPreferencesFlagAccessibilityNoColor) ??
              false,
          onChanged: (bool value) async {
            await userPreferences.setFlag(
                userPreferencesFlagAccessibilityNoColor, value);
            _showSuccessMessage();
          },
        ),
        UserPreferencesItemSwitch(
          title: 'Accessibility: show emoji',
          value:
              userPreferences.getFlag(userPreferencesFlagAccessibilityEmoji) ??
                  false,
          onChanged: (bool value) async {
            await userPreferences.setFlag(
                userPreferencesFlagAccessibilityEmoji, value);
            _showSuccessMessage();
          },
        ),
        UserPreferencesItemSwitch(
          title: appLocalizations.dev_mode_spellchecker_for_ocr_title,
          subtitle: appLocalizations.dev_mode_spellchecker_for_ocr_subtitle,
          value:
              userPreferences.getFlag(userPreferencesFlagSpellCheckerOnOcr) ??
                  false,
          onChanged: (bool value) async => userPreferences.setFlag(
            userPreferencesFlagSpellCheckerOnOcr,
            value,
          ),
        ),
        UserPreferencesItemSection(
          label: appLocalizations.dev_mode_section_experimental_features,
        ),
        UserPreferencesItemSwitch(
          title: appLocalizations.prices_bulk_proof_upload_title,
          value: userPreferences.getFlag(userPreferencesFlagBulkProofUpload) ??
              false,
          onChanged: (bool value) async => userPreferences.setFlag(
            userPreferencesFlagBulkProofUpload,
            value,
          ),
        ),
        UserPreferencesItemSwitch(
          title: 'Multi-products selection for prices',
          value: userPreferences
                  .getFlag(userPreferencesFlagPricesReceiptMultiSelection) ??
              false,
          onChanged: (bool value) async {
            await userPreferences.setFlag(
              userPreferencesFlagPricesReceiptMultiSelection,
              value,
            );
            _showSuccessMessage();
          },
        ),
        UserPreferencesItemSwitch(
          title: 'User ordered knowledge panels',
          value: userPreferences.getFlag(userPreferencesFlagUserOrderedKP) ??
              false,
          onChanged: (bool value) async {
            await userPreferences.setFlag(
                userPreferencesFlagUserOrderedKP, value);
            _showSuccessMessage();
          },
        ),
        UserPreferencesItemTile(
          title: 'Temporary access to location search',
          onTap: () async {
            final LocalDatabase localDatabase = context.read<LocalDatabase>();
            final DaoOsmLocation daoOsmLocation = DaoOsmLocation(localDatabase);
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
        ),
        UserPreferencesItemTile(
          title: 'Preference Search...',
          onTap: () async => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) =>
                  const UserPreferencesSearchPage(),
            ),
          ),
        ),
        UserPreferencesItemSwitch(
          title: 'Side by side comparison for 2 or 3 products',
          value:
              userPreferences.getFlag(userPreferencesFlagBoostedComparison) ??
                  false,
          onChanged: (bool value) async {
            await userPreferences.setFlag(
                userPreferencesFlagBoostedComparison, value);
            _showSuccessMessage();
          },
        ),
        UserPreferencesItemSwitch(
          title: 'Product list import',
          value:
              userPreferences.getFlag(userPreferencesFlagProductListImport) ??
                  false,
          onChanged: (bool value) async {
            await userPreferences.setFlag(
                userPreferencesFlagProductListImport, value);
            _showSuccessMessage();
          },
        ),
      ];

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      _showSuccessMessage() => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appLocalizations.dev_preferences_button_positive),
            ),
          );

  Future<void> _changeTestEnvDomain() async {
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

  Future<void> _changeFolksonomyHost() async {
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
