import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
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
              UserPreferencesListTile(
                title: Text(
                  ProductQueryPageHelper.getProductListLabel(
                    productList,
                    appLocalizations,
                  ),
                ),
                subtitle: FutureBuilder<int>(
                  future: daoProductList.getLength(productList),
                  builder: (
                    final BuildContext context,
                    final AsyncSnapshot<int> snapshot,
                  ) {
                    if (snapshot.data != null) {
                      return Text(
                        appLocalizations.user_list_length(snapshot.data!),
                      );
                    }
                    return EMPTY_WIDGET;
                  },
                ),
                trailing: productList.isEditable
                    ? PopupMenuButton<PopupMenuEntries>(
                        itemBuilder: (BuildContext context) {
                          return <PopupMenuEntry<PopupMenuEntries>>[
                            PopupMenuItem<PopupMenuEntries>(
                                value: PopupMenuEntries.deleteList,
                                child: ListTile(
                                  leading: const Icon(Icons.delete),
                                  title:
                                      Text(appLocalizations.action_delete_list),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onTap: () {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    ProductListUserDialogHelper(daoProductList)
                                        .showDeleteUserListDialog(
                                            context, productList);
                                  });
                                })
                          ];
                        },
                        icon: const Icon(Icons.more_vert),
                      )
                    : null,
                selected: productList.listType == currentList.listType &&
                    productList.parameters == currentList.parameters,
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                onTap: () => Navigator.of(context).pop(productList),
              ),
              if (index < productLists.length - 1) const Divider(height: 1.0),
            ],
          );
        },
      ),
    );
  }
}

enum PopupMenuEntries { deleteList }
