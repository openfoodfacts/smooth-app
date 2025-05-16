import 'dart:async';
import 'dart:ui';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/product/common/loading_status.dart';
import 'package:smooth_app/query/product_query.dart';

/// Async refresh of the prices of a product, with several loading phases.
class ProductPriceRefresher {
  ProductPriceRefresher({
    required this.pricesResult,
    required this.model,
    required this.userPreferences,
    required this.refreshDisplay,
  });

  final GetPricesModel model;
  final UserPreferences userPreferences;
  final VoidCallback refreshDisplay;

  GetPricesResult? pricesResult;

  LoadingStatus? _loadingStatus;

  LoadingStatus? get loadingStatus => _loadingStatus;

  String? _loadingError;

  String? get loadingError => _loadingError;

  String? get _barcode => model.parameters.productCode;

  Future<void> runIfNeeded() async {
    _resetIfNeedsUpdate();
    if (loadingStatus == null) {
      return _asyncLoad();
    }
  }

  void _resetIfNeedsUpdate() {
    if (_barcode == null) {
      return;
    }
    final int? latestUpdate = _latestUpdates[_barcode!];
    final int? latestRefresh = _latestRefreshes[_barcode!];
    if (latestRefresh != null &&
        latestUpdate != null &&
        latestUpdate > latestRefresh &&
        _loadingStatus != LoadingStatus.LOADING) {
      _loadingStatus = null;
      pricesResult = null;
    }
  }

  Future<void> _asyncLoad() async {
    _loadingStatus = LoadingStatus.LOADING;
    refreshDisplay();
    final MaybeError<GetPricesResult> result;
    if (pricesResult != null) {
      result = MaybeError<GetPricesResult>.value(pricesResult!);
    } else {
      result = await OpenPricesAPIClient.getPrices(
        model.parameters,
        uriHelper: ProductQuery.uriPricesHelper,
      );
    }
    if (result.isError) {
      _loadingError = result.detailError;
      _loadingStatus = LoadingStatus.ERROR;
    } else {
      pricesResult = result.value;
      _loadingStatus = LoadingStatus.LOADED;
      if (model.lazyCounterPrices != null && pricesResult!.total != null) {
        model.lazyCounterPrices!.setLocalCount(
          pricesResult!.total!,
          userPreferences,
          notify: true,
        );
      }
      if (_barcode != null) {
        _setLatestRefresh(_barcode!);
      }
    }
    refreshDisplay();
  }

  static final Map<String, int> _latestUpdates = <String, int>{};
  static final Map<String, int> _latestRefreshes = <String, int>{};

  static void setLatestUpdate(final String barcode) =>
      _latestUpdates[barcode] = _getTimestamp();

  static void _setLatestRefresh(final String barcode) =>
      _latestRefreshes[barcode] = _getTimestamp();

  static int _getTimestamp() => LocalDatabase.nowInMillis();
}
