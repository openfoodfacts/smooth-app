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
        title: Row(
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
        actions: !dismissible
            ? null
            : <Widget>[
                PopupMenuButton<String>(
                  itemBuilder: (final BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'clear',
                      child: Text('Clear'), // TODO(monsieurtanuki): translate
                      enabled: true,
                    ),
                  ],
                  onSelected: (final String value) async {
                    switch (value) {
                      case 'clear':
                        if (await ProductListDialogHelper.instance
                            .openClear(context, daoProductList, productList)) {
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
      floatingActionButton: products.isEmpty
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.emoji_events_outlined),
              onPressed: () async {
                await Navigator.push<Widget>(
                  context,
                  MaterialPageRoute<Widget>(
                    builder: (BuildContext context) =>
                        PersonalizedRankingPage(productList),
                  ),
                );
                setState(() {});
              },
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
                final Widget child = Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  child: ProductListItemSimple(product: product),
                );
                if (dismissible) {
                  return Dismissible(
                    background: Container(color: colorScheme.background),
                    key: Key(product.barcode!),
                    onDismissed: (final DismissDirection direction) async {
                      final bool removed = productList.remove(product.barcode!);
                      if (removed) {
                        await daoProductList.put(productList);
                        setState(() => products.removeAt(index));
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(removed
                              ? 'Product removed'
                              : 'Could not remove product'),
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
