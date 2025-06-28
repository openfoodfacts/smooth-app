import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/scan/camera_scan_page.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_floating_message.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page showing the camera feed and decoding the first barcode, for Prices.
class PriceScanPage extends StatefulWidget {
  const PriceScanPage({
    required this.latestScannedBarcode,
    required this.isMultiProducts,
  });

  final String? latestScannedBarcode;
  final bool isMultiProducts;

  @override
  State<PriceScanPage> createState() => _PriceScanPageState();
}

class _PriceScanPageState extends State<PriceScanPage>
    with TraceableClientMixin {
  // Mutual exclusion needed: we typically receive several times the same
  // barcode and the `pop` would be called several times and cause an error like
  // `Failed assertion: line 5277 pos 12: '!_debugLocked': is not true.`
  bool _mutex = false;

  final List<String> _barcodes = <String>[];
  late String? _latestScannedBarcode;

  @override
  String get actionName =>
      'Opened ${GlobalVars.barcodeScanner.getType()}_page for price';

  @override
  void initState() {
    super.initState();
    _latestScannedBarcode = widget.latestScannedBarcode;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothScaffold(
      appBar: SmoothAppBar(title: Text(appLocalizations.prices_add_an_item)),
      floatingActionButton: !widget.isMultiProducts
          ? null
          : _barcodes.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _pop(context),
              label: Text(appLocalizations.user_list_length(_barcodes.length)),
              icon: const Icon(Icons.add),
            ),
      body: GlobalVars.barcodeScanner.getScanner(
        onScan: (final String barcode) async {
          // for some reason, the scanner sometimes returns immediately the
          // previously scanned barcode.
          if (_latestScannedBarcode == barcode) {
            return false;
          }
          _latestScannedBarcode = barcode;
          if (_barcodes.contains(barcode)) {
            return false;
          }
          if (!widget.isMultiProducts) {
            if (_mutex) {
              return false;
            }
            _mutex = true;
          }
          _barcodes.add(barcode);
          if (!widget.isMultiProducts) {
            _pop(context);
            return true;
          }
          SmoothFloatingMessage(
            message: appLocalizations.scan_announce_new_barcode(barcode),
          ).show(
            context,
            duration: SnackBarDuration.medium,
            alignment: const Alignment(0.0, -0.75),
          );
          unawaited(SmoothHapticFeedback.click());
          setState(() {});
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

  void _pop(final BuildContext context) {
    Navigator.of(context).pop(_barcodes);
  }
}
