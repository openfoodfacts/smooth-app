import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/generic_lib/animations/smooth_reveal_animation.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_view_finder.dart';
import 'package:smooth_app/pages/scan/scan_header.dart';
import 'package:smooth_app/widgets/smooth_product_carousel.dart';

/// This builds all the essential widgets which are displayed above the camera
/// preview, like the [SmoothProductCarousel], the [SmoothViewFinder] and the
/// clear and compare buttons row.
class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({
    required this.child,
  });

  final Widget child;

  static const double carouselHeightPct = 0.55;
  static const double scannerWidthPct = 0.6;
  static const double scannerHeightPct = 0.33;
  static const double buttonRowHeightPx = 48;

  @override
  Widget build(BuildContext context) {
    final ContinuousScanModel model = context.watch<ContinuousScanModel>();
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
        final double buttonRowHeight = model.getBarcodes().isNotEmpty
            ? ScannerOverlay.buttonRowHeightPx
            : 0;
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
              //Scanner
              SmoothRevealAnimation(
                delay: 400,
                startOffset: Offset.zero,
                animationCurve: Curves.easeInOutBack,
                child: child,
              ),
              // Scanning area overlay
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
              // Product carousel
              SmoothRevealAnimation(
                delay: 400,
                startOffset: const Offset(0.0, -0.1),
                animationCurve: Curves.easeInOutBack,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SafeArea(top: true, child: ScanHeader()),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: SmoothProductCarousel(
                        showSearchCard: true,
                        height: carouselHeight,
                      ),
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
