// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/pages/product/common/product_list_page.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

class ProductListButton extends StatelessWidget {
  const ProductListButton(this.productList, this.daoProductList);

  final ProductList productList;
  final DaoProductList daoProductList;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton.icon(
      icon: productList.getIcon(
        colorScheme,
        ColorDestination.BUTTON_FOREGROUND,
      ),
      label: Text(
        ProductQueryPageHelper.getProductListLabel(
          productList,
          context,
          verbose: false,
        ),
        style: TextStyle(
          color: SmoothTheme.getColor(
            colorScheme,
            productList.getMaterialColor(),
            ColorDestination.BUTTON_FOREGROUND,
          ),
        ),
      ),
      onPressed: () async {
        await daoProductList.get(productList);
        await Navigator.push<Widget>(
          context,
          MaterialPageRoute<Widget>(
            builder: (BuildContext context) => ProductListPage(productList),
          ),
        );
        daoProductList.localDatabase.notifyListeners();
      },
      style: ElevatedButton.styleFrom(
        primary: SmoothTheme.getColor(
          colorScheme,
          productList.getMaterialColor(),
          ColorDestination.BUTTON_BACKGROUND,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
      ),
    );
  }
}
