import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_bar_scanner/flutter_qr_bar_scanner.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_not_found.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/database/full_products_database.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/lists/smooth_product_carousel.dart';
import 'package:smooth_app/pages/smooth_it_page.dart';

import 'package:smooth_ui_library/widgets/smooth_view_finder.dart';

class ContinuousScanPage extends StatelessWidget {
  final CarouselController carouselController = CarouselController();

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
        label: Text(
          'Smooth-it !',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => SmoothItPage(input: foundProducts,)),
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
                      _onScan(code, continuousScanModel, context);
                    },
                  );
                },
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 100.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SmoothViewFinder(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.width * 0.45,
                          animationDuration: 1500,
                        )
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
                            child: SmoothProductCarousel(
                              productCards: continuousScanModel.cardTemplates,
                              controller: carouselController,
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

  void _onScan(String code, ContinuousScanModel continuousScanModel,
      BuildContext context) {
    if (continuousScanModel.addBarcode(code)) {
      _generateScannedProductsCardTemplates(continuousScanModel, context);
      if (continuousScanModel.cardTemplates.isNotEmpty) {
        carouselController.animateToPage(
          continuousScanModel.cardTemplates.length - 1,
        );
      }
    }
  }

  Future<bool> _generateScannedProductsCardTemplates(
      ContinuousScanModel continuousScanModel, BuildContext context) async {
    final FullProductsDatabase productsDatabase = FullProductsDatabase();

    for (final String scannedBarcode
        in continuousScanModel.scannedBarcodes.keys) {
      switch (continuousScanModel.scannedBarcodes[scannedBarcode]) {
        case ScannedProductState.FOUND:
          break;
        case ScannedProductState.NOT_FOUND:
          break;
        case ScannedProductState.LOADING:
          final bool result =
              await productsDatabase.checkAndFetchProduct(scannedBarcode);
          if (result) {
            continuousScanModel.scannedBarcodes[scannedBarcode] =
                ScannedProductState.FOUND;
            final Product product =
                await productsDatabase.getProduct(scannedBarcode);
            continuousScanModel.setCardTemplate(
                scannedBarcode,
                SmoothProductCardFound(
                  heroTag: product.barcode,
                  product: product,
                  context: context,
                ));
            foundProducts.add(product);
          } else {
            continuousScanModel.scannedBarcodes[scannedBarcode] =
                ScannedProductState.NOT_FOUND;
            continuousScanModel.setCardTemplate(
              scannedBarcode,
              SmoothProductCardNotFound(
                barcode: scannedBarcode,
              ),
            );
            barcodesError.add(scannedBarcode);
          }
          break;
      }
    }
    return true;
  }
}
