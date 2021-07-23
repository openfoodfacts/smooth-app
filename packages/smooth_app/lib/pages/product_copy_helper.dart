import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/bottom_sheet_views/product_copy_view.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/pages/product/common/product_list_add_button.dart';
import 'package:smooth_app/pages/product/common/product_list_button.dart';
import 'package:smooth_app/pages/product/common/product_list_dialog_helper.dart';
import 'package:smooth_app/pages/product/common/product_list_page.dart';

/// Helper for product copy as multi selected
class ProductCopyHelper {
  /// Returns a user [ProductList] selected among the existing ones, or created
  Future<ProductList?> showProductListDialog({
    required final BuildContext context,
    required final DaoProductList daoProductList,
    required final DaoProduct daoProduct,
    final ProductList? ignoredProductList,
  }) async {
    final Map<String, List<Widget>> children = <String, List<Widget>>{};
    const List<String> USER_TYPE_FILTERS = <String>[
      ProductList.LIST_TYPE_USER_DEFINED,
      ProductList.LIST_TYPE_USER_PANTRY,
      ProductList.LIST_TYPE_USER_SHOPPING,
    ];
    for (final String productListType in USER_TYPE_FILTERS) {
      children[productListType] = <Widget>[];
    }
    final List<ProductList> productLists = await daoProductList.getAll(
      typeFilter: USER_TYPE_FILTERS,
    );
    for (final ProductList productList in productLists) {
      if (ignoredProductList != null &&
          productList.listType == ignoredProductList.listType &&
          productList.parameters == ignoredProductList.parameters) {
        // skipped, it's the same product list
      } else {
        children[productList.listType]!.add(
          ProductListButton(
            productList: productList,
            onPressed: () => Navigator.pop<ProductList>(context, productList),
          ),
        );
      }
    }
    for (final String productListType in USER_TYPE_FILTERS) {
      children[productListType]!.add(
        ProductListAddButton(
          onlyIcon: children.isNotEmpty,
          productListType: productListType,
          onPressed: () async {
            final ProductList? newProductList =
                await ProductListDialogHelper.openNew(
              context,
              daoProductList,
              productLists,
              productListType,
            );
            if (newProductList == null) {
              return;
            }
            Navigator.pop<ProductList>(context, newProductList);
          },
        ),
      );
    }
    return showCupertinoModalBottomSheet<ProductList>(
      expand: false,
      context: context,
      backgroundColor: Colors.transparent,
      bounce: true,
      builder: (BuildContext context) => ProductCopyView(children),
    );
  }

  /// Adds [products] to a [productList]
  Future<void> copy({
    required final BuildContext context,
    required final ProductList productList,
    required final DaoProductList daoProductList,
    required final List<Product> products,
  }) async {
    final int count = await _addToProductList(
      daoProductList,
      productList,
      products,
    );
    daoProductList.localDatabase.notifyListeners();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$count products actually added'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'GO',
          onPressed: () {
            Navigator.pop(context);
            Navigator.push<Widget>(
              context,
              MaterialPageRoute<Widget>(
                  builder: (BuildContext context) =>
                      ProductListPage(productList)),
            );
          },
        ),
      ),
    );
  }

  Future<int> _addToProductList(
    final DaoProductList daoProductList,
    final ProductList productList,
    final List<Product> products,
  ) async {
    await daoProductList.get(productList);
    int count = 0;
    for (final Product product in products) {
      if (productList.add(product)) {
        count++;
      }
    }
    if (count > 0) {
      await daoProductList.put(productList);
    }
    return count;
  }
}
