import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/widgets/ranking_floating_action_button.dart';
import 'package:smooth_app/widgets/smooth_product_carousel.dart';
import 'package:smooth_ui_library/smooth_ui_library.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ContinuousScanPage extends StatefulWidget {
  const ContinuousScanPage();

  @override
  State<ContinuousScanPage> createState() => _ContinuousScanPageState();
}

class _ContinuousScanPageState extends State<ContinuousScanPage> {
  final GlobalKey _scannerViewKey = GlobalKey(debugLabel: 'Barcode Scanner');
  ContinuousScanModel? _model;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('VisibilityDetector'),
      onVisibilityChanged: (VisibilityInfo visibilityInfo) {
        if (visibilityInfo.visibleFraction == 0.0) {
          _model?.stopQRView();
        } else {
          _model?.resumeQRView();
        }
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          _model = context.watch<ContinuousScanModel>();
          final Size screenSize = MediaQuery.of(context).size;
          final Size scannerSize = Size(
            screenSize.width * 0.6,
            screenSize.width * 0.33,
          );
          final double carouselHeight = constraints.maxHeight /
              1.81; // roughly 55% of the available height
          final double buttonRowHeight = areButtonsRendered(_model!) ? 48 : 0;
          final double availableScanHeight =
              constraints.maxHeight - carouselHeight - buttonRowHeight;
          // Padding for the qr code scanner. This ensures the scanner has equal spacing between buttons and carousel.
          final EdgeInsets qrScannerPadding = EdgeInsets.only(
              top: (availableScanHeight - scannerSize.height) / 2 +
                  buttonRowHeight);
          final double viewFinderBottomOffset = carouselHeight / 2.0;
          return Scaffold(
            appBar: AppBar(toolbarHeight: 0.0),
            body: Stack(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  color: Colors.black,
                  child: Padding(
                    padding: qrScannerPadding,
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
                    onQRViewCreated: _model!.setupScanner,
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
                      _buildButtonsRow(context, _model!),
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
      ),
    );
  }

  Widget _buildButtonsRow(BuildContext context, ContinuousScanModel model) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final ButtonStyle buttonStyle = ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
      ),
    );
    return AnimatedOpacity(
      opacity: areButtonsRendered(model) ? 0.8 : 0.0,
      duration: const Duration(milliseconds: 50),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: VERY_SMALL_SPACE, horizontal: MEDIUM_SPACE),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            ElevatedButton.icon(
              style: buttonStyle,
              icon: const Icon(Icons.cancel_outlined),
              onPressed: model.clearScanSession,
              label: Text(appLocalizations.clear),
            ),
            ElevatedButton.icon(
              style: buttonStyle,
              icon: const Icon(RankingFloatingActionButton.rankingIconData),
              onPressed: () => _openPersonalizedRankingPage(context),
              label: Text(
                appLocalizations.plural_compare_x_products(
                  model.getBarcodes().length,
                ),
              ),
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

  bool areButtonsRendered(ContinuousScanModel model) =>
      model.hasMoreThanOneProduct;
}
