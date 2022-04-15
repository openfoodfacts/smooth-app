import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  Future<PermissionStatus> _permissionCheck() async {
    final PermissionStatus status = await Permission.camera.status;

    // If is denied, is not restricted by for example parental control and is
    // not already declined once
    if (status.isDenied && !status.isRestricted) {
      final PermissionStatus newStatus = await Permission.camera.request();
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
      future: _permissionCheck(),
      builder: (
        BuildContext context,
        AsyncSnapshot<PermissionStatus> snapshot,
      ) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text(appLocalizations.permission_photo_error));
        }

        final PermissionStatus status = snapshot.data!;

        Widget? topChild;
        Widget? backgroundChild;

        if (!status.isGranted) {
          topChild = PermissionDeniedWidget(
            status: status,
          );
        } else if (userPreferences.getFlag(
              UserPreferencesDevMode.userPreferencesFlagUseMLKit,
            ) ??
            true) {
          backgroundChild = const MLKitScannerPage();
        } else {
          backgroundChild = const ContinuousScanPage();
        }

        return ChangeNotifierProvider<ContinuousScanModel>(
          create: (BuildContext context) => _model!,
          child: Scaffold(
            body: ScannerOverlay(
              backgroundChild: backgroundChild,
              topChild: topChild,
            ),
          ),
        );
      },
    );
  }
}

class PermissionDeniedWidget extends StatelessWidget {
  const PermissionDeniedWidget({
    required this.status,
    Key? key,
  }) : super(key: key);

  final PermissionStatus status;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    return Container(
      color: Colors.red,
      child: Center(
        child: Text(appLocalizations.permission_photo_denied),
      ),
    );
  }
}
