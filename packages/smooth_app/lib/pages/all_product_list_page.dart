import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
import 'package:smooth_app/pages/product/common/product_list_popup_items.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/product_list_user_dialog_helper.dart';

/// Page that lists all product lists.
class AllProductListModal extends StatelessWidget {
  AllProductListModal({
    required this.currentList,
  });

  final ProductList currentList;

  final List<ProductList> hardcodedProductLists = <ProductList>[
    ProductList.scanSession(),
    ProductList.scanHistory(),
    ProductList.history(),
  ];

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);

    final List<String> userLists = daoProductList.getUserLists();
    final List<ProductList> productLists =
        List<ProductList>.from(hardcodedProductLists);
    for (final String userList in userLists) {
      productLists.add(ProductList.user(userList));
    }
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: productLists.length,
        (final BuildContext context, final int index) {
          final ProductList productList = productLists[index];
          return Column(
            children: <Widget>[
              FutureBuilder<int>(
                future: daoProductList.getLength(productList),
                builder: (
                  final BuildContext context,
                  final AsyncSnapshot<int> snapshot,
                ) {
                  final int productsLength = snapshot.data ?? 0;

                  return UserPreferencesListTile(
                    title: Text(
                      ProductQueryPageHelper.getProductListLabel(
                        productList,
                        appLocalizations,
                      ),
                    ),
                    subtitle: Text(
                      appLocalizations.user_list_length(productsLength),
                    ),
                    trailing: PopupMenuButton<PopupMenuEntries>(
                      itemBuilder: (BuildContext context) {
                        return <PopupMenuEntry<PopupMenuEntries>>[
                          _shareMenu(
                            appLocalizations,
                            daoProductList,
                            localDatabase,
                            context,
                            productList,
                          ),
                          _openInWebMenu(
                            appLocalizations,
                            daoProductList,
                            localDatabase,
                            context,
                            productList,
                          ),
                          if (productsLength > 0)
                            _clearListMenu(
                              appLocalizations,
                              daoProductList,
                              localDatabase,
                              context,
                              productList,
                            ),
                          if (productList.isEditable)
                            _deleteListMenu(
                              appLocalizations,
                              daoProductList,
                              context,
                              productList,
                            ),
                        ];
                      },
                      icon: const Icon(Icons.more_vert),
                    ),
                    selected: productList.listType == currentList.listType &&
                        productList.parameters == currentList.parameters,
                    selectedColor:
                        Theme.of(context).primaryColor.withOpacity(0.2),
                    contentPadding: const EdgeInsetsDirectional.only(
                      start: VERY_LARGE_SPACE,
                      end: LARGE_SPACE,
                      top: VERY_SMALL_SPACE,
                      bottom: VERY_SMALL_SPACE,
                    ),
                    onTap: () => Navigator.of(context).pop(productList),
                  );
                },
              ),
              if (index < productLists.length - 1) const Divider(height: 1.0),
            ],
          );
        },
      ),
    );
  }

  PopupMenuItem<PopupMenuEntries> _shareMenu(
    AppLocalizations appLocalizations,
    DaoProductList daoProductList,
    LocalDatabase localDatabase,
    BuildContext context,
    ProductList productList,
  ) {
    final ProductListPopupShare popupShare = ProductListPopupShare();
    return PopupMenuItem<PopupMenuEntries>(
      value: PopupMenuEntries.shareList,
      child: ListTile(
        leading: const Icon(Icons.share),
        title: Text(popupShare.getTitle(appLocalizations)),
        contentPadding: EdgeInsets.zero,
        onTap: () {
          Navigator.of(context).pop();
          popupShare.doSomething(
            productList: productList,
            localDatabase: localDatabase,
            context: context,
          );
        },
      ),
    );
  }

  PopupMenuItem<PopupMenuEntries> _openInWebMenu(
    AppLocalizations appLocalizations,
    DaoProductList daoProductList,
    LocalDatabase localDatabase,
    BuildContext context,
    ProductList productList,
  ) {
    final ProductListPopupOpenInWeb webItem = ProductListPopupOpenInWeb();
    return PopupMenuItem<PopupMenuEntries>(
      value: PopupMenuEntries.openListInBrowser,
      child: ListTile(
        leading: const Icon(Icons.public),
        title: Text(webItem.getTitle(appLocalizations)),
        contentPadding: EdgeInsets.zero,
        onTap: () {
          Navigator.of(context).pop();
          webItem.doSomething(
            productList: productList,
            localDatabase: localDatabase,
            context: context,
          );
        },
      ),
    );
  }

  PopupMenuItem<PopupMenuEntries> _clearListMenu(
    AppLocalizations appLocalizations,
    DaoProductList daoProductList,
    LocalDatabase localDatabase,
    BuildContext context,
    ProductList productList,
  ) {
    final ProductListPopupClear clearItem = ProductListPopupClear();
    return PopupMenuItem<PopupMenuEntries>(
      value: PopupMenuEntries.clearList,
      child: ListTile(
        leading: const Icon(Icons.delete_sweep),
        title: Text(clearItem.getTitle(appLocalizations)),
        contentPadding: EdgeInsets.zero,
        onTap: () async {
          Navigator.of(context).pop();

          clearItem.doSomething(
            productList: productList,
            localDatabase: localDatabase,
            context: context,
          );
        },
      ),
    );
  }

  PopupMenuItem<PopupMenuEntries> _deleteListMenu(
    AppLocalizations appLocalizations,
    DaoProductList daoProductList,
    BuildContext context,
    ProductList productList,
  ) {
    return PopupMenuItem<PopupMenuEntries>(
        value: PopupMenuEntries.deleteList,
        child: ListTile(
          leading: const Icon(Icons.delete),
          title: Text(appLocalizations.action_delete_list),
          contentPadding: EdgeInsets.zero,
        ),
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ProductListUserDialogHelper(daoProductList)
                .showDeleteUserListDialog(context, productList);
          });
        });
  }
}

enum PopupMenuEntries {
  shareList,
  openListInBrowser,
  renameList,
  clearList,
  deleteList,
}
