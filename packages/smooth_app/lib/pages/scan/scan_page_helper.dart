import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';

Future<void> openPersonalizedRankingPage(BuildContext context) async {
  final ContinuousScanModel model = context.read<ContinuousScanModel>();
  await model.refreshProductList();
  await Navigator.push<Widget>(
    context,
    MaterialPageRoute<Widget>(
      builder: (BuildContext context) => PersonalizedRankingPage(
        productList: model.productList,
        title: ProductQueryPageHelper.getProductListLabel(
          model.productList,
          context,
        ),
      ),
    ),
  );
  await model.refresh();
}
