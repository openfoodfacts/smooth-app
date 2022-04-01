import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/ProductListQueryConfiguration.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
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
    final ThemeData themeData = Theme.of(context);
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
        elevation: 0,
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.onBackground,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (_selectionMode)
              ElevatedButton(
                child: Text(
                  appLocalizations.plural_compare_x_products(
                    _selectedBarcodes.length,
                  ),
                ),
                onPressed: _selectedBarcodes.length >=
                        2 // compare button is enabled only if 2 or more products have been selected
                    ? () async {
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
                              title: 'Your ranking', // TODO(X): Translate
                            ),
                          ),
                        );
                        setState(() => _selectionMode = false);
                      }
                    : null,
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
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.find_in_page_rounded,
                  color: colorScheme.primary,
                  size: VERY_LARGE_SPACE * 10,
                  semanticLabel: 'History not available',
                ),
                Text(
                  'Start scanning !', // TODO(bhattabhi013): localization
                  style: themeData.textTheme.headlineLarge
                      ?.apply(color: colorScheme.onBackground),
                ),
                Padding(
                  padding: const EdgeInsets.all(VERY_LARGE_SPACE),
                  child: Text(
                    'Product you scan in will appear here and you can check detailed information about them', // TODO(bhattabhi013): localization
                    style: TextStyle(
                      color: colorScheme.onBackground,
                    ),
                  ),
                )
              ],
            )
          : RefreshIndicator(
              //if it is in selectmode then refresh indicator is not shown
              notificationPredicate:
                  _selectionMode ? (_) => false : (_) => true,
              onRefresh: () async => _refreshListProducts(
                products,
                localDatabase,
              ),
              child: ListView.builder(
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
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        margin: const EdgeInsets.symmetric(vertical: 14),
                        color: RED_COLOR,
                        padding: const EdgeInsets.only(right: 30),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      key: Key(product.barcode!),
                      onDismissed: (final DismissDirection direction) async {
                        final bool removed =
                            productList.remove(product.barcode!);
                        if (removed) {
                          await daoProductList.put(productList);
                          _selectedBarcodes.remove(product.barcode);
                          setState(() => products.removeAt(index));
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              removed
                                  ? appLocalizations.product_removed_history
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
            ),
    );
  }

  /// Calls the "refresh products" part with dialogs on top.
  Future<void> _refreshListProducts(
    final List<Product> products,
    final LocalDatabase localDatabase,
  ) async {
    final bool? done = await LoadingDialog.run<bool>(
      context: context,
      title:
          'refreshing the history products', // TODO(monsieurtanuki): localize
      future: _reloadProducts(products, localDatabase),
    );
    switch (done) {
      case null: // user clicked on "stop"
        return;
      case true:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Just refreshed'), // TODO(monsieurtanuki): localize
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {});
        return;
      case false:
        LoadingDialog.error(context: context);
        return;
    }
  }

  /// Fetches the products from the API and refreshes the local database
  Future<bool> _reloadProducts(
    final List<Product> products,
    final LocalDatabase localDatabase,
  ) async {
    try {
      final List<String> barcodes = <String>[];
      for (final Product product in products) {
        barcodes.add(product.barcode!);
      }
      final SearchResult searchResult = await OpenFoodAPIClient.getProductList(
        ProductQuery.getUser(),
        ProductListQueryConfiguration(
          barcodes,
          fields: ProductQuery.fields,
          language: ProductQuery.getLanguage(),
          country: ProductQuery.getCountry(),
        ),
      );
      final List<Product>? freshProducts = searchResult.products;
      if (freshProducts == null) {
        return false;
      }
      await DaoProduct(localDatabase).putAll(freshProducts);
      freshProducts.forEach(productList.refresh);
      return true;
    } catch (e) {
      //
    }
    return false;
  }
}
