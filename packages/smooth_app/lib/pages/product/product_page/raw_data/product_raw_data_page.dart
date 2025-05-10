import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

import 'package:smooth_app/pages/product/product_page/raw_data/models/product_raw_data_category.dart';
import 'package:smooth_app/pages/product/product_page/raw_data/product_raw_data_category_item.dart';

import 'package:smooth_app/pages/product/product_page/raw_data/product_raw_data_ext.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class ProductRawDataPage extends StatefulWidget {
  const ProductRawDataPage(this.product);

  final Product product;

  @override
  State<StatefulWidget> createState() => _ProductRawDataPageState();
}

class _ProductRawDataPageState extends State<ProductRawDataPage> {
  @override
  Widget build(BuildContext context) {
    final List<ProductRawDataCategory> productRawDatas =
        widget.product.toRawDatas();
    final Color dividerColor =
        context.lightTheme() ? const Color(0xFFF9F9F9) : Colors.white;

    return Scaffold(
      body: ListView.separated(
        itemCount: productRawDatas.length,
        separatorBuilder: (BuildContext context, _) => Divider(
          color: dividerColor,
          //remove default margin between elements
          height: 0,
        ),
        itemBuilder: (_, int index) {
          return ProductRawDataCategoryItem(productRawDatas[index]);
        },
      ),
    );
  }
}
