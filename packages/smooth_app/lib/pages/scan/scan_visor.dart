import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_view_finder.dart';
import 'package:smooth_app/pages/scan/scanner_overlay.dart';

class ScannerVisorWidget extends StatelessWidget {
  const ScannerVisorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    final Size scannerSize = Size(
      screenSize.width * ScannerOverlay.scannerWidthPct,
      getVisorHeight(screenSize),
    );

    return SmoothViewFinder(
      boxSize: scannerSize,
      lineLength: screenSize.width * 0.8,
    );
  }

  static double getVisorHeight(Size size) {
    return size.width * ScannerOverlay.scannerHeightPct;
  }
}
