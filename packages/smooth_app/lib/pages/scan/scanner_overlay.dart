import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/pages/scan/scan_page_helper.dart';
import 'package:smooth_app/widgets/smooth_product_carousel.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';
import 'package:smooth_ui_library/widgets/smooth_view_finder.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// This builds all the essential widgets which are displayed above the camera
/// preview, like the [SmoothProductCarousel], the [SmoothViewFinder] and the
/// clear and compare buttons row. It takes the camera preview widget to display
/// and functions to stop and restart the camera, to only activate the camera
/// when the screen is currently visible.
class ScannerOverlay extends StatefulWidget {
  const ScannerOverlay({
    required this.scannerWidget,
    required this.model,
    required this.restartCamera,
    required this.stopCamera,
  });

  final Widget scannerWidget;
  final ContinuousScanModel model;
  final Function() restartCamera;
  final Function() stopCamera;

  static const double carouselHeightPct = 0.55;
  static const double scannerWidthPct = 0.6;
  static const double scannerHeightPct = 0.33;
  static const double buttonRowHeightPx = 48;

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  // Lifecycle changes are not handled by either of the used plugin. This means
  // we are responsible to control camera resources when the lifecycle state is
  // updated. Failure to do so might lead to unexpected behavior
  // didChangeAppLifecycleState is called when the system puts the app in the
  // background or returns the app to the foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      widget.stopCamera.call();
    } else if (state == AppLifecycleState.resumed) {
      widget.restartCamera.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        final Size screenSize = MediaQuery.of(context).size;
        final Size scannerSize = Size(
          screenSize.width * ScannerOverlay.scannerWidthPct,
          screenSize.width * ScannerOverlay.scannerHeightPct,
        );
        final double carouselHeight =
            constraints.maxHeight * ScannerOverlay.carouselHeightPct;
        final double buttonRowHeight = areButtonsRendered(widget.model)
            ? ScannerOverlay.buttonRowHeightPx
            : 0;
        final double availableScanHeight =
            constraints.maxHeight - carouselHeight - buttonRowHeight;

        // Padding for the qr code scanner. This ensures the scanner has equal spacing between buttons and carousel.
        final EdgeInsets qrScannerPadding = EdgeInsets.only(
            top: (availableScanHeight - scannerSize.height) / 2 +
                buttonRowHeight);

        return VisibilityDetector(
          key: const ValueKey<String>('VisibilityDetector'),
          onVisibilityChanged: (VisibilityInfo info) {
            if (info.visibleFraction == 0.0) {
              widget.stopCamera.call();
            } else {
              widget.restartCamera.call();
            }
          },
          child: Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                color: Colors.black,
                child: Padding(
                  padding: qrScannerPadding,
                  child: SvgPicture.asset(
                    'assets/actions/scanner_alt_2.svg',
                    width: scannerSize.width * 0.8,
                    height: scannerSize.height * 0.8,
                    color: Colors.white,
                  ),
                ),
              ),
              SmoothRevealAnimation(
                delay: 400,
                startOffset: Offset.zero,
                animationCurve: Curves.easeInOutBack,
                child: widget.scannerWidget,
              ),
              SmoothRevealAnimation(
                delay: 400,
                startOffset: const Offset(0.0, 0.1),
                animationCurve: Curves.easeInOutBack,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: qrScannerPadding,
                      child: SmoothViewFinder(
                        boxSize: scannerSize,
                        lineLength: screenSize.width * 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              SmoothRevealAnimation(
                delay: 400,
                startOffset: const Offset(0.0, -0.1),
                animationCurve: Curves.easeInOutBack,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    buildButtonsRow(context, widget.model),
                    const Spacer(),
                    SmoothProductCarousel(
                      showSearchCard: true,
                      height: carouselHeight,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
