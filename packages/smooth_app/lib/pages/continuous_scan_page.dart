import 'package:flutter/material.dart';
import 'package:flutter_qr_bar_scanner/flutter_qr_bar_scanner.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/lists/smooth_product_carousel.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';
import 'package:smooth_ui_library/widgets/smooth_toggle.dart';

import 'package:smooth_ui_library/widgets/smooth_view_finder.dart';

class ContinuousScanPage extends StatefulWidget {
  const ContinuousScanPage({this.initializeWithContributionMode = false});

  final bool initializeWithContributionMode;

  @override
  _ContinuousScanPageState createState() => _ContinuousScanPageState();

  static Widget getContributeChooseToggle(
    final ContinuousScanModel model,
    final Function setState,
  ) =>
      SmoothToggle(
        value: model.contributionMode,
        textLeft: '  CONTRIBUTE',
        textRight: 'CHOOSE      ',
        colorLeft: Colors.black.withAlpha(160),
        colorRight: Colors.black.withAlpha(160),
        iconLeft: SvgPicture.asset('assets/ikonate_bold/add.svg'),
        iconRight: SvgPicture.asset('assets/ikonate_bold/search.svg'),
        textSize: 12.0,
        animationDuration: const Duration(milliseconds: 320),
        width: 150.0,
        height: 50.0,
        onChanged: (bool value) async {
          if (value != model.contributionMode) {
            await model.contributionModeSwitch(value);
            setState(() {});
          }
        },
      );

  static Widget getHero(final Size screenSize) => Hero(
        tag: 'action_button',
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          color: Colors.black,
          child: Center(
            child: SvgPicture.asset(
              'assets/actions/scanner_alt_2.svg',
              width: 60.0,
              height: 60.0,
              color: Colors.white,
            ),
          ),
        ),
      );
}

class _ContinuousScanPageState extends State<ContinuousScanPage> {
  ContinuousScanModel _continuousScanModel;

  @override
  void initState() {
    super.initState();
    _continuousScanModel = ContinuousScanModel(
        contributionMode: widget.initializeWithContributionMode);
  }

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    _continuousScanModel.setLocalDatabase(localDatabase);
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
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
            AppLocalizations.of(context).myPersonalizedRanking,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          onPressed: () => Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => PersonalizedRankingPage(
                input: _continuousScanModel.foundProducts,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          ContinuousScanPage.getHero(screenSize),
          SmoothRevealAnimation(
            delay: 400,
            startOffset: const Offset(0.0, 0.0),
            animationCurve: Curves.easeInOutBack,
            child: QRBarScannerCamera(
              formats: const <BarcodeFormats>[
                BarcodeFormats.EAN_8,
                BarcodeFormats.EAN_13
              ],
              qrCodeCallback: (String code) =>
                  _continuousScanModel.onScan(code, setState),
              notStartedBuilder: (BuildContext context) => Container(),
            ),
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
                            ContinuousScanPage.getContributeChooseToggle(
                              _continuousScanModel,
                              setState,
                            ),
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
                  child: _continuousScanModel.cardTemplates.isNotEmpty
                      ? Container(
                          width: screenSize.width,
                          child: SmoothProductCarousel(
                            productCards: _continuousScanModel.cardTemplates,
                            controller: _continuousScanModel.carouselController,
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
                              AppLocalizations.of(context).scannerProductsEmpty,
                              style: Theme.of(context).textTheme.subtitle1,
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
    );
  }
}
