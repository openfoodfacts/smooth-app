import 'dart:async';

import 'package:flutter/material.dart' hide Listener;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:provider/provider.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/pages/scan/scan_header.dart';

/// A page showing the camera feed and decoding barcodes.
class CameraScannerPage extends StatefulWidget {
  const CameraScannerPage();

  @override
  CameraScannerPageState createState() => CameraScannerPageState();
}

class CameraScannerPageState extends State<CameraScannerPage>
    with TraceableClientMixin {
  final GlobalKey<State<StatefulWidget>> _headerKey = GlobalKey();

  late ContinuousScanModel _model;
  late UserPreferences _userPreferences;
  double? _headerHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (mounted) {
      _model = context.watch<ContinuousScanModel>();
      _userPreferences = context.watch<UserPreferences>();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _headerHeight =
            (_headerKey.currentContext?.findRenderObject() as RenderBox?)
                ?.size
                .height;
      });
    });
  }

  @override
  String get traceTitle => '${GlobalVars.barcodeScanner.getType()}_page';

  @override
  String get traceName => 'Opened ${GlobalVars.barcodeScanner.getType()}_page';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    if (!CameraHelper.hasACamera) {
      return Center(
        child: Text(appLocalizations.permission_photo_none_found),
      );
    }

    return ScreenVisibilityDetector(
      child: Stack(
        children: <Widget>[
          GlobalVars.barcodeScanner.getScanner(
            onScan: _onNewBarcodeDetected,
            hapticFeedback: () => SmoothHapticFeedback.click(),
            onCameraFlashError: _onCameraFlashError,
            trackCustomEvent: AnalyticsHelper.trackCustomEvent,
            hasMoreThanOneCamera: CameraHelper.hasMoreThanOneCamera,
            toggleCameraModeTooltip: appLocalizations.camera_toggle_camera,
            toggleFlashModeTooltip: appLocalizations.camera_toggle_flash,
            contentPadding: _model.compareFeatureEnabled
                ? EdgeInsets.only(top: _headerHeight ?? 0.0)
                : null,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ScanHeader(
              key: _headerKey,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onNewBarcodeDetected(final String barcode) async {
    if (!await _model.onScan(barcode)) {
      return false;
    }

    _userPreferences.incrementScanCount();
    return true;
  }

  void _onCameraFlashError(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (_) => SmoothAlertDialog(
        title: appLocalizations.camera_flash_error_dialog_title,
        body: Text(appLocalizations.camera_flash_error_dialog_message),
      ),
    );
  }
}
