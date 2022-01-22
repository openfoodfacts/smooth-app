import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/pages/scan/scan_page_helper.dart';
import 'package:smooth_app/widgets/smooth_product_carousel.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';
import 'package:smooth_ui_library/widgets/smooth_view_finder.dart';

/// This builds all the essential widgets which are displayed above the camera
/// preview, like the [SmoothProductCarousel], the [SmoothViewFinder] and the
/// clear and compare buttons row.
class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({
    required this.child,
    required this.model,
  });

  final Widget child;
  final ContinuousScanModel model;

  static const double carouselHeightPct = 0.55;
  static const double scannerWidthPct = 0.6;
  static const double scannerHeightPct = 0.33;
  static const double buttonRowHeightPx = 48;

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
        final double buttonRowHeight =
            areButtonsRendered(model) ? ScannerOverlay.buttonRowHeightPx : 0;
        final double availableScanHeight =
            constraints.maxHeight - carouselHeight - buttonRowHeight;

        // Padding for the qr code scanner. This ensures the scanner has equal spacing between buttons and carousel.
        final EdgeInsets qrScannerPadding = EdgeInsets.only(
            top: (availableScanHeight - scannerSize.height) / 2 +
                buttonRowHeight);

        return Container(
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              SmoothRevealAnimation(
                delay: 400,
                startOffset: Offset.zero,
                animationCurve: Curves.easeInOutBack,
                child: child,
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
                    buildButtonsRow(context, model),
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
