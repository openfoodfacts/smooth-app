import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/pages/scan/camera_scan_page.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page showing the camera feed and decoding the first barcode, for Prices.
class PriceScanPage extends StatefulWidget {
  const PriceScanPage();

  @override
  State<PriceScanPage> createState() => _PriceScanPageState();
}

class _PriceScanPageState extends State<PriceScanPage>
    with TraceableClientMixin {
  // Mutual exclusion needed: we typically receive several times the same
  // barcode and the `pop` would be called several times and cause an error like
  // `Failed assertion: line 5277 pos 12: '!_debugLocked': is not true.`
  bool _mutex = false;

  @override
  String get actionName =>
      'Opened ${GlobalVars.barcodeScanner.getType()}_page for price';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothScaffold(
      body: GlobalVars.barcodeScanner.getScanner(
        onScan: (final String barcode) async {
          if (_mutex) {
            return false;
          }
          _mutex = true;
          Navigator.of(context).pop(barcode);
          return true;
        },
        hapticFeedback: () => SmoothHapticFeedback.click(),
        onCameraFlashError: CameraScannerPage.onCameraFlashError,
        trackCustomEvent: AnalyticsHelper.trackCustomEvent,
        hasMoreThanOneCamera: CameraHelper.hasMoreThanOneCamera,
        toggleCameraModeTooltip: appLocalizations.camera_toggle_camera,
        toggleFlashModeTooltip: appLocalizations.camera_toggle_flash,
        contentPadding: null,
      ),
    );
  }
}
