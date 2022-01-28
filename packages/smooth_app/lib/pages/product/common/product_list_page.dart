import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/product/common/product_list_dialog_helper.dart';
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
        title: _selectionMode
            ? Text(
                '${_selectedBarcodes.length}/${products.length} products', // TODO(monsieurtanuki): localize
                overflow: TextOverflow.fade,
              )
            : Row(
                children: <Widget>[
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
                ],
              ),
        actions: <Widget>[
          if (_selectionMode && _selectedBarcodes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.check_box_outline_blank),
              onPressed: () => setState(() => _selectedBarcodes.clear()),
            ),
          if (_selectionMode && _selectedBarcodes.length < products.length)
            IconButton(
              icon: const Icon(Icons.check_box),
              onPressed: () => setState(() => _populateAll(products)),
            ),
          if (dismissible && !_selectionMode)
            PopupMenuButton<String>(
              itemBuilder: (final BuildContext context) =>
                  <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'clear',
                  child: Text(appLocalizations.clear),
                  enabled: true,
                ),
              ],
              onSelected: (final String value) async {
                switch (value) {
                  case 'clear':
                    if (await ProductListDialogHelper.instance.openClear(
                      context,
                      daoProductList,
                      productList,
                    )) {
                      localDatabase.notifyListeners();
                    }
                    break;
                  default:
                    throw Exception('Unknown value: $value');
                }
              },
            ),
        ],
      ),
      body: products.isEmpty
          ? Center(
              child: Text(appLocalizations.no_prodcut_in_list,
                  style: Theme.of(context).textTheme.subtitle1),
            )
          : ListView.builder(
              itemCount: products.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  // header
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      if (_selectionMode && _selectedBarcodes.isNotEmpty)
                        ElevatedButton(
                          child: const Text(
                              'Compare'), // TODO(monsieurtanuki): localize
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
                                  title:
                                      '', // TODO(monsieurtanuki): find inspiration
                                ),
                              ),
                            );
                            setState(() => _selectionMode = false);
                          },
                        ),
                      if (_selectionMode)
                        ElevatedButton(
                          onPressed: () =>
                              setState(() => _selectionMode = false),
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                      if (!_selectionMode)
                        ElevatedButton(
                          onPressed: () => setState(
                            () {
                              _selectionMode = true;
                              _populateAll(products);
                            },
                          ),
                          child: const Text(
                              'Compare Mode'), // TODO(monsieurtanuki): localize
                        ),
                    ],
                  );
                }
                index--;
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

  void _populateAll(final List<Product> products) {
    _selectedBarcodes.clear();
    for (final Product product in products) {
      _selectedBarcodes.add(product.barcode!);
    }
  }
}
