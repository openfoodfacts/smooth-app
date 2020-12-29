import 'package:flutter/material.dart';
import 'package:flutter_qr_bar_scanner/flutter_qr_bar_scanner.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/lists/smooth_product_carousel.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';
import 'package:smooth_ui_library/widgets/smooth_toggle.dart';

import 'package:smooth_ui_library/widgets/smooth_view_finder.dart';

class ContinuousScanPage extends StatelessWidget {
  ContinuousScanPage({this.initializeWithContributionMode = false});

  final bool initializeWithContributionMode;

  final List<String> barcodesError = <String>[];
  final List<Product> foundProducts = <Product>[];

  @override
  Widget build(BuildContext context) {
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
          onPressed: () {
            Navigator.push<dynamic>(
              context,
              MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) => PersonalizedRankingPage(
                        input: foundProducts,
                      )),
            );
          },
        ),
      ),
      body: ChangeNotifierProvider<ContinuousScanModel>(
          create: (BuildContext context) => ContinuousScanModel(
              contributionMode: initializeWithContributionMode),
          child: Stack(
            children: <Widget>[
              Hero(
                tag: 'action_button',
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
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
              ),
              Consumer<ContinuousScanModel>(
                builder: (BuildContext context,
                    ContinuousScanModel continuousScanModel, Widget child) {
                  return SmoothRevealAnimation(
                    delay: 400,
                    startOffset: const Offset(0.0, 0.0),
                    animationCurve: Curves.easeInOutBack,
                    child: QRBarScannerCamera(
                      formats: const <BarcodeFormats>[
                        BarcodeFormats.EAN_8,
                        BarcodeFormats.EAN_13
                      ],
                      qrCodeCallback: (String code) {
                        continuousScanModel.onScan(code);
                      },
                      notStartedBuilder: (BuildContext context) {
                        return Container();
                      },
                    ),
                  );
                },
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
                                Consumer<ContinuousScanModel>(builder:
                                    (BuildContext context,
                                        ContinuousScanModel continuousScanModel,
                                        Widget child) {
                                  foundProducts.clear();
                                  foundProducts.addAll(
                                      continuousScanModel.foundProducts);
                                  return SmoothToggle(
                                    value: continuousScanModel.contributionMode,
                                    textLeft: '  CONTRIBUTE',
                                    textRight: 'CHOOSE      ',
                                    colorLeft: Colors.black.withAlpha(160),
                                    colorRight: Colors.black.withAlpha(160),
                                    iconLeft: SvgPicture.asset(
                                        'assets/ikonate_bold/add.svg'),
                                    iconRight: SvgPicture.asset(
                                        'assets/ikonate_bold/search.svg'),
                                    textSize: 12.0,
                                    animationDuration:
                                        const Duration(milliseconds: 320),
                                    width: 150.0,
                                    height: 50.0,
                                    onChanged: (bool value) {
                                      continuousScanModel
                                          .contributionModeSwitch(value);
                                    },
                                  );
                                }),
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  height:
                                      MediaQuery.of(context).size.width * 0.45,
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
                      child: Consumer<ContinuousScanModel>(
                        builder: (BuildContext context,
                            ContinuousScanModel continuousScanModel,
                            Widget child) {
                          foundProducts.clear();
                          foundProducts
                              .addAll(continuousScanModel.foundProducts);
                          if (continuousScanModel.cardTemplates.isNotEmpty) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              child: SmoothProductCarousel(
                                productCards: continuousScanModel.cardTemplates,
                                controller:
                                    continuousScanModel.carouselController,
                                height: continuousScanModel.contributionMode
                                    ? 160.0
                                    : 120.0,
                              ),
                            );
                          }
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context).scannerProductsEmpty,
                                style: Theme.of(context).textTheme.subtitle1,
                                textAlign: TextAlign.start,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
