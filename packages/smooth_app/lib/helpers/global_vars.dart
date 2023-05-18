import 'package:app_store_shared/app_store_shared.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:smooth_app/helpers/entry_points_helper.dart';

class GlobalVars {
  GlobalVars._();

  static late final Scanner barcodeScanner;
  static late final AppStore appStore;
  static late final StoreLabel storeLabel;
  static late final ScannerLabel scannerLabel;
}
