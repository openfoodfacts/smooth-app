import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/lists/smooth_product_carousel.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/scan/scan_page.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';
import 'package:smooth_ui_library/widgets/smooth_view_finder.dart';

class ContinuousScanPage extends StatelessWidget {
  ContinuousScanPage(this._continuousScanModel);

  final ContinuousScanModel _continuousScanModel;

  final GlobalKey _scannerViewKey = GlobalKey(debugLabel: 'Barcode Scanner');

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final ThemeData themeData = Theme.of(context);
    return ChangeNotifierProvider<ContinuousScanModel>.value(
      value: _continuousScanModel,
      child: Consumer<ContinuousScanModel>(
        builder:
            (BuildContext context, ContinuousScanModel dummy, Widget? child) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            floatingActionButton: SmoothRevealAnimation(
              delay: 400,
              animationCurve: Curves.easeInOutBack,
              child: FloatingActionButton.extended(
                icon: SvgPicture.asset(
                  'assets/actions/smoothie.svg',
                  width: 24.0,
                  height: 24.0,
                  color: Colors.black,
                ),
                label: Text(
                  appLocalizations.myPersonalizedRanking,
                  style: const TextStyle(color: Colors.black),
                ),
                backgroundColor: Colors.white,
                onPressed: () async {
                  await _continuousScanModel.refreshProductList();
                  await Navigator.push<Widget>(
                    context,
                    MaterialPageRoute<Widget>(
                      builder: (BuildContext context) =>
                          PersonalizedRankingPage(
                        _continuousScanModel.productList,
                      ),
                    ),
                  );
                },
              ),
            ),
            body: Stack(
              children: <Widget>[
                ScanPage.getHero(screenSize),
                SmoothRevealAnimation(
                  delay: 400,
                  startOffset: Offset.zero,
                  animationCurve: Curves.easeInOutBack,
                  child: QRView(
                    key: _scannerViewKey,
                    onQRViewCreated: (QRViewController controller) =>
                        _continuousScanModel.setupScanner(controller),
                  ),
                ),
                SmoothRevealAnimation(
                  delay: 400,
                  startOffset: const Offset(0.0, 0.1),
                  animationCurve: Curves.easeInOutBack,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(top: 32.0),
                        child: Column(
                          children: <Widget>[
                            ScanPage.getContributeChooseToggle(
                              _continuousScanModel,
                              context,
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: SmoothViewFinder(
                          width: screenSize.width * 0.8,
                          height: screenSize.width * 0.4,
                          animationDuration: 1500,
                        ),
                      ),
                      if (_continuousScanModel.isNotEmpty)
                        Container(
                          height: screenSize.height * 0.35,
                          padding:
                              EdgeInsets.only(bottom: screenSize.height * 0.08),
                          child: SmoothProductCarousel(
                            continuousScanModel: _continuousScanModel,
                          ),
                        )
                      else
                        Container(
                          width: screenSize.width,
                          height: screenSize.height * 0.35,
                          padding:
                              EdgeInsets.only(top: screenSize.height * 0.08),
                          child: Text(
                            appLocalizations.scannerProductsEmpty,
                            style: themeData.textTheme.subtitle1!
                                .copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
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
}
