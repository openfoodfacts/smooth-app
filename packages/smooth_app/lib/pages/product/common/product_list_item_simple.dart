import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/pages/multi_select_product_page.dart';

/// Widget for a [ProductList] item (simple product list)
class ProductListItemSimple extends StatelessWidget {
  const ProductListItemSimple({
    required this.product,
    required this.productList,
    required this.listRefresher,
    required this.daoProductList,
    this.reorderIndex,
    Key? key,
  }) : super(key: key);

  final Product product;
  final ProductList productList;
  final VoidCallback listRefresher;
  final DaoProductList daoProductList;
  // null for "not-user" lists
  final int? reorderIndex;

  @override
  Widget build(BuildContext context) => SmoothProductCardFound(
        heroTag: product.barcode!,
        product: product,
        refresh: () async {
          await daoProductList.get(productList);
          listRefresher();
        },
        handle: reorderIndex == null
            ? null
            : ReorderableDragStartListener(
                index: reorderIndex!,
                child: const Icon(Icons.drag_handle),
              ),
        onLongPress: () async {
          await Navigator.push<Widget>(
            context,
            MaterialPageRoute<Widget>(
              builder: (BuildContext context) => MultiSelectProductPage(
                barcode: product.barcode!,
                productList: productList,
              ),
            ),
          );
          listRefresher();
        },
      );
}
