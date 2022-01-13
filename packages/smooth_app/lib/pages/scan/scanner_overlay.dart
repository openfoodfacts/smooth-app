import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/pages/scan/scan_page_helper.dart';
import 'package:smooth_app/widgets/smooth_product_carousel.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';
import 'package:smooth_ui_library/widgets/smooth_view_finder.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ScannerOverlay extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        final Size screenSize = MediaQuery.of(context).size;
        final Size scannerSize = Size(
          screenSize.width * 0.6,
          screenSize.width * 0.33,
        );
        final double carouselHeight =
            constraints.maxHeight / 1.81; // roughly 55% of the available height
        final double buttonRowHeight = areButtonsRendered(model) ? 48 : 0;
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
              stopCamera.call();
            } else {
              restartCamera.call();
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
                child: scannerWidget,
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
