import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/scan/continuous_scan_page.dart';
import 'package:smooth_app/pages/scan/ml_kit_scan_page.dart';
import 'package:smooth_app/pages/user_preferences_dev_mode.dart';

class ScanPage extends StatefulWidget {
  const ScanPage();

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  ContinuousScanModel? _model;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateModel();
  }

  Future<void> _updateModel() async {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    if (_model == null) {
      _model = await ContinuousScanModel().load(localDatabase);
    } else {
      await _model?.refresh();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.read<UserPreferences>();
    if (_model == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final Widget child;

    if (userPreferences.getFlag(
          UserPreferencesDevMode.userPreferencesFlagUseMLKit,
        ) ??
        true) {
      child = const MLKitScannerPage();
    } else {
      child = const ContinuousScanPage();
    }

    return ChangeNotifierProvider<ContinuousScanModel>(
      create: (BuildContext context) => _model!,
      child: child,
    );
  }
}
