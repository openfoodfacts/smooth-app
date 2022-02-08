import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/product/common/product_list_item_simple.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage(this.productList);

  final ProductList productList;

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late ProductList productList;
  bool first = true;
  final Set<String> _selectedBarcodes = <String>{};
  bool _selectionMode = false;

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    if (first) {
      first = false;
      productList = widget.productList;
    }
    final List<Product> products = productList.getList();
    final bool dismissible;
    switch (productList.listType) {
      case ProductListType.SCAN_SESSION:
      case ProductListType.HISTORY:
        dismissible = productList.barcodes.isNotEmpty;
        break;
      case ProductListType.HTTP_SEARCH_CATEGORY:
      case ProductListType.HTTP_SEARCH_KEYWORDS:
      case ProductListType.HTTP_SEARCH_GROUP:
        dismissible = false;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // TODO(monsieurtanuki): night mode
        foregroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: _selectionMode && _selectedBarcodes.isEmpty
              ? MainAxisAlignment.end // just the cancel button, at the end
              : MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (_selectionMode && _selectedBarcodes.isNotEmpty)
              ElevatedButton(
                child: Text(
                  appLocalizations.plural_compare_x_products(
                    _selectedBarcodes.length,
                  ),
                ),
                onPressed: () async {
                  final List<Product> list = <Product>[];
                  for (final Product product in products) {
                    if (_selectedBarcodes.contains(product.barcode)) {
                      list.add(product);
                    }
                  }
                  await Navigator.push<Widget>(
                    context,
                    MaterialPageRoute<Widget>(
                      builder: (BuildContext context) =>
                          PersonalizedRankingPage.fromItems(
                        products: list,
                        title: 'Your ranking',
                      ),
                    ),
                  );
                  setState(() => _selectionMode = false);
                },
              ),
            if (_selectionMode)
              ElevatedButton(
                onPressed: () => setState(() => _selectionMode = false),
                child: Text(appLocalizations.cancel),
              ),
            if (!_selectionMode)
              Flexible(
                child: Text(
                  ProductQueryPageHelper.getProductListLabel(
                    productList,
                    context,
                    verbose: false,
                  ),
                  overflow: TextOverflow.fade,
                ),
              ),
            if ((!_selectionMode) && products.isNotEmpty)
              Flexible(
                child: ElevatedButton(
                  child: Text(appLocalizations.compare_products_mode),
                  onPressed: () => setState(() => _selectionMode = true),
                ),
              ),
          ],
        ),
      ),
      body: products.isEmpty
          ? Center(
              child: Text(appLocalizations.no_prodcut_in_list,
                  style: Theme.of(context).textTheme.subtitle1),
            )
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                final Product product = products[index];
                final String barcode = product.barcode!;
                final bool selected = _selectedBarcodes.contains(barcode);
                void onTap() => setState(
                      () {
                        if (selected) {
                          _selectedBarcodes.remove(barcode);
                        } else {
                          _selectedBarcodes.add(barcode);
                        }
                      },
                    );
                final Widget child = GestureDetector(
                  onTap: _selectionMode ? onTap : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: _selectionMode ? 0 : 12.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: <Widget>[
                        if (_selectionMode)
                          Icon(
                            selected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                          ),
                        Expanded(
                          child: ProductListItemSimple(
                            product: product,
                            onTap: _selectionMode ? onTap : null,
                            onLongPress: !_selectionMode
                                ? () => setState(() => _selectionMode = true)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                if (dismissible) {
                  return Dismissible(
                    background: Container(color: colorScheme.background),
                    key: Key(product.barcode!),
                    onDismissed: (final DismissDirection direction) async {
                      final bool removed = productList.remove(product.barcode!);
                      if (removed) {
                        await daoProductList.put(productList);
                        _selectedBarcodes.remove(product.barcode);
                        setState(() => products.removeAt(index));
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            removed
                                ? appLocalizations.product_removed
                                : appLocalizations.product_could_not_remove,
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      // TODO(monsieurtanuki): add a snackbar ("put back the food")
                    },
                    child: child,
                  );
                }
                return Container(
                  key: Key(product.barcode!),
                  child: child,
                );
              },
            ),
    );
  }
}
