import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_ui_library/widgets/smooth_toggle.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/lists/smooth_product_carousel.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';
import 'package:smooth_ui_library/widgets/smooth_view_finder.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({
    @required this.contributionMode,
    @required this.mlKit,
    this.continuousScanModel,
  });

  final bool contributionMode;
  final bool mlKit;
  final ContinuousScanModel continuousScanModel;

  @override
  Widget build(BuildContext context) {
    final GlobalKey _scannerViewKey = GlobalKey(debugLabel: 'Barcode Scanner');
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();

    return FutureBuilder<ContinuousScanModel>(
        future: ContinuousScanModel(
          contributionMode: contributionMode,
          languageCode: ProductQuery.getCurrentLanguageCode(context),
          countryCode: ProductQuery.getCurrentCountryCode(),
        ).load(localDatabase),
        builder: (BuildContext context,
            AsyncSnapshot<ContinuousScanModel> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final ContinuousScanModel continuousScanModel = snapshot.data;
            if (continuousScanModel != null) {
              final Size screenSize = MediaQuery.of(context).size;
              final AppLocalizations appLocalizations =
                  AppLocalizations.of(context);
              final ThemeData themeData = Theme.of(context);
              return ChangeNotifierProvider<ContinuousScanModel>.value(
                value: continuousScanModel,
                child: Consumer<ContinuousScanModel>(
                  builder: (BuildContext context, ContinuousScanModel dummy,
                          Widget child) =>
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
                                PersonalizedRankingPage(
                                    continuousScanModel.productList),
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
                          child: QRView(
                            key: _scannerViewKey,
                            onQRViewCreated: (QRViewController controller) =>
                                continuousScanModel.setupScanner(controller),
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
                                height: screenSize.height * 0.3,
                                padding: const EdgeInsets.only(top: 32.0),
                                child: Column(
                                  children: <Widget>[
                                    ScanPage.getContributeChooseToggle(
                                        continuousScanModel),
                                  ],
                                ),
                              ),
                              Center(
                                child: Container(
                                  child: SmoothViewFinder(
                                    width: screenSize.width * 0.8,
                                    height: screenSize.width * 0.4,
                                    animationDuration: 1500,
                                  ),
                                ),
                              ),
                              if (continuousScanModel.isNotEmpty)
                                Container(
                                  height: screenSize.height * 0.35,
                                  padding: EdgeInsets.only(
                                      bottom: screenSize.height * 0.08),
                                  child: SmoothProductCarousel(
                                    continuousScanModel: continuousScanModel,
                                  ),
                                )
                              else
                                Container(
                                  width: screenSize.width,
                                  height: screenSize.height * 0.35,
                                  padding: EdgeInsets.only(
                                      top: screenSize.height * 0.08),
                                  child: Text(
                                    appLocalizations.scannerProductsEmpty,
                                    style: themeData.textTheme.subtitle1,
                                    textAlign: TextAlign.center,
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
          return const Center(child: CircularProgressIndicator());
        });
  }

  static Widget getContributeChooseToggle(final ContinuousScanModel model) =>
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
        onChanged: (bool value) => model.contributionModeSwitch(value),
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
