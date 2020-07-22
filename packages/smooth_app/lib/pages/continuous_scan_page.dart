import 'package:flutter/material.dart';
import 'package:flutter_qr_bar_scanner/flutter_qr_bar_scanner.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/lists/smooth_product_carousel.dart';
import 'package:smooth_app/pages/smooth_it_page.dart';
import 'package:smooth_ui_library/widgets/smooth_toggle.dart';

import 'package:smooth_ui_library/widgets/smooth_view_finder.dart';

class ContinuousScanPage extends StatelessWidget {
  final List<String> barcodesError = <String>[];

  final List<Product> foundProducts = <Product>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: SvgPicture.asset(
          'assets/actions/smoothie.svg',
          width: 24.0,
          height: 24.0,
          color: Colors.black,
        ),
        label: const Text(
          'Smooth-it !',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => SmoothItPage(
                      input: foundProducts,
                    )),
          );
        },
      ),
      body: ChangeNotifierProvider<ContinuousScanModel>(
          create: (BuildContext context) => ContinuousScanModel(),
          child: Stack(
            children: <Widget>[
              Consumer<ContinuousScanModel>(
                builder: (BuildContext context,
                    ContinuousScanModel continuousScanModel, Widget child) {
                  return QRBarScannerCamera(
                    formats: const <BarcodeFormats>[
                      BarcodeFormats.EAN_8,
                      BarcodeFormats.EAN_13
                    ],
                    qrCodeCallback: (String code) {
                      continuousScanModel.onScan(code);
                    },
                  );
                },
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 32.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Consumer<ContinuousScanModel>(builder:
                                  (BuildContext context,
                                      ContinuousScanModel continuousScanModel,
                                      Widget child) {
                                return SmoothToggle(
                                  value: continuousScanModel.contributionMode,
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
                                width: MediaQuery.of(context).size.width * 0.8,
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
                        if (continuousScanModel.cardTemplates.isNotEmpty) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            child: SmoothProductCarousel(
                              productCards: continuousScanModel.cardTemplates,
                              controller:
                                  continuousScanModel.carouselController,
                            ),
                          );
                        }
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                            child: Text(
                              'Products you scan will appear here',
                              style: Theme.of(context).textTheme.subtitle1,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            ],
          )),
    );
  }
}
