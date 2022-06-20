import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/ProductListQueryConfiguration.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/up_to_date_product_provider.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
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

class _ProductListPageState extends State<ProductListPage>
    with TraceableClientMixin {
  late ProductList productList;
  final Set<String> _selectedBarcodes = <String>{};
  bool _selectionMode = false;

  static const String _popupActionClear = 'clear';
  static const String _popupActionRename = 'rename';

  @override
  String get traceName => 'Opened list_page ${widget.productList.listType}';

  @override
  String get traceTitle => 'list_page';

  @override
  void initState() {
    super.initState();
    productList = widget.productList;
  }

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
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
      case ProductListType.HTTP_USER_CONTRIBUTOR:
      case ProductListType.HTTP_USER_INFORMER:
      case ProductListType.HTTP_USER_PHOTOGRAPHER:
      case ProductListType.HTTP_USER_TO_BE_COMPLETED:
        dismissible = false;
    }
    final bool enableClear = products.isNotEmpty;
    final bool enableRename = productList.listType == ProductListType.USER;
    return Scaffold(
      floatingActionButton: _selectionMode || products.length <= 1
          ? null
          : FloatingActionButton.extended(
              onPressed: () => setState(() => _selectionMode = true),
              label: Text(appLocalizations.compare_products_mode),
              icon: const Icon(Icons.compare_arrows),
            ),
      appBar: AppBar(
        actions: _selectionMode || !(enableClear || enableRename)
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
                              positiveAction: SmoothActionButton(
                                onPressed: () async {
                                  daoProductList.clear(productList);
                                  await daoProductList.get(productList);
                                  setState(() {});
                                  if (!mounted) {
                                    return;
                                  }
                                  Navigator.of(context).pop();
                                },
                                text: appLocalizations.yes,
                              ),
                              negativeAction: SmoothActionButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                text: appLocalizations.no,
                              ),
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
                    if (enableClear)
                      PopupMenuItem<String>(
                        value: _popupActionClear,
                        child: Text(appLocalizations.user_list_popup_clear),
                      ),
                    if (enableRename)
                      PopupMenuItem<String>(
                        value: _popupActionRename,
                        child: Text(appLocalizations.user_list_popup_rename),
                      ),
                  ],
                )
              ],
        title: Text(
          ProductQueryPageHelper.getProductListLabel(
            productList,
            context,
            verbose: false,
          ),
          overflow: TextOverflow.fade,
          //style: TextStyle(color: Colors.black),
        ),
        // Force a light status bar
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: products.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  'assets/misc/empty-list.svg',
                  height: MediaQuery.of(context).size.height * .4,
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
                    textAlign: TextAlign.center,
                    style: themeData.textTheme.bodyText2?.apply(
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  if (_selectionMode)
                    Padding(
                      padding: const EdgeInsets.all(SMALL_SPACE),
                      child: _buildCompareBar(products, appLocalizations),
                    ),
                  Expanded(
                    child: Consumer<UpToDateProductProvider>(
                      builder: (
                        _,
                        final UpToDateProductProvider provider,
                        __,
                      ) =>
                          ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (BuildContext context, int index) {
                          Product product = products[index];
                          final Product? refreshedProduct =
                              provider.get(product);
                          if (refreshedProduct != null) {
                            product = refreshedProduct;
                            productList.refresh(product);
                          }
                          return _buildItem(
                            dismissible,
                            products,
                            index,
                            localDatabase,
                            appLocalizations,
                            refreshedProduct,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildItem(
    final bool dismissible,
    final List<Product> products,
    final int index,
    final LocalDatabase localDatabase,
    final AppLocalizations appLocalizations,
    final Product? refreshedProduct,
  ) {
    final Product product = refreshedProduct ?? products[index];
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
    final Widget child = InkWell(
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
                selected ? Icons.check_box : Icons.check_box_outline_blank,
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
          final bool removed = productList.remove(product.barcode!);
          if (removed) {
            DaoProductList(localDatabase).put(productList);
            _selectedBarcodes.remove(product.barcode);
            setState(() => products.removeAt(index));
          }
          if (!mounted) {
            return;
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
        if (!mounted) {
          return;
        }
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

  Widget _buildCompareBar(
    final List<Product> products,
    final AppLocalizations appLocalizations,
  ) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ElevatedButton(
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
            child: Text(
              appLocalizations.plural_compare_x_products(
                _selectedBarcodes.length,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => setState(() => _selectionMode = false),
            child: Text(appLocalizations.cancel),
          ),
        ],
      );
}
