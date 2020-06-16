import 'package:flutter/foundation.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_template.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_loading.dart';

enum ScannedProductState { FOUND, NOT_FOUND, LOADING }

class ContinuousScanModel extends ChangeNotifier {
  ContinuousScanModel() {
    scannedBarcodes = <String, ScannedProductState>{};
    cardTemplates = <String, SmoothProductCardTemplate>{};
    paused = false;
  }

  Map<String, ScannedProductState> scannedBarcodes;
  Map<String, SmoothProductCardTemplate> cardTemplates;
  bool paused;

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

  void setCardTemplate(String barcode, SmoothProductCardTemplate cardTemplate) {
    cardTemplates[barcode] = cardTemplate;
    notifyListeners();
  }

  void pauseScan() {
    paused = true;
    notifyListeners();
  }

  void resumeScan() {
    paused = false;
    notifyListeners();
  }
}
