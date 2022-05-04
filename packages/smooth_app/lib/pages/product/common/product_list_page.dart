import 'package:flutter/cupertino.dart';
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
import 'package:smooth_app/helpers/robotoff_insight_helper.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/product/common/product_list_clipboard_helper.dart';
import 'package:smooth_app/pages/product/common/product_list_item_simple.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/product_list_user_dialog_helper.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage(this.productList);

  final ProductList productList;

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

enum _SelectionMode {
  none,
  compare,
  copy,
}

class _ProductListPageState extends State<ProductListPage> {
  late ProductList productList;
  bool first = true;
  final Set<String> _selectedBarcodes = <String>{};
  _SelectionMode _selectionMode = _SelectionMode.none;

  static const String _popupActionClear = 'clear';
  static const String _popupActionRename = 'rename';
  static const String _popupActionCopy = 'copy';
  static const String _popupActionPaste = 'paste';

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
      case ProductListType.USER:
        dismissible = productList.barcodes.isNotEmpty;
        break;
      case ProductListType.HTTP_SEARCH_CATEGORY:
      case ProductListType.HTTP_SEARCH_KEYWORDS:
        dismissible = false;
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.onBackground,
        actions: _selectionMode != _SelectionMode.none
            ? null
            : <Widget>[
                PopupMenuButton<String>(
                  onSelected: (final String action) async {
                    switch (action) {
                      case _popupActionClear:
                        await daoProductList.clear(productList);
                        await daoProductList.get(productList);
                        setState(() {});
                        break;
                      case _popupActionRename:
                        final ProductList? renamedProductList =
                            await ProductListUserDialogHelper(daoProductList)
                                .showRenameUserListDialog(context, productList);
                        if (renamedProductList == null) {
                          return;
                        }
                        setState(() => productList = renamedProductList);
                        break;
                      case _popupActionCopy:
                        setState(() => _selectionMode = _SelectionMode.copy);
                        break;
                      case _popupActionPaste:
                        final int? result =
                            await ProductListClipboardHelper(productList)
                                .paste(localDatabase);
                        final String message;
                        if (result == null) {
                          message = 'Error while pasting from the clipboard';
                        } else if (result == 0) {
                          message = 'No new barcode found in the clipboard';
                        } else {
                          message = '$result pasted from clipboard';
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                        if (result != null && result > 0) {
                          setState(() {});
                        }
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    if (!productList.isEmpty())
                      _buildPopupMenuItem(
                        _popupActionClear,
                        appLocalizations.user_list_popup_clear,
                        CupertinoIcons.clear_circled,
                      ),
                    if (productList.listType == ProductListType.USER)
                      _buildPopupMenuItem(
                        _popupActionRename,
                        appLocalizations.user_list_popup_rename,
                        Icons.edit,
                      ),
                    if (!productList.isEmpty())
                      _buildPopupMenuItem(
                        _popupActionCopy,
                        'Copy', // TODO(monsieurtanuki): localize
                        Icons.copy,
                      ),
                    if (productList.listType == ProductListType.USER)
                      _buildPopupMenuItem(
                        _popupActionPaste,
                        'Paste', // TODO(monsieurtanuki): localize
                        Icons.paste,
                      ),
                  ],
                )
              ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (_selectionMode == _SelectionMode.compare)
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
                                PersonalizedRankingPage(
                              products: list,
                              title: appLocalizations.product_list_your_ranking,
                            ),
                          ),
                        );
                        setState(() => _selectionMode = _SelectionMode.none);
                      }
                    : null,
              ),
            if (_selectionMode == _SelectionMode.copy)
              ElevatedButton(
                child: Text(
                    'copy ${_selectedBarcodes.length} products'), // TODO(monsieurtanuki): localize
                onPressed: _selectedBarcodes
                        .isNotEmpty // copy button is enabled only if 1 or more products have been selected
                    ? () async {
                        final bool result =
                            await ProductListClipboardHelper(productList)
                                .copy(_selectedBarcodes);
                        final String message = result
                            ? 'Copied to clipboard'
                            : 'Error while copying to the clipboard';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                        setState(() => _selectionMode = _SelectionMode.none);
                      }
                    : null,
              ),
            if (_selectionMode != _SelectionMode.none)
              ElevatedButton(
                onPressed: () => setState(
                  () => _selectionMode = _SelectionMode.none,
                ),
                child: Text(appLocalizations.cancel),
              ),
            if (_selectionMode == _SelectionMode.none)
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
            if (_selectionMode == _SelectionMode.none && products.length >= 2)
              Flexible(
                child: ElevatedButton(
                  child: Text(appLocalizations.compare_products_mode),
                  onPressed: () => setState(
                    () => _selectionMode = _SelectionMode.compare,
                  ),
                ),
              ),
          ],
        ),
      ),
      body: products.isEmpty &&
              (productList.listType == ProductListType.HISTORY ||
                  productList.listType == ProductListType.SCAN_SESSION)
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.find_in_page_rounded,
                  color: colorScheme.primary,
                  size: VERY_LARGE_SPACE * 10,
                  semanticLabel: appLocalizations.product_list_empty_icon_desc,
                ),
                Text(
                  appLocalizations.product_list_empty_title,
                  style: themeData.textTheme.headlineLarge
                      ?.apply(color: colorScheme.onBackground),
                ),
                Padding(
                  padding: const EdgeInsets.all(VERY_LARGE_SPACE),
                  child: Text(
                    appLocalizations.product_list_empty_message,
                    style: TextStyle(
                      color: colorScheme.onBackground,
                    ),
                  ),
                )
              ],
            )
          : RefreshIndicator(
              //if it is in selectmode then refresh indicator is not shown
              notificationPredicate: _selectionMode != _SelectionMode.none
                  ? (_) => false
                  : (_) => true,
              onRefresh: () async => _refreshListProducts(
                products,
                localDatabase,
                appLocalizations,
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
                    onTap: _selectionMode != _SelectionMode.none ? onTap : null,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            _selectionMode != _SelectionMode.none ? 0 : 12.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        children: <Widget>[
                          if (_selectionMode != _SelectionMode.none)
                            Icon(
                              selected
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                            ),
                          Expanded(
                            child: ProductListItemSimple(
                              product: product,
                              onTap: _selectionMode != _SelectionMode.none
                                  ? onTap
                                  : null,
                              onLongPress: _selectionMode == _SelectionMode.none
                                  ? () => setState(() =>
                                      _selectionMode = _SelectionMode.compare)
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
                                  ? appLocalizations
                                      .product_removed_history // TODO(monsieurtanuki): not always "from history"
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
    final AppLocalizations appLocalizations,
  ) async {
    final bool? done = await LoadingDialog.run<bool>(
      context: context,
      title: appLocalizations.product_list_reloading_in_progress,
      future: _reloadProducts(products, localDatabase),
    );
    switch (done) {
      case null: // user clicked on "stop"
        return;
      case true:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appLocalizations.product_list_reloading_success),
            duration: const Duration(seconds: 2),
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
      final RobotoffInsightHelper robotoffInsightHelper =
          RobotoffInsightHelper(localDatabase);
      await robotoffInsightHelper.clearInsightAnnotationsSaved();
      return true;
    } catch (e) {
      //
    }
    return false;
  }

  PopupMenuItem<T> _buildPopupMenuItem<T>(
    final T value,
    final String title,
    final IconData icon,
  ) =>
      PopupMenuItem<T>(
        value: value,
        child: Row(
          children: <Widget>[
            Icon(icon),
            const SizedBox(width: SMALL_SPACE),
            Text(title),
          ],
        ),
      );
}
