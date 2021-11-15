import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/widgets/smooth_product_carousel.dart';
import 'package:smooth_ui_library/smooth_ui_library.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';

class ContinuousScanPage extends StatelessWidget {
  final GlobalKey _scannerViewKey = GlobalKey(debugLabel: 'Barcode Scanner');

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final ContinuousScanModel model = context.watch<ContinuousScanModel>();
    final double carouselHeight = screenSize.height / 2.2; // Roughly 45%
    final double viewFinderBottomOffset = carouselHeight / 2.0;
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0.0),
      body: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.only(top: 48),
              child: SvgPicture.asset(
                'assets/actions/scanner_alt_2.svg',
                width: 60.0,
                height: 60.0,
                color: Colors.white,
              ),
            ),
          ),
          SmoothRevealAnimation(
            delay: 400,
            startOffset: Offset.zero,
            animationCurve: Curves.easeInOutBack,
            child: QRView(
              overlay: QrScannerOverlayShape(
                // We use [SmoothViewFinder] instead of the overlay.
                overlayColor: Colors.transparent,
                // This offset adjusts the scanning area on iOS.
                cutOutBottomOffset: viewFinderBottomOffset,
              ),
              key: _scannerViewKey,
              onQRViewCreated: model.setupScanner,
            ),
          ),
          SmoothRevealAnimation(
            delay: 400,
            startOffset: const Offset(0.0, 0.1),
            animationCurve: Curves.easeInOutBack,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: SmoothViewFinder(
                    boxSize: Size(
                      screenSize.width * 0.6,
                      screenSize.width * 0.33,
                    ),
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
                _buildButtonsRow(context, model),
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
  }

  Widget _buildButtonsRow(BuildContext context, ContinuousScanModel model) {
    final ButtonStyle buttonStyle = ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
      ),
    );
    return AnimatedOpacity(
      opacity: model.hasMoreThanOneProduct ? 0.8 : 0.0,
      duration: const Duration(milliseconds: 50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            ElevatedButton.icon(
              style: buttonStyle,
              icon: const Icon(Icons.cancel_outlined),
              onPressed: model.clearScanSession,
              // TODO(jasmeet): Internationalize
              label: const Text('Clear'),
            ),
            ElevatedButton.icon(
              style: buttonStyle,
              icon: const Icon(Icons.emoji_events_outlined),
              onPressed: () => _openPersonalizedRankingPage(context),
              // TODO(jasmeet): Internationalize
              label: Text('Compare ${model.getBarcodes().length} Products'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPersonalizedRankingPage(BuildContext context) async {
    final ContinuousScanModel model = context.read<ContinuousScanModel>();
    await model.refreshProductList();
    await Navigator.push<Widget>(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => PersonalizedRankingPage(
          model.productList,
        ),
      ),
    );
    await model.refresh();
  }
}
