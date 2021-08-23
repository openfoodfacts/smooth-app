import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/widgets/smooth_product_carousel.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/scan/scan_page.dart';
import 'package:smooth_app/pages/user_preferences_page.dart';
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
    final Color backgroundColor = themeData.colorScheme.surface;
    final Color foregroundColor = themeData.colorScheme.onSurface;
    return ChangeNotifierProvider<ContinuousScanModel>.value(
      value: _continuousScanModel,
      child: Consumer<ContinuousScanModel>(
        builder:
            (BuildContext context, ContinuousScanModel dummy, Widget? child) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: const Text('Scan'),
              actions: <Widget>[
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/actions/food-cog.svg',
                    color: Colors.white,
                  ),
                  onPressed: () async => Navigator.push<Widget>(
                    context,
                    MaterialPageRoute<Widget>(
                      builder: (BuildContext context) =>
                          const UserPreferencesPage(),
                    ),
                  ),
                ),
              ],
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
                  child: Stack(children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: SmoothViewFinder(
                            width: screenSize.width * 0.8,
                            height: screenSize.width * 0.4,
                            animationDuration: 1500,
                          ),
                        )
                      ],
                    ),
                    if (_continuousScanModel.isNotEmpty)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              ElevatedButton.icon(
                                icon: const Icon(CupertinoIcons.clear_circled),
                                onPressed: () async =>
                                    _continuousScanModel.clearScanSession(),
                                label: const Text('Clear'),
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.emoji_events_outlined),
                                onPressed: () async {
                                  await _continuousScanModel
                                      .refreshProductList();
                                  await Navigator.push<Widget>(
                                    context,
                                    MaterialPageRoute<Widget>(
                                      builder: (BuildContext context) =>
                                          PersonalizedRankingPage(
                                        _continuousScanModel.productList,
                                      ),
                                    ),
                                  );
                                  await _continuousScanModel.refresh();
                                },
                                label: Text(
                                    appLocalizations.myPersonalizedRanking),
                              ),
                            ],
                          ),
                        ],
                      ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        if (_continuousScanModel.isNotEmpty)
                          Container(
                            height: screenSize.height * 0.35,
                            padding: EdgeInsets.only(
                                bottom: screenSize.height * 0.08),
                            child: SmoothProductCarousel(
                              continuousScanModel: _continuousScanModel,
                            ),
                          )
                        else
                          Container(
                            color: backgroundColor,
                            child: ListTile(
                              title: Text(
                                '${appLocalizations.scannerProductsEmpty}'
                                '. Scan product barcodes to see which ones'
                                ' better match your food preferences',
                                style: TextStyle(color: foregroundColor),
                              ),
                              trailing: SvgPicture.asset(
                                'assets/actions/food-cog.svg',
                                color: foregroundColor,
                              ),
                              onTap: () async => Navigator.push<Widget>(
                                context,
                                MaterialPageRoute<Widget>(
                                  builder: (BuildContext context) =>
                                      const UserPreferencesPage(),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
