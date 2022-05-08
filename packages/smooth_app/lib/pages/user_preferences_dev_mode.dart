import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/helpers/product_list_import_export.dart';
import 'package:smooth_app/pages/abstract_user_preferences.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/pages/scan/ml_kit_scan_page.dart';
import 'package:smooth_app/pages/user_preferences_dialog_editor.dart';

/// Collapsed/expanded display of "dev mode" for the preferences page.
///
/// The dev mode is triggered this way:
/// * go to the "forgotten password" page
/// * click 10 times on the action button (in French "Changer le mot de passe")
/// * you'll see a dialog; obviously click "yes"
/// * go to the preferences page
/// * expand/collapse any item
/// * then you'll see the dev mode in red
class UserPreferencesDevMode extends AbstractUserPreferences {
  UserPreferencesDevMode({
    required final Function(Function()) setState,
    required final BuildContext context,
    required final UserPreferences userPreferences,
    required final AppLocalizations appLocalizations,
    required final ThemeData themeData,
  }) : super(
          setState: setState,
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );

  static const String userPreferencesFlagProd = '__devWorkingOnProd';
  static const String userPreferencesTestEnvHost = '__testEnvHost';
  static const String userPreferencesFlagUseMLKit = '__useMLKit';
  static const String userPreferencesFlagStrongMatching = '__lenientMatching';
  static const String userPreferencesFlagAdditionalButton =
      '__additionalButtonOnProductPage';
  static const String userPreferencesFlagEditIngredients = '__editIngredients';
  static const String userPreferencesEnumScanMode = '__scanMode';
  static const String userPreferencesCameraPostFrameDuration =
      '__cameraPostFrameDuration';

  final TextEditingController _textFieldController = TextEditingController();

  @override
  bool isCollapsedByDefault() => true;

  @override
  String getPreferenceFlagKey() => 'devMode';

  @override
  Widget getTitle() => Container(
        color: Colors.red,
        child: Text(
          appLocalizations.dev_preferences_screen_title,
          style: themeData.textTheme.headline2!.copyWith(color: Colors.white),
        ),
      );

  @override
  Widget? getSubtitle() => null;

