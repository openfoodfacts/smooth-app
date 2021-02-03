import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/product_query_page_helper.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:openfoodfacts/model/Product.dart';

import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/temp/user_preferences.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage(
    this.productList, {
    this.unique = true,
    this.reverse = false,
  });

  final ProductList productList;
  final bool unique;
  final bool reverse;

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final ProductList productList = widget.productList;
    final List<Product> products = _compact(productList.getList());
    bool pastable = false;
    bool deletable = false;
    switch (productList.listType) {
      case ProductList.LIST_TYPE_USER_DEFINED:
        // TODO(monsieurtanuki): clear the preference when the product list is deleted
        pastable = userPreferences.getProductListCopy() != null;
        deletable = true;
        break;
      case ProductList.LIST_TYPE_HTTP_SEARCH_KEYWORDS:
      case ProductList.LIST_TYPE_HTTP_SEARCH_GROUP:
        deletable = true;
        break;
      case ProductList.LIST_TYPE_SCAN:
      case ProductList.LIST_TYPE_HISTORY:
    }
    const int INDEX_COPY = 0;
    final int indexPaste = pastable ? INDEX_COPY + 1 : -1;
    final int indexClear = pastable ? indexPaste + 1 : INDEX_COPY + 1;
    final int indexDelete = deletable ? indexClear + 1 : -2;
    return Scaffold(
      bottomNavigationBar: Builder(
        builder: (BuildContext context) => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
                icon: Icon(Icons.copy), label: 'copy'),
            if (pastable)
              const BottomNavigationBarItem(
                  icon: Icon(Icons.paste), label: 'paste'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.highlight_remove), label: 'clear'),
            if (deletable)
              const BottomNavigationBarItem(
                  icon: Icon(Icons.delete), label: 'delete'),
          ],
          onTap: (final int index) async {
            if (index == INDEX_COPY) {
              await userPreferences.setProductListCopy(productList.lousyKey);
            } else if (index == indexPaste) {
              final int pasted = await daoProductList.paste(
                  productList, userPreferences.getProductListCopy());
              localDatabase.notifyListeners();
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('$pasted products pasted'),
                  duration: const Duration(seconds: 2),
                ),
              );
              setState(() {});
            } else if (index == indexClear) {
              await daoProductList.clear(productList);
              localDatabase.notifyListeners();
            } else if (index == indexDelete) {
              await daoProductList.delete(productList);
              Navigator.pop(context);
              localDatabase.notifyListeners();
            } else {
              throw Exception('Unexpected index $index');
            }
          },
        ),
      ),
      appBar: AppBar(
        title: Text(
          ProductQueryPageHelper.getProductListLabel(productList),
          style: TextStyle(color: colorScheme.onBackground),
        ),
        iconTheme: IconThemeData(color: colorScheme.onBackground),
      ),
      floatingActionButton: products.isEmpty
          ? null
          : FloatingActionButton(
              child: SvgPicture.asset(
                'assets/actions/smoothie.svg',
                width: 24.0,
                height: 24.0,
                color: colorScheme.onSecondary,
              ),
              onPressed: () => Navigator.push<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) =>
                      PersonalizedRankingPage(productList),
                ),
              ),
            ),
      body: products.isEmpty
          ? Center(
              child: Text('There is no product in this list',
                  style: Theme.of(context).textTheme.subtitle1),
            )
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                final Product product = products[index];
                final String barcode = product.barcode;
                final Widget child = Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  child: SmoothProductCardFound(
                      heroTag: barcode, product: product),
                );
                return !pastable
                    ? child
                    : Dismissible(
                        background: Container(color: Colors.red),
                        key: Key(barcode),
                        onDismissed: (final DismissDirection direction) async {
                          await daoProductList.removeBarcode(
                              productList, barcode);
                          setState(() {
                            products.removeAt(index);
                          });
                          // TODO(monsieurtanuki): add a snackbar ("put back the food")
                        },
                        child: child,
                      );
              },
            ),
    );
  }

  List<Product> _compact(final List<Product> products) {
    if (!widget.unique) {
      if (!widget.reverse) {
        return products;
      }
      final List<Product> result = <Product>[];
      products.reversed.forEach(result.add);
      return result;
    }
    final List<Product> result = <Product>[];
    final Set<String> barcodes = <String>{};
    final Iterable<Product> iterable =
        widget.reverse ? products.reversed : products;
    for (final Product product in iterable) {
      final String barcode = product.barcode;
      if (barcodes.contains(barcode)) {
        continue;
      }
      barcodes.add(barcode);
      result.add(product);
    }
    return result;
  }
}
