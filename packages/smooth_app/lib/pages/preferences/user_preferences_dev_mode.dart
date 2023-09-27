import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_badge.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/data_importer/product_list_import_export.dart';
import 'package:smooth_app/helpers/data_importer/smooth_app_data_importer.dart';
import 'package:smooth_app/pages/offline_data_page.dart';
import 'package:smooth_app/pages/offline_tasks_page.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_debug_info.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_search_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';
import 'package:smooth_app/query/product_query.dart';

/// Full page display of "dev mode" for the preferences page.
///
/// The dev mode is triggered by a switch in
/// Settings => FAQ => Develop => Clicking switch
class UserPreferencesDevMode extends AbstractUserPreferences {
  UserPreferencesDevMode({
    required final BuildContext context,
    required final UserPreferences userPreferences,
    required final AppLocalizations appLocalizations,
    required final ThemeData themeData,
  }) : super(
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );

  static const String userPreferencesFlagProd = '__devWorkingOnProd';
  static const String userPreferencesTestEnvHost = '__testEnvHost';
  static const String userPreferencesFlagEditIngredients = '__editIngredients';
  static const String userPreferencesFlagBoostedComparison =
      '__boostedComparison';
  static const String userPreferencesEnumScanMode = '__scanMode';
  static const String userPreferencesAppLanguageCode = '__appLanguage';
  static const String userPreferencesFlagAccessibilityNoColor =
      '__accessibilityNoColor';
  static const String userPreferencesFlagAccessibilityEmoji =
      '__accessibilityEmoji';

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
          title: appLocalizations.dev_preferences_reset_onboarding_title,
          subtitle: appLocalizations.dev_preferences_reset_onboarding_subtitle,
          onTap: () async {
            await userPreferences.resetOnboarding();
            _showSuccessMessage();
          },
        ),
        UserPreferencesItemTile(
          title: appLocalizations.dev_preferences_environment_switch_title,
          trailing: DropdownButton<bool>(
            value: OpenFoodAPIConfiguration.globalQueryType == QueryType.PROD,
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
            '${OpenFoodAPIConfiguration.uriScheme}://${OpenFoodAPIConfiguration.uriTestHost}/',
          ),
          onTap: () async => _changeTestEnvHost(),
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

            // ignore: use_build_context_synchronously
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
        _dataImporterTile(),
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
          title: appLocalizations.dev_preferences_import_history_title,
          subtitle: appLocalizations.dev_preferences_import_history_subtitle,
          onTap: () async {
            final LocalDatabase localDatabase = context.read<LocalDatabase>();
            await ProductListImportExport().importFromJSON(
              ProductListImportExport.TMP_IMPORT,
              localDatabase,
            );
            //ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  appLocalizations
                      .dev_preferences_import_history_result_success,
                ),
              ),
            );
            localDatabase.notifyListeners();
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
        UserPreferencesItemSwitch(
          title: appLocalizations.dev_mode_hide_ecoscore_title,
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
        UserPreferencesItemTile(
          // Do not translate
          title: 'Reset app language',
          onTap: () async {
            userPreferences.setAppLanguageCode(null);
            ProductQuery.setLanguage(context, userPreferences);
          },
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
        UserPreferencesItemTile(
          title: 'Debugging information',
          onTap: () async => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (BuildContext context) =>
                  const UserPreferencesDebugInfo())),
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
      ];

  UserPreferencesItem _dataImporterTile() {
    final SmoothAppDataImporterStatus status =
        context.read<SmoothAppDataImporter>().status;

    return UserPreferencesItemTile(
      title: appLocalizations.dev_preferences_migration_title,
      subtitle: appLocalizations.dev_preferences_migration_subtitle(
        status.printableLabel(appLocalizations),
      ),
      onTap: status.canInitiateMigration
          ? () {
              context.read<SmoothAppDataImporter>().startMigrationAsync(
                    forceMigration: true,
                  );
            }
          : null,
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      _showSuccessMessage() => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appLocalizations.dev_preferences_button_positive),
            ),
          );

  Future<void> _changeTestEnvHost() async {
    _textFieldController.text =
        userPreferences.getDevModeString(userPreferencesTestEnvHost) ??
            OpenFoodAPIConfiguration.uriTestHost;
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
          userPreferencesTestEnvHost, _textFieldController.text);
      ProductQuery.setQueryType(userPreferences);
    }
  }
}
