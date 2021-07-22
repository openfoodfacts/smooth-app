import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/product/common/smooth_chip.dart';

/// Button related to an existing product list
class ProductListButton extends StatelessWidget {
  const ProductListButton({
    required this.productList,
    required this.onPressed,
  });

  final ProductList productList;
  final Function onPressed;

  @override
  Widget build(BuildContext context) => SmoothChip(
        onPressed: onPressed,
        iconData: productList.iconData,
        label: ProductQueryPageHelper.getProductListLabel(
          productList,
          context,
          verbose: false,
        ),
        materialColor: productList.getMaterialColor(),
        shape: ProductQueryPageHelper.getShape(productList.listType),
      );
}
