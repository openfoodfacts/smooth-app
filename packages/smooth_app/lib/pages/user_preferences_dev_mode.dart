import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/pages/abstract_user_preferences.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';

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
  static const String userPreferencesFlagUseMLKit = '__useMLKit';
  static const String userPreferencesFlagLenientMatching = '__lenientMatching';
  static const String userPreferencesFlagAdditionalButton =
      '__additionalButtonOnProductPage';
  static const String userPreferencesEnumScanMode = '__scanMode';

  @override
  bool isCollapsedByDefault() => true;

  @override
  String getPreferenceFlagKey() => 'devMode';

  @override
  Widget getTitle() => Container(
        color: Colors.red,
        child: Text(
          'DEV MODE',
          style: themeData.textTheme.headline2!.copyWith(color: Colors.white),
        ),
      );

  @override
  Widget? getSubtitle() => null;

  @override
  List<Widget> getBody() => <Widget>[
        ListTile(
          title: const Text('Remove dev mode'),
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
          title: const Text('Restart onboarding'),
          subtitle:
              const Text('You then have to restart Flutter to see it again.'),
          onTap: () async {
            userPreferences
                .setLastVisitedOnboardingPage(OnboardingPage.NOT_STARTED);
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Ok')));
          },
        ),
        ListTile(
          title: const Text('Switch between openfoodfacts.org and .net'),
          subtitle: Text(
            'Current query type is ${OpenFoodAPIConfiguration.globalQueryType}',
          ),
          onTap: () async {
            await userPreferences.setFlag(userPreferencesFlagProd,
                !(userPreferences.getFlag(userPreferencesFlagProd) ?? true));
            ProductQuery.setQueryType(userPreferences);
            setState(() {});
          },
        ),
        SwitchListTile(
          title: const Text('Use ML Kit'),
          subtitle: const Text('then you have to restart this app'),
          value: userPreferences.getFlag(userPreferencesFlagUseMLKit) ?? true,
          onChanged: (bool value) async {
            await userPreferences.setFlag(userPreferencesFlagUseMLKit, value);
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Ok')));
          },
        ),
        SwitchListTile(
          title: const Text('Additional button on product page'),
          value: userPreferences.getFlag(userPreferencesFlagAdditionalButton) ??
              false,
          onChanged: (bool value) async {
            await userPreferences.setFlag(
                userPreferencesFlagAdditionalButton, value);
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Ok')));
          },
        ),
        ListTile(
          title: const Text('Export History'),
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
                      ? 'exception'
                      : exists
                          ? 'product found'
                          : 'product NOT found'),
                ),
              );
            }
            showDialog<void>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('export history'),
                content: SizedBox(
                  height: 400,
                  width: 300,
                  child: ListView(children: children),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: Text(AppLocalizations.of(context)!.okay),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          },
        ),
        ListTile(
          title: const Text('Switch between strong and lenient matching'),
          subtitle: Text(
            'Current matching level is '
            '${(userPreferences.getFlag(userPreferencesFlagLenientMatching) ?? false) ? 'strong' : 'lenient'}',
          ),
          onTap: () async {
            await userPreferences.setFlag(
                userPreferencesFlagLenientMatching,
                !(userPreferences.getFlag(userPreferencesFlagLenientMatching) ??
                    false));
            setState(() {});
          },
        ),
        ListTile(
          title: const Text('Scan Mode'),
          subtitle: Text(
            'Current scan mode is :"'
            '${DevModeScanModeExtension.fromIndex(userPreferences.getDevModeIndex(userPreferencesEnumScanMode)).label}'
            '"',
          ),
          onTap: () async {
            final DevModeScanMode? scanMode = await showDialog<DevModeScanMode>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Scan Mode'),
                content: SizedBox(
                  height: 400,
                  width: 300,
                  child: ListView.builder(
                    itemCount: DevModeScanMode.values.length,
                    itemBuilder: (final BuildContext context, final int index) {
                      final DevModeScanMode scanMode =
                          DevModeScanMode.values[index];
                      return ListTile(
                        title: Text(scanMode.label),
                        onTap: () => Navigator.pop(context, scanMode),
                      );
                    },
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text('cancel'),
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
      ];
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
