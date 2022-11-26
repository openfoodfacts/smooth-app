import 'dart:async';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/query/product_query.dart';

class BarcodeProductQuery {
  BarcodeProductQuery({
    required this.barcode,
    required this.daoProduct,
    required this.isScanned,
  });

  final String barcode;
  final DaoProduct daoProduct;
  final bool isScanned;

  Future<FetchedProduct> getFetchedProduct() async {
    try {
      ProductQuery.setUserAgentComment(isScanned ? 'scan' : 'search');
      final Product? product = await ProductRefresher().silentFetchAndRefresh(
        barcode: barcode,
        localDatabase: daoProduct.localDatabase,
      );
      if (product != null) {
        return FetchedProduct(product);
      }
    } catch (e) {
      return FetchedProduct.error(FetchedProductStatus.internetError);
    } finally {
      ProductQuery.setUserAgentComment('');
    }

    if (isScanned) {
      AnalyticsHelper.trackEvent(
        AnalyticsEvent.couldNotScanProduct,
        barcode: barcode,
      );
    } else {
      AnalyticsHelper.trackEvent(
        AnalyticsEvent.couldNotFindProduct,
        barcode: barcode,
      );
    }

    return FetchedProduct.error(FetchedProductStatus.internetNotFound);
  }
}
