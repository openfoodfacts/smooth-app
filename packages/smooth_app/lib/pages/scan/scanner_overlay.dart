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
///
/// The camera preview should be passed to [backgroundChild].
class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({
    required this.topChild,
    this.backgroundChild,
  });

  final Widget? backgroundChild;
  final Widget topChild;

  static const double carouselHeightPct = 0.55;
  static const double carouselBottomPadding = 10.0;
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

        final double carouselHeight =
            constraints.maxHeight * ScannerOverlay.carouselHeightPct;
        final double buttonRowHeight = model.getBarcodes().isNotEmpty
            ? ScannerOverlay.buttonRowHeightPx
            : 0;
        final double availableScanHeight =
            constraints.maxHeight - carouselHeight - buttonRowHeight;

        final Size scannerContainerSize = Size(
          screenSize.width,
          availableScanHeight - carouselBottomPadding,
        );

        return Container(
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              //Scanner
              if (backgroundChild != null)
                // Force the child to take the full space, otherwise the
                // [VisibilityDetector] may return incorrect results
                SmoothRevealAnimation(
                  delay: 400,
                  startOffset: Offset.zero,
                  animationCurve: Curves.easeInOutBack,
                  child: SizedBox.expand(
                    child: backgroundChild,
                  ),
                ),
              // Scanning area overlay
              SmoothRevealAnimation(
                delay: 400,
                startOffset: const Offset(0.0, 0.1),
                animationCurve: Curves.easeInOutBack,
                child: ConstrainedBox(
                  constraints: BoxConstraints.tight(
                    scannerContainerSize,
                  ),
                  child: Center(child: topChild),
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
                      padding:
                          const EdgeInsets.only(bottom: carouselBottomPadding),
                      child: SmoothProductCarousel(
                        containSearchCard: true,
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

class ScannerVisorWidget extends StatelessWidget {
  const ScannerVisorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    final Size scannerSize = Size(
      screenSize.width * ScannerOverlay.scannerWidthPct,
      screenSize.width * ScannerOverlay.scannerHeightPct,
    );

    return SmoothViewFinder(
      boxSize: scannerSize,
      lineLength: screenSize.width * 0.8,
    );
  }
}
