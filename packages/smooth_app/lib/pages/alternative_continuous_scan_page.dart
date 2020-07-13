import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/lists/smooth_product_carousel.dart';
import 'package:smooth_app/pages/smooth_it_page.dart';

import 'package:smooth_ui_library/widgets/smooth_view_finder.dart';

class AlternativeContinuousScanPage extends StatelessWidget {
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
                  return QRView(
                    key: continuousScanModel.scannerViewKey,
                    onQRViewCreated: continuousScanModel.setupScanner,
                  );
                },
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Consumer<ContinuousScanModel>(
                    builder: (BuildContext context,
                        ContinuousScanModel continuousScanModel, Widget child) {
                      foundProducts.clear();
                      foundProducts.addAll(continuousScanModel.foundProducts);
                      if (continuousScanModel.cardTemplates.isNotEmpty) {
                        return Center(
                          child: Container(
                            height: 100.0,
                          ),
                        );
                      }
                      return Container();
                    },
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: SmoothViewFinder(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.width * 0.45,
                        animationDuration: 1500,
                      ),
                    ),
                  ),
                  Consumer<ContinuousScanModel>(
                    builder: (BuildContext context,
                        ContinuousScanModel continuousScanModel, Widget child) {
                      foundProducts.clear();
                      foundProducts.addAll(continuousScanModel.foundProducts);
                      if (continuousScanModel.cardTemplates.isNotEmpty) {
                        return Container(
                          child: SmoothProductCarousel(
                            productCards: continuousScanModel.cardTemplates,
                            controller: continuousScanModel.carouselController,
                          ),
                        );
                      }
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.25,
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
                ],
              ),
            ],
          )),
    );
  }
}
