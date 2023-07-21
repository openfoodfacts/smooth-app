import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/up_to_date_product_list_mixin.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/helpers/robotoff_insight_helper.dart';
import 'package:smooth_app/pages/all_product_list_page.dart';
import 'package:smooth_app/pages/inherited_data_manager.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/product/common/product_list_item_simple.dart';
import 'package:smooth_app/pages/product/common/product_list_popup_items.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Displays the products of a product list, with access to other lists.
class ProductListPage extends StatefulWidget {
  const ProductListPage(this.productList);

  final ProductList productList;

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage>
    with TraceableClientMixin, UpToDateProductListMixin {
  final Set<String> _selectedBarcodes = <String>{};
  bool _selectionMode = false;

  @override
  String get traceName => 'Opened list_page';

  @override
  String get traceTitle => 'list_page';

  @override
  void initState() {
    super.initState();
    initUpToDate(widget.productList, context.read<LocalDatabase>());
  }

  final ProductListPopupItem _rename = ProductListPopupRename();
  final ProductListPopupItem _clear = ProductListPopupClear();
  final ProductListPopupItem _openInWeb = ProductListPopupOpenInWeb();
  final ProductListPopupItem _share = ProductListPopupShare();

  //returns bool to handle WillPopScope
  Future<bool> _handleUserBacktap() async {
    if (_selectionMode) {
      setState(
        () {
          _selectionMode = false;
          _selectedBarcodes.clear();
        },
      );
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final ThemeData themeData = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    refreshUpToDate();
    final List<String> products = productList.getList();
    final bool dismissible;
    switch (productList.listType) {
      case ProductListType.SCAN_SESSION:
      case ProductListType.SCAN_HISTORY:
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
      case ProductListType.HTTP_ALL_TO_BE_COMPLETED:
        dismissible = false;
    }
    final bool enableClear = products.isNotEmpty;
    final bool enableRename = productList.listType == ProductListType.USER;

    return SmoothScaffold(
      floatingActionButton: products.isEmpty
          ? FloatingActionButton.extended(
              icon: const Icon(CupertinoIcons.barcode),
              label: Text(appLocalizations.product_list_empty_title),
              onPressed: () =>
                  InheritedDataManager.of(context).resetShowSearchCard(true),
            )
          : _selectionMode || products.length <= 1
              ? _CompareProductsButton(
                  selectedBarcodes: _selectedBarcodes,
                  barcodes: products,
                  onComparisonEnded: () {
                    setState(() => _selectionMode = false);
                  },
                )
              : FloatingActionButton.extended(
                  onPressed: () => setState(() => _selectionMode = true),
                  label: Text(appLocalizations.compare_products_mode),
                  icon: const Icon(Icons.compare_arrows),
                ),
      appBar: SmoothAppBar(
        centerTitle: _selectionMode ? false : null,
        actions: <Widget>[
          IconButton(
            icon: const Icon(CupertinoIcons.square_list),
            onPressed: () async {
              final ProductList? selected = await Navigator.push<ProductList>(
                context,
                MaterialPageRoute<ProductList>(
                  builder: (BuildContext context) => const AllProductListPage(),
                  fullscreenDialog: true,
                ),
              );
              if (selected == null) {
                return;
              }
              if (context.mounted) {
                await daoProductList.get(selected);
                if (context.mounted) {
                  setState(() => productList = selected);
                }
              }
            },
          ),
          if (enableClear || enableRename)
            PopupMenuButton<ProductListPopupItem>(
              onSelected: (final ProductListPopupItem action) async {
                final ProductList? differentProductList =
                    await action.doSomething(
                  productList: productList,
                  localDatabase: localDatabase,
                  context: context,
                );
                if (differentProductList != null) {
                  setState(() => productList = differentProductList);
                }
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<ProductListPopupItem>>[
                if (enableRename) _rename.getMenuItem(appLocalizations),
                _share.getMenuItem(appLocalizations),
                _openInWeb.getMenuItem(appLocalizations),
                if (enableClear) _clear.getMenuItem(appLocalizations),
              ],
            ),
        ],
        title: AutoSizeText(
          ProductQueryPageHelper.getProductListLabel(
            productList,
            appLocalizations,
          ),
          maxLines: 2,
        ),
        actionMode: _selectionMode,
        onLeaveActionMode: () {
          setState(() => _selectionMode = false);
        },
        actionModeTitle: Text(appLocalizations.compare_products_appbar_title),
        actionModeSubTitle:
            Text(appLocalizations.compare_products_appbar_subtitle),
        actionModeActions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              if (_selectedBarcodes.isNotEmpty) {
                await showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return SmoothAlertDialog(
                      body: Container(
                        padding: const EdgeInsetsDirectional.only(
                            start: SMALL_SPACE),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              appLocalizations.alert_clear_selected_user_list,
                            ),
                            const SizedBox(
                              height: SMALL_SPACE,
                            ),
                            Text(
                              appLocalizations.confirm_clear_selected_user_list,
                            ),
                          ],
                        ),
                      ),
                      positiveAction: SmoothActionButton(
                        onPressed: () async {
                          await daoProductList.bulkSet(
                            productList,
                            _selectedBarcodes.toList(growable: false),
                            include: false,
                          );
                          await daoProductList.get(productList);
                          if (!mounted) {
                            return;
                          }
                          setState(() {});
                          Navigator.of(context).maybePop();
                        },
                        text: appLocalizations.yes,
                      ),
                      negativeAction: SmoothActionButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        text: appLocalizations.no,
                      ),
                    );
                  },
                );
              } else {
                await showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return SmoothAlertDialog(
                      body: Text(
                        appLocalizations.alert_select_items_to_clear,
                      ),
                      positiveAction: SmoothActionButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        text: appLocalizations.okay,
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
      body: products.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(SMALL_SPACE),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/misc/empty-list.svg',
                    package: AppHelper.APP_PACKAGE,
                    width: MediaQuery.of(context).size.width / 2,
                  ),
                  Text(
                    appLocalizations.product_list_empty_message,
                    textAlign: TextAlign.center,
                    style: themeData.textTheme.bodyMedium?.apply(
                      color: themeData.colorScheme.onBackground,
                    ),
                  ),
                  EMPTY_WIDGET,
                ],
              ),
            )
          : WillPopScope(
              onWillPop: _handleUserBacktap,
              child: RefreshIndicator(
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
                  itemBuilder: (BuildContext context, int index) => _buildItem(
                    dismissible,
                    products,
                    index,
                    localDatabase,
                    appLocalizations,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildItem(
    final bool dismissible,
    final List<String> barcodes,
    final int index,
    final LocalDatabase localDatabase,
    final AppLocalizations appLocalizations,
  ) {
    final String barcode = barcodes[index];
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
        padding: EdgeInsetsDirectional.only(
          start: _selectionMode ? SMALL_SPACE : 0,
        ),
        child: Row(
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width:
                  _selectionMode ? (IconTheme.of(context).size ?? 20.0) : 0.0,
              child: Offstage(
                offstage: !_selectionMode,
                child: Icon(
                  selected ? Icons.check_box : Icons.check_box_outline_blank,
                ),
              ),
            ),
            Expanded(
              child: ProductListItemSimple(
                barcode: barcode,
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
          alignment: AlignmentDirectional.centerEnd,
          margin: const EdgeInsets.symmetric(vertical: 14),
          color: RED_COLOR,
          padding: const EdgeInsetsDirectional.only(end: 30),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        key: Key(barcode),
        onDismissed: (final DismissDirection direction) async {
          final bool removed = productList.remove(barcode);
          bool removedFromSelectedBarcodes = false;
          if (removed) {
            await DaoProductList(localDatabase).put(productList);
            removedFromSelectedBarcodes = _selectedBarcodes.remove(barcode);
            setState(() => barcodes.removeAt(index));
          }
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                removed
                    ? appLocalizations.product_removed_list
                    : appLocalizations.product_could_not_remove,
              ),
              duration: SnackBarDuration.medium,
              action: !removed
                  ? null
                  : SnackBarAction(
                      textColor: PRIMARY_BLUE_COLOR,
                      label: appLocalizations.undo,
                      onPressed: () async {
                        barcodes.insert(index, barcode);
                        productList.set(barcodes);
                        if (removedFromSelectedBarcodes) {
                          _selectedBarcodes.add(barcode);
                        }
                        await DaoProductList(localDatabase).put(productList);
                        setState(() {});
                      },
                    ),
            ),
          );
        },
        child: child,
      );
    }
    return Container(
      key: Key(barcode),
      child: child,
    );
  }

  /// Calls the "refresh products" part with dialogs on top.
  Future<void> _refreshListProducts(
    final List<String> products,
    final LocalDatabase localDatabase,
    final AppLocalizations appLocalizations,
  ) async {
    final bool? done = await LoadingDialog.run<bool>(
      context: context,
      title: appLocalizations.product_list_reloading_in_progress_multiple(
        products.length,
      ),
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
            content: Text(
              appLocalizations.product_list_reloading_success_multiple(
                products.length,
              ),
            ),
            duration: SnackBarDuration.short,
          ),
        );
        setState(() {});
        return;
      case false:
        // ignore: use_build_context_synchronously
        LoadingDialog.error(context: context);
        return;
    }
  }

  /// Fetches the products from the API and refreshes the local database
  Future<bool> _reloadProducts(
    final List<String> barcodes,
    final LocalDatabase localDatabase,
  ) async {
    try {
      final SearchResult searchResult = await OpenFoodAPIClient.searchProducts(
        ProductQuery.getUser(),
        ProductRefresher().getBarcodeListQueryConfiguration(barcodes),
      );
      final List<Product>? freshProducts = searchResult.products;
      if (freshProducts == null) {
        return false;
      }
      await DaoProduct(localDatabase).putAll(freshProducts);
      localDatabase.upToDate.setLatestDownloadedProducts(freshProducts);
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

class _CompareProductsButton extends StatelessWidget {
  const _CompareProductsButton({
    required this.selectedBarcodes,
    required this.barcodes,
    this.onComparisonEnded,
    Key? key,
  }) : super(key: key);

  final Set<String> selectedBarcodes;
  final List<String> barcodes;
  final VoidCallback? onComparisonEnded;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final bool enabled = selectedBarcodes.length >= 2;

    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.5,
      duration: SmoothAnimationsDuration.brief,
      child: FloatingActionButton.extended(
        label: Text(appLocalizations.compare_products_mode),
        icon: const Icon(Icons.compare_arrows),
        tooltip: enabled
            ? appLocalizations.plural_compare_x_products(
                selectedBarcodes.length,
              )
            : appLocalizations.compare_products_appbar_subtitle,
        onPressed: enabled
            ? () async {
                final List<String> list = <String>[];
                for (final String barcode in barcodes) {
                  if (selectedBarcodes.contains(barcode)) {
                    list.add(barcode);
                  }
                }

                await Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => PersonalizedRankingPage(
                      barcodes: list,
                      title: appLocalizations.product_list_your_ranking,
                    ),
                  ),
                );

                onComparisonEnded?.call();
              }
            : null,
      ),
    );
  }
}
