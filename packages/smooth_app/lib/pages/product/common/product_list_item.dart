import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/pages/product/common/product_list_item_pantry.dart';
import 'package:smooth_app/pages/product/common/product_list_item_shopping.dart';
import 'package:smooth_app/pages/product/common/product_list_item_simple.dart';

/// Widget for a [ProductList] item, for all product list types
class ProductListItem extends StatelessWidget {
  const ProductListItem({
    required this.product,
    required this.productList,
    required this.listRefresher,
    required this.daoProductList,
    this.reorderIndex,
  });

  final Product product;
  final ProductList productList;
  final VoidCallback listRefresher;
  final DaoProductList daoProductList;
  final int? reorderIndex;

  @override
  Widget build(BuildContext context) {
    switch (productList.listType) {
      case ProductList.LIST_TYPE_USER_PANTRY:
        return ProductListItemPantry(
          product: product,
          productList: productList,
          listRefresher: listRefresher,
          daoProductList: daoProductList,
          reorderIndex: reorderIndex!,
        );
      case ProductList.LIST_TYPE_USER_SHOPPING:
        return ProductListItemShopping(
          product: product,
          productList: productList,
          listRefresher: listRefresher,
          daoProductList: daoProductList,
          reorderIndex: reorderIndex!,
        );
    }
    return ProductListItemSimple(
      product: product,
      productList: productList,
      listRefresher: listRefresher,
      daoProductList: daoProductList,
      reorderIndex: reorderIndex,
    );
  }
}
