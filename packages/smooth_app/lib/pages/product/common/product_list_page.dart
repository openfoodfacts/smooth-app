// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

// Project imports:
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/functions/launchURL.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/product/common/product_list_dialog_helper.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

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
  ProductList productList;

  static const String _TRANSLATE_ME_RENAME = 'Rename';
  static const String _TRANSLATE_ME_DELETE = 'Delete';
  static const String _TRANSLATE_ME_CHANGE = 'Change icon';
  static const String _TRANSLATE_ME_COPY = 'copy';
  static const String _TRANSLATE_ME_PASTE = 'paste';
  static const String _TRANSLATE_ME_CLEAR = 'clear';
  static const String _TRANSLATE_ME_GROCERY = 'grocery';

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    productList ??= widget.productList;
    final List<Product> products = _compact(productList.getList());
    bool pastable = false;
    bool renamable = false;
    bool deletable = false;
    switch (productList.listType) {
      case ProductList.LIST_TYPE_USER_DEFINED:
        // TODO(monsieurtanuki): clear the preference when the product list is deleted
        pastable = userPreferences.getProductListCopy() != null;
        deletable = true;
        renamable = true;
        break;
      case ProductList.LIST_TYPE_HTTP_SEARCH_KEYWORDS:
      case ProductList.LIST_TYPE_HTTP_SEARCH_CATEGORY:
      case ProductList.LIST_TYPE_HTTP_SEARCH_GROUP:
        deletable = true;
        break;
      case ProductList.LIST_TYPE_SCAN:
      case ProductList.LIST_TYPE_HISTORY:
    }
    const int INDEX_COPY = 0;
    final int indexPaste = pastable ? INDEX_COPY + 1 : -1;
    final int indexClear = pastable ? indexPaste + 1 : INDEX_COPY + 1;
    final int indexShare = indexClear + 1;
    final int indexGrocery = indexShare + 1;
    return Scaffold(
      bottomNavigationBar: Builder(
        builder: (BuildContext context) => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
                icon: Icon(Icons.copy), label: _TRANSLATE_ME_COPY),
            if (pastable)
              const BottomNavigationBarItem(
                  icon: Icon(Icons.paste), label: _TRANSLATE_ME_PASTE),
            const BottomNavigationBarItem(
                icon: Icon(Icons.highlight_remove), label: _TRANSLATE_ME_CLEAR),
            const BottomNavigationBarItem(
                icon: Icon(Icons.launch), label: 'web'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.local_grocery_store),
                label: _TRANSLATE_ME_GROCERY),
          ],
          onTap: (final int index) async {
            if (index == INDEX_COPY) {
              await userPreferences.setProductListCopy(productList.lousyKey);
            } else if (index == indexPaste) {
              final int pasted = await daoProductList.paste(
                  productList, userPreferences.getProductListCopy());
              localDatabase.notifyListeners();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$pasted products pasted'),
                  duration: const Duration(seconds: 2),
                ),
              );
              setState(() {});
            } else if (index == indexClear) {
              await daoProductList.clear(productList);
              localDatabase.notifyListeners();
            } else if (index == indexShare) {
              final List<String> codes = <String>[];
              for (final Product product in products) {
                codes.add(product.barcode);
              }
              Launcher().launchURL(
                  context,
                  'https://openfoodfacts.org/products/${codes.join(',')}',
                  true);
              return;
            } else if (index == indexGrocery) {
              final List<String> names = <String>[];
              for (final Product product in products) {
                names.add(
                  '* ${product.productName}'
                  ', ${product.brands}'
                  ', ${product.quantity}',
                );
              }
              Share.share(
                names.join('\n'),
                subject: productList.parameters,
              );
            } else {
              throw Exception('Unexpected index $index');
            }
          },
        ),
      ),
      appBar: AppBar(
        backgroundColor: SmoothTheme.getColor(
          colorScheme,
          productList.getMaterialColor(),
          ColorDestination.APP_BAR_BACKGROUND,
        ),
        title: Row(
          children: <Widget>[
            productList.getIcon(
              colorScheme,
              ColorDestination.APP_BAR_FOREGROUND,
            ),
            const SizedBox(width: 8.0),
            Text(
              ProductQueryPageHelper.getProductListLabel(productList,
                  verbose: false), // TODO(monsieurtanuki): handle the overflow
            ),
          ],
        ),
        actions: (!renamable) && (!deletable)
            ? null
            : <Widget>[
                PopupMenuButton<String>(
                  itemBuilder: (final BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    if (renamable)
                      const PopupMenuItem<String>(
                        value: 'rename',
                        child: Text(_TRANSLATE_ME_RENAME),
                        enabled: true,
                      ),
                    const PopupMenuItem<String>(
                      value: 'change',
                      child: Text(_TRANSLATE_ME_CHANGE),
                      enabled: true,
                    ),
                    if (deletable)
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text(_TRANSLATE_ME_DELETE),
                        enabled: true,
                      ),
                  ],
                  onSelected: (final String value) async {
                    switch (value) {
                      case 'rename':
                        final ProductList renamedProductList =
                            await ProductListDialogHelper.openRename(
                                context, daoProductList, productList);
                        if (renamedProductList == null) {
                          return;
                        }
                        productList = renamedProductList;
                        localDatabase.notifyListeners();
                        break;
                      case 'delete':
                        if (await ProductListDialogHelper.openDelete(
                            context, daoProductList, productList)) {
                          Navigator.pop(context);
                          localDatabase.notifyListeners();
                        }
                        break;
                      case 'change':
                        final bool changed =
                            await ProductListDialogHelper.openChangeIcon(
                                context, daoProductList, productList);
                        if (changed) {
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
                        background: Container(color: colorScheme.background),
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
