import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/up_to_date_product_list_mixin.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_app_logo.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_responsive.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/helpers/robotoff_insight_helper.dart';
import 'package:smooth_app/pages/all_product_list_modal.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/product/common/product_list_item_popup_items.dart';
import 'package:smooth_app/pages/product/common/product_list_item_simple.dart';
import 'package:smooth_app/pages/product/common/product_list_popup_items.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product_list_user_dialog_helper.dart';
import 'package:smooth_app/pages/scan/carousel/scan_carousel_manager.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/query/search_products_manager.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_menu_button.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/will_pop_scope.dart';

/// Displays the products of a product list, with access to other lists.
class ProductListPage extends StatefulWidget {
  const ProductListPage(
    this.productList, {
    this.allowToSwitchBetweenLists = true,
  });

  final ProductList productList;
  final bool allowToSwitchBetweenLists;

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage>
    with TraceableClientMixin, UpToDateProductListMixin {
  final Set<String> _selectedBarcodes = <String>{};
  bool _selectionMode = false;

  @override
  String get actionName => 'Opened list_page';

  @override
  void initState() {
    super.initState();
    initUpToDate(widget.productList, context.read<LocalDatabase>());
  }

  final ProductListPopupItem _rename = ProductListPopupRename();
  final ProductListPopupItem _clear = ProductListPopupClear();
  final ProductListPopupItem _openInWeb = ProductListPopupOpenInWeb();
  final ProductListPopupItem _share = ProductListPopupShare();
  final ProductListItemPopupItem _deleteItems = ProductListItemPopupDelete();
  final ProductListItemPopupItem _rankItems = ProductListItemPopupRank();
  final ProductListItemPopupItem _sideBySideItems =
      ProductListItemPopupSideBySide();

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
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    refreshUpToDate();

    /// If we were on a user list, but it has been deleted, we switch to history
    if (!daoProductList.exist(productList) &&
        productList.listType == ProductListType.USER) {
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(
            () => productList = ProductList.history(),
          ));

      return EMPTY_WIDGET;
    }

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

