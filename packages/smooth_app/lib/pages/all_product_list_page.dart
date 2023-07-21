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
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page that lists all product lists.
class AllProductListPage extends StatelessWidget {
  const AllProductListPage();

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final List<ProductList> productLists = <ProductList>[
      ProductList.scanSession(),
      ProductList.scanHistory(),
      ProductList.history(),
    ];
    final List<String> userLists = daoProductList.getUserLists();
    for (final String userList in userLists) {
      productLists.add(ProductList.user(userList));
    }
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothScaffold(
      appBar: SmoothAppBar(title: Text(appLocalizations.product_list_select)),
      body: ListView.builder(
        itemCount: productLists.length,
        itemBuilder: (final BuildContext context, final int index) {
          final ProductList productList = productLists[index];
          return UserPreferencesListTile(
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
            onTap: () => Navigator.of(context).pop(productList),
            onLongPress: () async => ProductListUserDialogHelper(daoProductList)
                .showDeleteUserListDialog(context, productList),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async => ProductListUserDialogHelper(daoProductList)
            .showCreateUserListDialog(context),
        label: Row(
          children: <Widget>[
            const Icon(Icons.add),
            Text(appLocalizations.add_list_label),
          ],
        ),
      ),
    );
  }
}
