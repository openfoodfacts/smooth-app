import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/scan/search_panel.dart';
import 'package:smooth_app/widgets/smooth_product_carousel.dart';
import 'package:smooth_ui_library/smooth_ui_library.dart';

class ContinuousScanPage extends StatelessWidget {
  final GlobalKey _scannerViewKey = GlobalKey(debugLabel: 'Barcode Scanner');

  @override
  Widget build(BuildContext context) {
    final ContinuousScanModel model = context.watch<ContinuousScanModel>();
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final Size screenSize = MediaQuery.of(context).size;
    const double viewFinderBottomOffset = 0.0;
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0.0),
      body: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            color: Colors.black,
            child: SvgPicture.asset(
              'assets/actions/scanner_alt_2.svg',
              width: 60.0,
              height: 60.0,
              color: Colors.white,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  // Double the offset to account for the vertical centering.
                  padding:
                      // ignore: use_named_constants
                      const EdgeInsets.only(bottom: 2 * viewFinderBottomOffset),
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
              children: <Widget>[
                if (model.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton.icon(
                        icon: const Icon(Icons.cancel_outlined),
                        onPressed: model.clearScanSession,
                        label: const Text('Clear'),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.emoji_events_outlined),
                        onPressed: () => _openPersonalizedRankingPage(context),
                        label: Text(localizations.myPersonalizedRanking),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  const SmoothProductCarousel(),
                ],
              ],
            ),
          ),
          SearchPanel(),
        ],
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