    return SmoothSharedAnimationController(
      child: SmoothScaffold(
        floatingActionButton: products.isEmpty
            ? FloatingActionButton.extended(
                icon: const Icon(CupertinoIcons.barcode),
                label: Text(appLocalizations.product_list_empty_title),
                onPressed: () =>
                    ExternalScanCarouselManager.read(context).showSearchCard(),
              )
            : _selectionMode
                ? null
                : FloatingActionButton.extended(
                    onPressed: () => setState(() => _selectionMode = true),
                    label: const Text('Multi-select'),
                    icon: const Icon(Icons.checklist),
                  ),
        appBar: SmoothAppBar(
          centerTitle: false,
          actions: <Widget>[
            SmoothPopupMenuButton<ProductListPopupItem>(
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
              itemBuilder: (_) => <SmoothPopupMenuItem<ProductListPopupItem>>[
                if (enableRename) _rename.getMenuItem(appLocalizations),
                _share.getMenuItem(appLocalizations),
                _openInWeb.getMenuItem(appLocalizations),
                if (enableClear) _clear.getMenuItem(appLocalizations),
              ],
            ),
          ],
          title: _ProductListAppBarTitle(
            productList: productList,
            onTap: () => _onChangeList(appLocalizations, daoProductList),
            enabled: widget.allowToSwitchBetweenLists,
          ),
          titleSpacing: 0.0,
          actionMode: _selectionMode,
          onLeaveActionMode: () {
            setState(() => _selectionMode = false);
          },
          actionModeTitle: Text('${_selectedBarcodes.length}'),
          actionModeActions: <Widget>[
            SmoothPopupMenuButton<ProductListItemPopupItem>(
              onSelected: (final ProductListItemPopupItem action) async {
                final bool andThenSetState = await action.doSomething(
                  productList: productList,
                  localDatabase: localDatabase,
                  context: context,
                  selectedBarcodes: _selectedBarcodes,
                );
                if (andThenSetState) {
                  if (context.mounted) {
                    setState(() {});
                  }
                }
              },
              itemBuilder: (_) =>
                  <SmoothPopupMenuItem<ProductListItemPopupItem>>[
                if (userPreferences.getFlag(UserPreferencesDevMode
                        .userPreferencesFlagBoostedComparison) ==
                    true)
                  _sideBySideItems.getMenuItem(
                    appLocalizations,
                    _selectedBarcodes.length >= 2 &&
                        _selectedBarcodes.length <= 3,
                  ),
                _rankItems.getMenuItem(
                  appLocalizations,
                  _selectedBarcodes.length >= 2,
                ),
                _deleteItems.getMenuItem(
                  appLocalizations,
                  _selectedBarcodes.isNotEmpty,
                ),
              ],
            ),
          ],
        ),
        body: products.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(SMALL_SPACE),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      SvgPicture.asset(
                        'assets/misc/empty-list.svg',
                        package: AppHelper.APP_PACKAGE,
                        width: MediaQuery.sizeOf(context).width / 2,
                      ),
                      Text(
                        appLocalizations.product_list_empty_message,
                        textAlign: TextAlign.center,
                        style: themeData.textTheme.bodyMedium?.apply(
                          color: themeData.colorScheme.onSurface,
                        ),
                      ),
                      EMPTY_WIDGET,
                    ],
                  ),
                ),
              )
            : WillPopScope2(
                onWillPop: () async => (await _handleUserBacktap(), null),
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
                    itemBuilder: (BuildContext context, int index) =>
                        _buildItem(
                      dismissible,
                      products,
                      index,
                      localDatabase,
                      appLocalizations,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  double _computeModalInitHeight(BuildContext context) {
    if (context.isSmallDevice()) {
      return 0.7;
    } else if (context.isSmartphoneDevice()) {
      return 0.55;
    } else {
      return 0.45;
    }
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
                    ? () => setState(
                          () {
                            _selectedBarcodes.add(barcode);
                            _selectionMode = true;
                          },
                        )
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

            if (productList.listType == ProductListType.SCAN_SESSION &&
                mounted) {
              context.read<ContinuousScanModel>().removeBarcode(barcode);
            }

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
        if (mounted) {
          LoadingDialog.error(context: context);
        }
        return;
    }
  }

  /// Fetches the products from the API and refreshes the local database
  Future<bool> _reloadProducts(
    final List<String> barcodes,
    final LocalDatabase localDatabase,
  ) async {
    bool fresh = true;
    try {
      final OpenFoodFactsLanguage language = ProductQuery.getLanguage();
      final Map<ProductType, List<String>> productTypes =
          await DaoProduct(localDatabase).getProductTypes(barcodes);
      for (final MapEntry<ProductType, List<String>> entry
          in productTypes.entries) {
        final SearchResult searchResult =
            await SearchProductsManager.searchProducts(
          ProductQuery.getReadUser(),
          ProductRefresher().getBarcodeListQueryConfiguration(
            entry.value,
            language,
          ),
          uriHelper: ProductQuery.getUriProductHelper(productType: entry.key),
          type: SearchProductsType.live,
        );
        final List<Product>? freshProducts = searchResult.products;
        if (freshProducts == null) {
          fresh = false;
        } else {
          await DaoProduct(localDatabase).putAll(
            freshProducts,
            language,
            productType: entry.key,
          );
          localDatabase.upToDate.setLatestDownloadedProducts(freshProducts);
        }
      }
      final RobotoffInsightHelper robotoffInsightHelper =
          RobotoffInsightHelper(localDatabase);
      await robotoffInsightHelper.clearInsightAnnotationsSaved();
      return fresh;
    } catch (e) {
      //
    }
    return false;
  }

  Future<void> _onChangeList(
    AppLocalizations appLocalizations,
    DaoProductList daoProductList,
  ) async {
    final ProductList? selected =
        await showSmoothDraggableModalSheet<ProductList>(
      context: context,
      header: SmoothModalSheetHeader(
        title: appLocalizations.product_list_select,
        suffix: SmoothModalSheetHeaderButton(
          label: appLocalizations.product_list_create,
          prefix: const Icon(Icons.add_circle_outline_sharp),
          tooltip: appLocalizations.product_list_create_tooltip,
          onTap: () async => ProductListUserDialogHelper(daoProductList)
              .showCreateUserListDialog(context),
        ),
      ),
      bodyBuilder: (BuildContext context) => AllProductListModal(
        currentList: productList,
      ),
      initHeight: _computeModalInitHeight(context),
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
  }
}

class _ProductListAppBarTitle extends StatelessWidget {
  const _ProductListAppBarTitle({
    required this.productList,
    required this.onTap,
    required this.enabled,
  });

  final ProductList productList;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String title = ProductQueryPageHelper.getProductListLabel(
      productList,
      appLocalizations,
    );

    return Semantics(
      label: enabled ? appLocalizations.action_change_list : null,
      value: title,
      button: enabled,
      excludeSemantics: true,
      child: SizedBox(
        height: kToolbarHeight,
        child: InkWell(
          borderRadius: context.read<ThemeProvider>().isAmoledTheme
              ? ANGULAR_BORDER_RADIUS
              : null,
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: NavigationToolbar.kMiddleSpacing,
            ),
            child: LayoutBuilder(
              builder: (_, BoxConstraints constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.9 -
                            (enabled ? (MEDIUM_SPACE - 15.0) : 0),
                      ),
                      child: AutoSizeText(
                        title,
                        maxLines: 2,
                      ),
                    ),
                    if (enabled) ...<Widget>[
                      const SizedBox(width: MEDIUM_SPACE),
                      icons.AppIconTheme(
                        semanticLabel: appLocalizations.action_change_list,
                        size: 15.0,
                        child: const icons.Chevron.down(),
                      )
                    ]
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
