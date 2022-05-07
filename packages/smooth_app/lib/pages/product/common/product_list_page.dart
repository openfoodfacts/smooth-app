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
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/helpers/robotoff_insight_helper.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/product/common/product_list_item_simple.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/product_list_user_dialog_helper.dart';

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

  static const String _popupActionClear = 'clear';
  static const String _popupActionRename = 'rename';

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
        actions: _selectionMode
            ? null
            : <Widget>[
                PopupMenuButton<String>(
                  onSelected: (final String action) async {
                    switch (action) {
                      case _popupActionClear:
                        await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return SmoothAlertDialog(
                              body: Text(appLocalizations.confirm_clear),
                              actions: <SmoothActionButton>[
                                SmoothActionButton(
                                  onPressed: () async {
                                    await daoProductList.clear(productList);
                                    await daoProductList.get(productList);
                                    setState(() {});
                                    Navigator.of(context).pop();
                                  },
                                  text: appLocalizations.yes,
                                ),
                                SmoothActionButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  text: appLocalizations.no,
                                ),
                              ],
                            );
                          },
                        );

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
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: _popupActionClear,
                      child: Text(appLocalizations.user_list_popup_clear),
                    ),
                    if (productList.listType == ProductListType.USER)
                      PopupMenuItem<String>(
                        value: _popupActionRename,
                        child: Text(appLocalizations.user_list_popup_rename),
                      ),
                  ],
                )
              ],
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
                                PersonalizedRankingPage(
                              products: list,
                              title: appLocalizations.product_list_your_ranking,
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
              notificationPredicate:
                  _selectionMode ? (_) => false : (_) => true,
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
}
