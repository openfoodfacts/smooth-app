import 'dart:async';

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
    ProductQuery.setUserAgentComment(isScanned ? 'scan' : 'search');
    final FetchedProduct fetchedProduct = await ProductRefresher()
        .silentFetchAndRefresh(
          barcode: barcode,
          localDatabase: daoProduct.localDatabase,
        );
    ProductQuery.setUserAgentComment('');
    if (fetchedProduct.product != null) {
      if (fetchedProduct.product!.obsolete == true) {
        AnalyticsHelper.trackProductEvent(
          AnalyticsEvent.obsoleteProduct,
          product: fetchedProduct.product!,
        );
      }
      return fetchedProduct;
    }

    if (fetchedProduct.status == FetchedProductStatus.internetNotFound) {
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
    }

    return fetchedProduct;
  }
}