  @override
  List<Widget> getBody() => <Widget>[
        ListTile(
          title: Text(
            appLocalizations.dev_preferences_disable_mode,
          ),
          onTap: () async {
            // resetting back to "no dev mode"
            await userPreferences.setDevMode(0);
            // resetting back to PROD
            await userPreferences.setFlag(userPreferencesFlagProd, true);
            ProductQuery.setQueryType(userPreferences);
            setState(() {});
          },
        ),
        ListTile(
          title: Text(
            appLocalizations.dev_preferences_reset_onboarding_title,
          ),
          subtitle: Text(
            appLocalizations.dev_preferences_reset_onboarding_subtitle,
          ),
          onTap: () async {
            userPreferences
                .setLastVisitedOnboardingPage(OnboardingPage.NOT_STARTED);
            _showSuccessMessage();
          },
        ),
        ListTile(
          title: Text(
            appLocalizations.dev_preferences_environment_switch_title,
          ),
          subtitle: Text(
            appLocalizations.dev_preferences_environment_switch_subtitle(
              OpenFoodAPIConfiguration.globalQueryType.toString(),
            ),
          ),
          onTap: () async {
            await userPreferences.setFlag(userPreferencesFlagProd,
                !(userPreferences.getFlag(userPreferencesFlagProd) ?? true));
            ProductQuery.setQueryType(userPreferences);
            setState(() {});
          },
        ),
        ListTile(
          title: Text(
            appLocalizations.dev_preferences_test_environment_title,
          ),
          subtitle: Text(
            appLocalizations.dev_preferences_test_environment_subtitle(
              '${OpenFoodAPIConfiguration.uriScheme}://${OpenFoodAPIConfiguration.uriTestHost}/',
            ),
          ),
          onTap: () async => _changeTestEnvHost(),
        ),
        SwitchListTile(
          title: Text(
            appLocalizations.dev_preferences_ml_kit_title,
          ),
          subtitle: Text(
            appLocalizations.dev_preferences_ml_kit_subtitle,
          ),
          value: userPreferences.getFlag(userPreferencesFlagUseMLKit) ?? true,
          onChanged: (bool value) async {
            await userPreferences.setFlag(userPreferencesFlagUseMLKit, value);
            _showSuccessMessage();
          },
        ),
        ListTile(
          title: const Text('Change camera post frame callback duration'),
          onTap: () async => _changeCameraPostFrameCallbackDuration(),
        ),
        SwitchListTile(
          title: Text(
            appLocalizations.dev_preferences_product_additional_features_title,
          ),
          value: userPreferences.getFlag(userPreferencesFlagAdditionalButton) ??
              false,
          onChanged: (bool value) async {
            await userPreferences.setFlag(
                userPreferencesFlagAdditionalButton, value);
            _showSuccessMessage();
          },
        ),
        SwitchListTile(
          title: Text(
            appLocalizations.dev_preferences_edit_ingredients_title,
          ),
          value: userPreferences.getFlag(userPreferencesFlagEditIngredients) ??
              false,
          onChanged: (bool value) async {
            await userPreferences.setFlag(
                userPreferencesFlagEditIngredients, value);
            _showSuccessMessage();
          },
        ),
        ListTile(
          title: Text(
            appLocalizations.dev_preferences_export_history_title,
          ),
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
            showDialog<void>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text(
                  appLocalizations.dev_preferences_export_history_dialog_title,
                ),
                content: SizedBox(
                  height: 400,
                  width: 300,
                  child: ListView(children: children),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: Text(
                      appLocalizations.dev_preferences_button_positive,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          },
        ),
        ListTile(
          title: Text(
            appLocalizations.dev_preferences_import_history_title,
          ),
          subtitle: Text(
            appLocalizations.dev_preferences_import_history_subtitle,
          ),
          onTap: () async {
            final LocalDatabase localDatabase = context.read<LocalDatabase>();
            await ProductListImportExport().import(
              ProductListImportExport.TMP_IMPORT,
              localDatabase,
            );
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
        ListTile(
          title: Text(
            appLocalizations.dev_mode_matching_mode_title,
          ),
          subtitle: Text(
            appLocalizations.dev_mode_matching_mode_subtitle(
              (userPreferences.getFlag(userPreferencesFlagStrongMatching) ??
                      false)
                  ? appLocalizations.dev_mode_matching_mode_value_strong
                  : appLocalizations.dev_mode_matching_mode_value_lenient,
            ),
          ),
          onTap: () async {
            await userPreferences.setFlag(
                userPreferencesFlagStrongMatching,
                !(userPreferences.getFlag(userPreferencesFlagStrongMatching) ??
                    false));
            setState(() {});
          },
        ),
        ListTile(
          title: Text(
            appLocalizations.dev_mode_scan_mode_title,
          ),
          subtitle: Text(
            appLocalizations
                .dev_mode_scan_mode_subtitle(DevModeScanModeExtension.fromIndex(
              userPreferences.getDevModeIndex(
                userPreferencesEnumScanMode,
              ),
            ).localizedLabel(appLocalizations)),
          ),
          onTap: () async {
            final DevModeScanMode? scanMode = await showDialog<DevModeScanMode>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text(
                  appLocalizations.dev_mode_scan_mode_dialog_title,
                ),
                content: SizedBox(
                  height: 400,
                  width: 300,
                  child: ListView.builder(
                    itemCount: DevModeScanMode.values.length,
                    itemBuilder: (final BuildContext context, final int index) {
                      final DevModeScanMode scanMode =
                          DevModeScanMode.values[index];
                      return ListTile(
                        title: Text(scanMode.localizedLabel(appLocalizations)),
                        onTap: () => Navigator.pop(context, scanMode),
                      );
                    },
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: Text(
                      appLocalizations.dev_preferences_button_negative,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
            if (scanMode != null) {
              await userPreferences.setDevModeIndex(
                userPreferencesEnumScanMode,
                scanMode.index,
              );
              setState(() {});
            }
          },
        ),
        SwitchListTile(
          title: Text(
            appLocalizations.dev_mode_hide_ecoscore_title,
          ),
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
            setState(() {});
          },
        ),
      ];

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      _showSuccessMessage() {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appLocalizations.dev_preferences_button_positive),
      ),
    );
  }

  Future<void> _changeTestEnvHost() async {
    _textFieldController.text =
        userPreferences.getDevModeString(userPreferencesTestEnvHost) ??
            OpenFoodAPIConfiguration.uriTestHost;
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (final BuildContext context) => AlertDialog(
        title: Text(
          appLocalizations.dev_preferences_test_environment_dialog_title,
        ),
        content: TextField(controller: _textFieldController),
        actions: <Widget>[
          TextButton(
            child: Text(
              appLocalizations.dev_preferences_button_negative,
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: Text(
              appLocalizations.dev_preferences_button_positive,
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (result == true) {
      await userPreferences.setDevModeString(
          userPreferencesTestEnvHost, _textFieldController.text);
      ProductQuery.setQueryType(userPreferences);
      setState(() {});
    }
  }

  Future<void> _changeCameraPostFrameCallbackDuration() async {
    const int minValue = MLKitScannerPageState.postFrameCallbackStandardDelay;
    final int initialValue = userPreferences.getDevModeIndex(
          userPreferencesCameraPostFrameDuration,
        ) ??
        minValue;

    final int? result = await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return UserPreferencesEditValueDialog<int>(
            label: 'Camera post frame callback duration',
            initialValue: initialValue,
            converter: (String value) => int.tryParse(value) ?? 0,
            validator: (int? newValue) =>
                newValue != null && newValue >= minValue,
            textAlignment: TextAlign.center,
            keyboardType: TextInputType.number,
          );
        });

    if (result is int && result > minValue) {
      userPreferences.setDevModeIndex(
        userPreferencesCameraPostFrameDuration,
        result,
      );

      setState(() {});
    }
  }
}

enum DevModeScanMode {
  CAMERA_ONLY,
  PREPROCESS_FULL_IMAGE,
  PREPROCESS_HALF_IMAGE,
  SCAN_FULL_IMAGE,
  SCAN_HALF_IMAGE,
}

extension DevModeScanModeExtension on DevModeScanMode {
  static const DevModeScanMode defaultScanMode =
      DevModeScanMode.SCAN_FULL_IMAGE;

  static const Map<DevModeScanMode, String> _labels = <DevModeScanMode, String>{
    DevModeScanMode.CAMERA_ONLY: 'Only camera stream, no scanning',
    DevModeScanMode.PREPROCESS_FULL_IMAGE:
        'Camera stream and full image preprocessing, no scanning',
    DevModeScanMode.PREPROCESS_HALF_IMAGE:
        'Camera stream and half image preprocessing, no scanning',
    DevModeScanMode.SCAN_FULL_IMAGE: 'Full image scanning',
    DevModeScanMode.SCAN_HALF_IMAGE: 'Half image scanning',
  };

  static const Map<DevModeScanMode, int> _indices = <DevModeScanMode, int>{
    DevModeScanMode.CAMERA_ONLY: 4,
    DevModeScanMode.PREPROCESS_FULL_IMAGE: 3,
    DevModeScanMode.PREPROCESS_HALF_IMAGE: 2,
    DevModeScanMode.SCAN_FULL_IMAGE: 0,
    DevModeScanMode.SCAN_HALF_IMAGE: 1,
  };

  String get label => _labels[this]!;

  String localizedLabel(AppLocalizations appLocalizations) {
    switch (this) {
      case DevModeScanMode.CAMERA_ONLY:
        return appLocalizations.dev_mode_scan_camera_only;
      case DevModeScanMode.PREPROCESS_FULL_IMAGE:
        return appLocalizations.dev_mode_scan_preprocess_full_image;
      case DevModeScanMode.PREPROCESS_HALF_IMAGE:
        return appLocalizations.dev_mode_scan_preprocess_half_image;
      case DevModeScanMode.SCAN_FULL_IMAGE:
        return appLocalizations.dev_mode_scan_scan_full_image;
      case DevModeScanMode.SCAN_HALF_IMAGE:
        return appLocalizations.dev_mode_scan_scan_half_image;
    }
  }

  int get index => _indices[this]!;

  static DevModeScanMode fromIndex(final int? index) {
    if (index == null) {
      return defaultScanMode;
    }
    for (final DevModeScanMode scanMode in DevModeScanMode.values) {
      if (scanMode.index == index) {
        return scanMode;
      }
    }
    throw Exception('Unknown index $index');
  }
}
