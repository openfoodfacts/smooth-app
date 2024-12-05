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
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

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

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: productLists.length,
        (final BuildContext context, final int index) {
          final ProductList productList = productLists[index];
          return Column(
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: double.infinity,
                  minHeight: MediaQuery.textScalerOf(context).scale(80.0),
                ),
                child: FutureBuilder<void>(
                  future: daoProductList.get(productList),
                  builder:
                      (BuildContext context, AsyncSnapshot<void> snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }
                    return _ModalProductListItem(
                      productList: productList,
                      selected: productList.listType == currentList.listType &&
                          productList.parameters == currentList.parameters,
                    );
                  },
                ),
              ),
              if (index < productLists.length - 1) const Divider(height: 1.0),
            ],
          );
        },
      ),
    );
  }
}

class _ModalProductListItem extends StatelessWidget {
  const _ModalProductListItem({
    required this.productList,
    required this.selected,
  });

  final ProductList productList;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final LocalDatabase localDatabase = context.watch<LocalDatabase>();

    final int productsLength = productList.barcodes.length;
    final bool enableRename = productList.listType == ProductListType.USER;
    final bool hasProducts = productsLength > 0;

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
      trailing: (enableRename || hasProducts || productList.isEditable)
          ? PopupMenuButton<ProductListPopupMenuEntry>(
              itemBuilder: (BuildContext context) {
                final List<ProductListPopupItem> list = <ProductListPopupItem>[
                  if (enableRename) ProductListPopupRename(),
                  if (hasProducts) ProductListPopupShare(),
                  if (hasProducts) ProductListPopupOpenInWeb(),
                  if (hasProducts) ProductListPopupClear(),
                  if (productList.isEditable) ProductListPopupDelete(),
                ];
                final List<PopupMenuEntry<ProductListPopupMenuEntry>> result =
                    <PopupMenuEntry<ProductListPopupMenuEntry>>[];
                for (final ProductListPopupItem item in list) {
                  result.add(
                    PopupMenuItem<ProductListPopupMenuEntry>(
                      value: item.getEntry(),
                      child: ListTile(
                        leading: Icon(item.getIconData()),
                        title: Text(item.getTitle(appLocalizations)),
                        contentPadding: EdgeInsetsDirectional.zero,
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
            )
          : null,
      selected: selected,
      selectedColor:
          lightTheme ? extension.primaryMedium : extension.primarySemiDark,
      contentPadding: const EdgeInsetsDirectional.only(
        start: VERY_LARGE_SPACE,
        end: LARGE_SPACE,
        top: VERY_SMALL_SPACE,
        bottom: VERY_SMALL_SPACE,
      ),
      onTap: () => Navigator.of(context).pop(productList),
    );
  }
}
