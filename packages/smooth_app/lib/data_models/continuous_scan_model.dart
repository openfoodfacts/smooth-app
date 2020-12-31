import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_edit.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_not_found.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_loading.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_thanks.dart';
import 'package:smooth_app/database/full_products_database.dart';

enum ScannedProductState { FOUND, NOT_FOUND, LOADING }

class ContinuousScanModel extends ChangeNotifier {
  ContinuousScanModel({@required this.contributionMode}) {
    carouselController = CarouselController();

    scannedBarcodes = <String, ScannedProductState>{};
    cardTemplates = <String, Widget>{};
  }

  final GlobalKey scannerViewKey = GlobalKey(debugLabel: 'Barcode Scanner');
  QRViewController scannerController;
  CarouselController carouselController;

  Map<String, ScannedProductState> scannedBarcodes;
  Map<String, Widget> cardTemplates;

  List<Product> foundProducts = <Product>[];

  String barcodeTrustCheck;

  bool contributionMode = false;

  bool firstScan = true;

  void setupScanner(QRViewController controller) {
    scannerController = controller;
    scannerController.scannedDataStream.listen((String barcode) {
      onScan(barcode);
    });
  }

  void onScan(String code) {
    print('Barcode detected : $code');
    if (barcodeTrustCheck != code) {
      barcodeTrustCheck = code;
      return;
    }
    if (addBarcode(code)) {
      _generateScannedProductsCardTemplates();
      if (!firstScan) {
        carouselController.animateToPage(
          cardTemplates.length - 1,
        );
      } else {
        firstScan = false;
      }
    }
  }

  void onScanAlt(String code, List<Offset> offsets) {
    print('Barcode detected : $code');
    if (addBarcode(code)) {
      _generateScannedProductsCardTemplates();
      if (cardTemplates.isNotEmpty) {
        carouselController.animateToPage(
          cardTemplates.length - 1,
        );
      }
    }
  }

  Future<bool> _generateScannedProductsCardTemplates(
      {bool switchMode = false}) async {
    final FullProductsDatabase productsDatabase = FullProductsDatabase();

    for (final String scannedBarcode in scannedBarcodes.keys) {
      switch (scannedBarcodes[scannedBarcode]) {
        case ScannedProductState.FOUND:
          if (switchMode) {
            final Product product = await productsDatabase.getProduct(
                scannedBarcode); // Acceptable thanks to offline first
            setCardTemplate(
                scannedBarcode,
                contributionMode
                    ? SmoothProductCardEdit(
                        heroTag: product.barcode, product: product)
                    : SmoothProductCardFound(
                        heroTag: product.barcode, product: product));
          }
          break;
        case ScannedProductState.NOT_FOUND:
          break;
        case ScannedProductState.LOADING:
          final bool result =
              await productsDatabase.checkAndFetchProduct(scannedBarcode);
          if (result) {
            scannedBarcodes[scannedBarcode] = ScannedProductState.FOUND;
            final Product product =
                await productsDatabase.getProduct(scannedBarcode);
            setCardTemplate(
                scannedBarcode,
                contributionMode
                    ? SmoothProductCardEdit(
                        heroTag: product.barcode, product: product)
                    : SmoothProductCardFound(
                        heroTag: product.barcode, product: product));
            foundProducts.add(product);
          } else {
            scannedBarcodes[scannedBarcode] = ScannedProductState.NOT_FOUND;
            setCardTemplate(
              scannedBarcode,
              SmoothProductCardNotFound(
                barcode: scannedBarcode,
                callback: () {
                  setCardTemplate(scannedBarcode, SmoothProductCardThanks());
                },
              ),
            );
          }
          break;
      }
    }
    return true;
  }

  bool addBarcode(String newBarcode) {
    if (scannedBarcodes[newBarcode] == null) {
      scannedBarcodes[newBarcode] = ScannedProductState.LOADING;
      cardTemplates[newBarcode] = SmoothProductCardLoading(barcode: newBarcode);
      notifyListeners();
      return true;
    }
    return false;
  }

  void setProductState(String barcode, ScannedProductState state) {
    scannedBarcodes[barcode] = state;
    notifyListeners();
  }

  void setCardTemplate(String barcode, Widget cardTemplate) {
    cardTemplates[barcode] = cardTemplate;
    notifyListeners();
  }

  void contributionModeSwitch(bool value) {
    contributionMode = value;
    _generateScannedProductsCardTemplates(switchMode: true);
    notifyListeners();
  }
}
