import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/pages/pantry/common/pantry_button.dart';
import 'package:smooth_app/pages/pantry/pantry_page.dart';
import 'package:smooth_app/pages/product/common/product_list_button.dart';
import 'package:smooth_app/pages/product/common/product_list_page.dart';
import 'package:smooth_app/data_models/pantry.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/product/common/product_list_dialog_helper.dart';
import 'package:smooth_app/pages/pantry/common/pantry_dialog_helper.dart';

/// Helper for product copy as multi selected
class ProductCopyHelper {
  Future<List<Widget>> getButtons({
    required final BuildContext context,
    required final DaoProductList daoProductList,
    required final DaoProduct daoProduct,
    required final Map<PantryType, List<Pantry>> allPantries,
    required final UserPreferences userPreferences,
    final ProductList ignoredProductList,
    final Pantry ignoredPantry,
  }) async {
    final List<Widget> children = <Widget>[];
    final List<ProductList> productLists = await daoProductList.getAll(
      typeFilter: <String>[ProductList.LIST_TYPE_USER_DEFINED],
    );
    for (final ProductList productList in productLists) {
      if (ignoredProductList != null &&
          productList.parameters == ignoredProductList.parameters) {
        // skipped, it's the same product list
      } else {
        children.add(
          ProductListButton(
            productList: productList,
            onPressed: () => Navigator.pop<ProductList>(context, productList),
          ),
        );
      }
    }
    children.add(
      ProductListButton.add(
        onlyIcon: children.isNotEmpty,
        onPressed: () async {
          final ProductList newProductList =
              await ProductListDialogHelper.openNew(
            context,
            daoProductList,
            productLists,
          );
          if (newProductList == null) {
            return;
          }
          Navigator.pop<ProductList>(context, newProductList);
        },
      ),
    );
    final List<PantryType> pantryTypes = <PantryType>[
      PantryType.PANTRY,
      PantryType.SHOPPING,
    ];
    for (final PantryType pantryType in pantryTypes) {
      final List<Pantry> pantries = allPantries[pantryType];
      int index = 0;
      for (final Pantry pantry in pantries) {
        if (ignoredPantry != null &&
            ignoredPantry.name == pantry.name &&
            ignoredPantry.pantryType == pantry.pantryType) {
          // skip
        } else {
          children.add(
            PantryButton(
              pantries: pantries,
              index: index,
              onPressed: () => Navigator.pop<Pantry>(context, pantry),
            ),
          );
        }
        index++;
      }
      children.add(
        PantryButton.add(
          pantries: pantries,
          pantryType: pantryType,
          onlyIcon: children.isNotEmpty,
          onPressed: () async {
            final Pantry newPantry = await PantryDialogHelper.openNew(
              context,
              pantries,
              pantryType,
              userPreferences,
            );
            if (newPantry == null) {
              return;
            }
            Navigator.pop<Pantry>(context, newPantry);
          },
        ),
      );
    }
    return children;
  }

  Future<void> copy({
    required final BuildContext context,
    required dynamic target,
    required final Map<PantryType, List<Pantry>> allPantries,
    required final DaoProductList daoProductList,
    required final List<Product> products,
    required final UserPreferences userPreferences,
  }) async {
    int count; // late
    Widget Function(BuildContext) go; // late
    if (target is ProductList) {
      count = await _addToProductList(
        daoProductList,
        target,
        products,
      );
      go = (BuildContext context) => ProductListPage(target);
    } else if (target is Pantry) {
      final List<Pantry> pantries = allPantries[target.pantryType];
      int index = 0;
      for (final Pantry pantry in pantries) {
        if (pantry.name == target.name) {
          final int value = index;
          count = await _addToPantry(
            pantries,
            value,
            target.pantryType,
            products,
            userPreferences,
          );
          go = (BuildContext context) => PantryPage(
                pantries: pantries,
                pantry: target,
              );
        }
        index++;
      }
    } else {
      throw Exception('unknown type $target');
    }
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
              MaterialPageRoute<Widget>(builder: go),
            );
          },
        ),
      ),
    );
  }

  Future<int> _addToProductList(
    final DaoProductList daoProductList,
    final ProductList target,
    final List<Product> products,
  ) async {
    await daoProductList.get(target);
    int count = 0;
    for (final Product product in products) {
      if (target.add(product)) {
        count++;
      }
    }
    if (count > 0) {
      await daoProductList.put(target);
    }
    return count;
  }

  Future<int> _addToPantry(
    final List<Pantry> pantries,
    final int index,
    final PantryType pantryType,
    final List<Product> products,
    final UserPreferences userPreferences,
  ) async {
    int count = 0;
    final Pantry pantry = pantries[index];
    final List<String> currentBarcodes = pantry.getOrderedBarcodes();
    for (final Product product in products) {
      if (currentBarcodes.contains(product.barcode)) {
        // do nothing?
      } else {
        pantry.add(product);
        count++;
      }
    }
    if (count > 0) {
      await Pantry.putAll(userPreferences, pantries, pantryType);
    }
    return count;
  }
}
