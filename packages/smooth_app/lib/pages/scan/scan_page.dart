import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/scan/continuous_scan_page.dart';
import 'package:smooth_app/pages/scan/ml_kit_scan_page.dart';
import 'package:smooth_app/pages/scan/scanner_overlay.dart';
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

  Future<PermissionStatus> _permissionCheck(
    UserPreferences userPreferences,
  ) async {
    final PermissionStatus status = await Permission.camera.status;

    // If is denied, is not restricted by for example parental control and is
    // not already declined once
    if (status.isDenied &&
        !status.isRestricted &&
        !userPreferences.cameraDeclinedOnce) {
      final PermissionStatus newStatus = await Permission.camera.request();
      if (!newStatus.isGranted && !newStatus.isLimited) {
        userPreferences.setCameraDecline(true);
      }
      return newStatus;
    } else {
      return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.read<UserPreferences>();
    if (_model == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<PermissionStatus>(
      future: _permissionCheck(userPreferences),
      builder: (
        BuildContext context,
        AsyncSnapshot<PermissionStatus> snapshot,
      ) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        }

        // TODO(M123): show no camera access screen
        if (snapshot.data!.isDenied ||
            snapshot.data!.isPermanentlyDenied ||
            snapshot.data!.isRestricted) {
          const Center(
            child: Text('No camera access granted'),
          );
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
          child: Scaffold(
            body: ScannerOverlay(
              child: child,
            ),
          ),
        );
      },
    );
  }
}
