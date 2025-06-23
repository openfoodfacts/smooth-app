import 'dart:async';

import 'package:flutter/material.dart' hide Listener;
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
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/scan/scan_header.dart';

/// A page showing the camera feed and decoding barcodes.
class CameraScannerPage extends StatefulWidget {
  const CameraScannerPage();

  @override
  State<CameraScannerPage> createState() => _CameraScannerPageState();

  static Future<void> onCameraFlashError(BuildContext context) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      builder: (_) => SmoothAlertDialog(
        title: appLocalizations.camera_flash_error_dialog_title,
        body: Text(appLocalizations.camera_flash_error_dialog_message),
      ),
    );
  }
}

class _CameraScannerPageState extends State<CameraScannerPage>
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

    _detectHeaderHeight();
  }

  /// In some cases, the size may be null
  /// (Mainly when the app is launched for the first time AND in release mode)
  void _detectHeaderHeight([int retries = 0]) {
    // Let's try during 5 frames (should be enough, as 2 or 3 seems to be an average)
    if (retries > 5) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _headerHeight =
            (_headerKey.currentContext?.findRenderObject() as RenderBox?)
                ?.size
                .height;
      } catch (_) {
        _headerHeight = null;
      }

      if (_headerHeight == null) {
        _detectHeaderHeight(retries + 1);
      } else {
        setState(() {});
      }
    });
  }

  @override
  String get actionName => 'Opened ${GlobalVars.barcodeScanner.getType()}_page';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    if (!CameraHelper.hasACamera) {
      return Center(
        child: Text(appLocalizations.permission_photo_none_found),
      );
    }

    final double statusBarHeight = MediaQuery.viewPaddingOf(context).top;

    return ScreenVisibilityDetector(
      child: Stack(
        children: <Widget>[
          Semantics(
            label: appLocalizations.camera_window_accessibility_label,
            explicitChildNodes: true,
            child: GlobalVars.barcodeScanner.getScanner(
              onScan: _onNewBarcodeDetected,
              hapticFeedback: () => SmoothHapticFeedback.click(),
              onCameraFlashError: CameraScannerPage.onCameraFlashError,
              trackCustomEvent: AnalyticsHelper.trackCustomEvent,
              hasMoreThanOneCamera: CameraHelper.hasMoreThanOneCamera,
              toggleCameraModeTooltip: appLocalizations.camera_toggle_camera,
              toggleFlashModeTooltip: appLocalizations.camera_toggle_flash,
              contentPadding: _model.compareFeatureEnabled
                  ? EdgeInsets.only(top: _headerHeight ?? 0.0)
                  : null,
            ),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              height: statusBarHeight,
              width: double.infinity,
              color: Colors.black12,
            ),
          ),
          Positioned(
            top: statusBarHeight,
            left: 0.0,
            right: 0.0,
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
}
