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
import 'package:smooth_app/database/barcode_product_query.dart';
import 'package:smooth_app/database/local_database.dart';

enum ScannedProductState { FOUND, NOT_FOUND, LOADING }

class ContinuousScanModel {
  ContinuousScanModel({@required this.contributionMode})
      : carouselController = CarouselController();

  QRViewController _scannerController;
  final CarouselController carouselController;

  final Map<String, ScannedProductState> _scannedBarcodes =
      <String, ScannedProductState>{};
  final Map<String, Widget> cardTemplates = <String, Widget>{};

  List<Product> foundProducts = <Product>[];

  String _barcodeTrustCheck;

  bool contributionMode;

  bool _firstScan = true;

  LocalDatabase _localDatabase;

  void setLocalDatabase(final LocalDatabase localDatabase) =>
      _localDatabase = localDatabase;

  void setupScanner(QRViewController controller, final Function setState) {
    _scannerController = controller;
    _scannerController.scannedDataStream.listen(
      (String barcode) => onScan(barcode, setState),
    );
  }

  Future<void> onScan(String code, Function setState) async {
    print('Barcode detected : $code');
    if (_barcodeTrustCheck != code) {
      _barcodeTrustCheck = code;
      return;
    }
    if (_addBarcode(code)) {
      await _generateScannedProductsCardTemplates();
      setState(() {});
      if (!_firstScan) {
        carouselController.animateToPage(cardTemplates.length - 1);
      } else {
        _firstScan = false;
      }
    }
  }

  Future<void> onScanAlt(
      String code, List<Offset> offsets, final Function setState) async {
    print('Barcode detected : $code');
    if (_addBarcode(code)) {
      await _generateScannedProductsCardTemplates();
      setState(() {});
      if (cardTemplates.isNotEmpty) {
        carouselController.animateToPage(
          cardTemplates.length - 1,
        );
      }
    }
  }

  Future<bool> _generateScannedProductsCardTemplates(
      {bool switchMode = false}) async {
    for (final String scannedBarcode in _scannedBarcodes.keys) {
      switch (_scannedBarcodes[scannedBarcode]) {
        case ScannedProductState.FOUND:
          if (switchMode) {
            final Product product = await _localDatabase.getProduct(
                scannedBarcode); // Acceptable thanks to offline first
            _setCardTemplate(
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
          final Product product =
              await BarcodeProductQuery(scannedBarcode).getProduct();
          if (product != null) {
            _scannedBarcodes[scannedBarcode] = ScannedProductState.FOUND;
            await _localDatabase.putProduct(product);
            _setCardTemplate(
                scannedBarcode,
                contributionMode
                    ? SmoothProductCardEdit(
                        heroTag: product.barcode, product: product)
                    : SmoothProductCardFound(
                        heroTag: product.barcode, product: product));
            foundProducts.add(product);
          } else {
            _scannedBarcodes[scannedBarcode] = ScannedProductState.NOT_FOUND;
            _setCardTemplate(
              scannedBarcode,
              SmoothProductCardNotFound(
                barcode: scannedBarcode,
                callback: () =>
                    _setCardTemplate(scannedBarcode, SmoothProductCardThanks()),
              ),
            );
          }
          break;
      }
    }
    return true;
  }

  bool _addBarcode(String newBarcode) {
    if (_scannedBarcodes[newBarcode] == null) {
      _scannedBarcodes[newBarcode] = ScannedProductState.LOADING;
      _setCardTemplate(
          newBarcode, SmoothProductCardLoading(barcode: newBarcode));
      return true;
    }
    return false;
  }

  void _setCardTemplate(String barcode, Widget cardTemplate) {
    cardTemplates[barcode] = cardTemplate;
  }

  Future<void> contributionModeSwitch(bool value) async {
    contributionMode = value;
    await _generateScannedProductsCardTemplates(switchMode: true);
  }
}
