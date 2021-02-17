import 'package:flutter/material.dart';
//import 'package:flutter_qr_bar_scanner/flutter_qr_bar_scanner.dart';
//import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/lists/smooth_product_carousel.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/scan_page.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';
import 'package:smooth_ui_library/widgets/smooth_view_finder.dart';

class ContinuousScanPage extends StatelessWidget {
  const ContinuousScanPage(this._continuousScanModel);

  final ContinuousScanModel _continuousScanModel;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    return ChangeNotifierProvider<ContinuousScanModel>.value(
      value: _continuousScanModel,
      child: Consumer<ContinuousScanModel>(
        builder:
            (BuildContext context, ContinuousScanModel dummy, Widget child) =>
                Scaffold(
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
              onPressed: () => Navigator.push<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) =>
                      PersonalizedRankingPage(_continuousScanModel.productList),
                ),
              ),
            ),
          ),
          body: Stack(
            children: <Widget>[
              ScanPage.getHero(screenSize),
              SmoothRevealAnimation(
                delay: 400,
                startOffset: const Offset(0.0, 0.0),
                animationCurve: Curves.easeInOutBack,
                child: Container(),
//                child: QRBarScannerCamera(
//                  formats: const <BarcodeFormats>[
//                    BarcodeFormats.EAN_8,
//                    BarcodeFormats.EAN_13
//                  ],
//                  qrCodeCallback: (String code) =>
//                      _continuousScanModel.onScan(code),
//                  notStartedBuilder: (BuildContext context) => Container(),
//                ),
              ),
              SmoothRevealAnimation(
                delay: 400,
                startOffset: const Offset(0.0, 0.1),
                animationCurve: Curves.easeInOutBack,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 36.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                ScanPage.getContributeChooseToggle(
                                    _continuousScanModel),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 14.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SmoothViewFinder(
                                  width: screenSize.width * 0.8,
                                  height: screenSize.width * 0.45,
                                  animationDuration: 1500,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 80.0),
                      child: _continuousScanModel.isNotEmpty
                          ? Container(
                              width: screenSize.width,
                              child: SmoothProductCarousel(
                                continuousScanModel: _continuousScanModel,
                                height: _continuousScanModel.contributionMode
                                    ? 160.0
                                    : 120.0,
                              ),
                            )
                          : Container(
                              width: screenSize.width,
                              height: screenSize.height * 0.5,
                              child: Center(
                                child: Text(
                                  appLocalizations.scannerProductsEmpty,
                                  style: themeData.textTheme.subtitle1,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
