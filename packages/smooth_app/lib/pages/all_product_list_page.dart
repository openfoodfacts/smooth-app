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

/// Page that lists all product lists.
class AllProductListModal extends StatelessWidget {
  AllProductListModal({
    required this.currentList,
  });

  final ProductList currentList;

  final List<ProductList> _hardcodedProductLists = <ProductList>[
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
        List<ProductList>.from(_hardcodedProductLists);
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
                    trailing: PopupMenuButton<ProductListPopupMenuEntry>(
                      itemBuilder: (BuildContext context) {
                        final bool enableRename =
                            productList.listType == ProductListType.USER;
                        final List<ProductListPopupItem> list =
                            <ProductListPopupItem>[
                          if (enableRename) ProductListPopupRename(),
                          ProductListPopupShare(),
                          ProductListPopupOpenInWeb(),
                          if (productsLength > 0) ProductListPopupClear(),
                          if (productList.isEditable) ProductListPopupDelete(),
                        ];
                        final List<PopupMenuEntry<ProductListPopupMenuEntry>>
                            result =
                            <PopupMenuEntry<ProductListPopupMenuEntry>>[];
                        for (final ProductListPopupItem item in list) {
                          result.add(
                            PopupMenuItem<ProductListPopupMenuEntry>(
                              value: item.getEntry(),
                              child: ListTile(
                                leading: Icon(item.getIconData()),
                                title: Text(item.getTitle(appLocalizations)),
                                contentPadding: EdgeInsets.zero,
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  await item.doSomething(
                                    productList: productList,
                                    localDatabase: localDatabase,
                                    context: context,
                                  );
                                },
                              ),
                            ),
                          );
                        }
                        return result;
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
}
