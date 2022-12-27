import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/model/parameter/BarcodeParameter.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/helpers/robotoff_insight_helper.dart';
import 'package:smooth_app/pages/inherited_data_manager.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/product/common/product_list_item_simple.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/product_list_user_dialog_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

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
  String get traceName => 'Opened list_page';

  @override
  String get traceTitle => 'list_page';

  @override
  void initState() {
    super.initState();
    productList = widget.productList;
  }

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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final List<String> products = productList.getList();
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
      case ProductListType.HTTP_ALL_TO_BE_COMPLETED:
        dismissible = false;
    }
    final bool enableClear = products.isNotEmpty;
    final bool enableRename = productList.listType == ProductListType.USER;
    return SmoothScaffold(
      floatingActionButton: _selectionMode || products.length <= 1
          ? null
          : FloatingActionButton.extended(
              onPressed: () => setState(() => _selectionMode = true),
              label: Text(appLocalizations.compare_products_mode),
              icon: const Icon(Icons.compare_arrows),
            ),
      appBar: SmoothAppBar(
        actions: !(enableClear || enableRename)
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
                              body: Text(
                                productList.listType == ProductListType.USER
                                    ? appLocalizations.confirm_clear_user_list(
                                        productList.parameters)
                                    : appLocalizations.confirm_clear,
                              ),
                              positiveAction: SmoothActionButton(
                                onPressed: () async {
                                  await daoProductList.clear(productList);
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
          ProductQueryPageHelper.getProductListLabel(productList, context),
          overflow: TextOverflow.fade,
        ),
        actionMode: _selectionMode,
        onLeaveActionMode: () {
          setState(() => _selectionMode = false);
        },
        actionModeTitle: Text(appLocalizations.compare_products_appbar_title),
        actionModeSubTitle:
            Text(appLocalizations.compare_products_appbar_subtitle),
        actionModeActions: <Widget>[
          _CompareProductsButton(
            selectedBarcodes: _selectedBarcodes,
            barcodes: products,
            onComparisonEnded: () {
              setState(() => _selectionMode = false);
            },
          )
        ],
      ),
      body: products.isEmpty
          ? GestureDetector(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(
                      'assets/misc/empty-list.svg',
                      height: MediaQuery.of(context).size.height * .4,
                      package: AppHelper.APP_PACKAGE,
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
                ),
              ),
              onTap: () {
                InheritedDataManager.of(context).resetShowSearchCard(true);
              },
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
        padding: EdgeInsets.only(
          left: _selectionMode ? SMALL_SPACE : 0,
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
          alignment: Alignment.centerRight,
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
          if (removed) {
            await DaoProductList(localDatabase).put(productList);
            _selectedBarcodes.remove(barcode);
            setState(() => barcodes.removeAt(index));
          }
          //ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                removed
                    ? appLocalizations.product_removed_history
                    : appLocalizations.product_could_not_remove,
              ),
              duration: SnackBarDuration.medium,
            ),
          );
          // TODO(monsieurtanuki): add a snackbar ("put back the food")
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
        ProductSearchQueryConfiguration(
          fields: ProductQuery.fields,
          language: ProductQuery.getLanguage(),
          country: ProductQuery.getCountry(),
          parametersList: <Parameter>[
            BarcodeParameter.list(barcodes),
          ],
          version: ProductQuery.productQueryVersion,
        ),
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

    if (selectedBarcodes.length < 2) {
      return const SizedBox.shrink();
    }

    return IconButton(
      icon: const Icon(Icons.compare_arrows),
      tooltip: appLocalizations.plural_compare_x_products(
        selectedBarcodes.length,
      ),
      onPressed: () async {
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
      },
    );
  }
}
