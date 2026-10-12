import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/pages/scan/camera_scan_page.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/widgets/smooth_view_padding.dart';

Future<String?> showSingleBarcodeScanner(BuildContext context) async {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: false,
    backgroundColor: Colors.black,
    builder: (BuildContext context) {
      return SizedBox(
        width: double.infinity,
        height: MediaQuery.heightOf(context) * 0.4,
        child: const _BarcodeScannerView(),
      );
    },
  );
}

class _BarcodeScannerView extends StatefulWidget {
  const _BarcodeScannerView();

  @override
  State<_BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<_BarcodeScannerView>
    with TraceableClientMixin {
  @override
  String get actionName =>
      'Opened ${GlobalVars.barcodeScanner.getType()}_page for price';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: GlobalVars.barcodeScanner.getScanner(
            onScan: (final String barcode) async {
              Navigator.of(context).pop(barcode);
              return true;
            },
            hapticFeedback: () => SmoothHapticFeedback.click(),
            onCameraFlashError: CameraScannerPage.onCameraFlashError,
            trackCustomEvent: AnalyticsHelper.trackCustomEvent,
            hasMoreThanOneCamera: CameraHelper.hasMoreThanOneCamera,
            barcodeScannerIcon: const icons.Search.off(),
            torchOnIcon: const icons.Torch.on(),
            torchOffIcon: const icons.Torch.off(),
            contentPadding: EdgeInsetsDirectional.only(
              top: 50.0,
              start: LARGE_SPACE,
              end: LARGE_SPACE,
              bottom: SmoothViewPadding.of(context).bottom,
            ),
          ),
        ),
        const Align(
          alignment: AlignmentDirectional.topCenter,
          child: _DragHandle(),
        ),
      ],
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    final Size handleSize =
        Theme.of(context).bottomSheetTheme.dragHandleSize ??
        const Size(32.0, 4.0);

    return SizedBox(
      width: math.max(handleSize.width, kMinInteractiveDimension),
      height: math.max(handleSize.height, kMinInteractiveDimension),
      child: Center(
        child: Container(
          height: handleSize.height,
          width: handleSize.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(handleSize.height / 2),
            color: Colors.blueGrey,
          ),
        ),
      ),
    );
  }
}
