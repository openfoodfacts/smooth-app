import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_extra.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/product/common/product_list_dialog_helper.dart';
import 'package:smooth_app/pages/product/common/product_list_item.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage(this.productList);

  final ProductList productList;

  @override
  _ProductListPageState createState() => _ProductListPageState();
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
    final Map<String, ProductExtra> productExtras = productList.productExtras;
    final List<_Meta> metas = <_Meta>[];
    if (productList.listType == ProductList.LIST_TYPE_HISTORY ||
        productList.listType == ProductList.LIST_TYPE_SCAN) {
      final int nowInMillis = LocalDatabase.nowInMillis();
      const int DAY_IN_MILLIS = 24 * 3600 * 1000;
      String? daysAgoLabel;
      for (final Product product in products) {
        final int timestamp = productExtras[product.barcode]!.intValue;
        final int daysAgo = ((nowInMillis - timestamp) / DAY_IN_MILLIS).round();
        final String tmpDaysAgoLabel = _getDaysAgoLabel(daysAgo);
        if (daysAgoLabel != tmpDaysAgoLabel) {
          daysAgoLabel = tmpDaysAgoLabel;
          metas.add(_Meta.daysAgoLabel(daysAgoLabel));
        }
        metas.add(_Meta.product(product));
      }
    } else {
      for (final Product product in products) {
        metas.add(_Meta.product(product));
      }
    }
    bool renamable = false;
    bool deletable = false;
    bool dismissible = false;
    bool reorderable = false;
    switch (productList.listType) {
      case ProductList.LIST_TYPE_USER_DEFINED:
      case ProductList.LIST_TYPE_USER_PANTRY:
      case ProductList.LIST_TYPE_USER_SHOPPING:
        // TODO(monsieurtanuki): clear the preference when the product list is deleted
        deletable = true;
        renamable = true;
        reorderable = true;
        dismissible = true;
        break;
      case ProductList.LIST_TYPE_HTTP_SEARCH_KEYWORDS:
      case ProductList.LIST_TYPE_HTTP_SEARCH_CATEGORY:
      case ProductList.LIST_TYPE_HTTP_SEARCH_GROUP:
        deletable = true;
        break;
      case ProductList.LIST_TYPE_SCAN:
      case ProductList.LIST_TYPE_HISTORY:
        dismissible = true;
        break;
      default:
        throw Exception('unknown list type ${productList.listType}');
    }
    return Scaffold(
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
        actions: (!renamable) && (!deletable)
            ? null
            : <Widget>[
                PopupMenuButton<String>(
                  itemBuilder: (final BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    if (renamable)
                      PopupMenuItem<String>(
                        value: 'rename',
                        child: Text(appLocalizations.rename),
                        enabled: true,
                      ),
                    PopupMenuItem<String>(
                      value: 'change',
                      child: Text(appLocalizations.change_icon),
                      enabled: true,
                    ),
                    if (deletable)
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text(appLocalizations.delete),
                        enabled: true,
                      ),
                  ],
                  onSelected: (final String value) async {
                    switch (value) {
                      case 'rename':
                        final ProductList? renamedProductList =
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
      floatingActionButton: metas.isEmpty
          ? null
          : FloatingActionButton(
              child: SvgPicture.asset(
                'assets/actions/smoothie.svg',
                width: 24.0,
                height: 24.0,
                color: colorScheme.onSecondary,
              ),
              onPressed: () => Navigator.push<Widget>(
                context,
                MaterialPageRoute<Widget>(
                  builder: (BuildContext context) =>
                      PersonalizedRankingPage(productList),
                ),
              ),
            ),
      body: metas.isEmpty
          ? Center(
              child: Text(appLocalizations.no_prodcut_in_list,
                  style: Theme.of(context).textTheme.subtitle1),
            )
          : ReorderableListView.builder(
              onReorder: (final int oldIndex, final int newIndex) async {
                productList.reorder(oldIndex, newIndex);
                daoProductList
                    .put(productList); // careful: if "await", flickering
                setState(() {});
              },
              buildDefaultDragHandles: false,
              itemCount: metas.length,
              itemBuilder: (BuildContext context, int index) {
                final _Meta meta = metas[index];
                if (!meta.isProduct()) {
                  return ListTile(
                    key: Key(meta.daysAgoLabel!),
                    leading: const Icon(Icons.history),
                    title: Text(meta.daysAgoLabel!),
                  );
                }
                final Product product = meta.product!;
                final Widget child = Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  child: ProductListItem(
                    product: product,
                    productList: productList,
                    listRefresher: () => setState(() {}),
                    daoProductList: daoProductList,
                    reorderIndex: reorderable ? index : null,
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
                        setState(() => metas.removeAt(index));
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

  static String _getDaysAgoLabel(final int daysAgo) {
    final int weeksAgo = (daysAgo.toDouble() / 7).round();
    final int monthsAgo = (daysAgo.toDouble() / (365.25 / 12)).round();
    if (daysAgo == 0) {
      return 'Today';
    }
    if (daysAgo == 1) {
      return 'Yesterday';
    }
    if (daysAgo < 7) {
      return '$daysAgo days ago';
    }
    if (weeksAgo == 1) {
      return 'One week ago';
    }
    if (monthsAgo == 0) {
      return '$weeksAgo weeks ago';
    }
    if (monthsAgo == 1) {
      return 'One month ago';
    }
    return '$monthsAgo months ago';
  }
}

class _Meta {
  _Meta.product(this.product) : daysAgoLabel = null;
  _Meta.daysAgoLabel(this.daysAgoLabel) : product = null;

  final Product? product;
  final String? daysAgoLabel;

  bool isProduct() => product != null;
}
