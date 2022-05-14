import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
import 'package:smooth_app/pages/product/common/product_list_page.dart';
import 'package:smooth_app/pages/product_list_user_dialog_helper.dart';
import 'package:smooth_app/themes/constant_icons.dart';

/// Page that lists all user product lists.
class AllUserProductList extends StatefulWidget {
  const AllUserProductList();

  @override
  State<AllUserProductList> createState() => _AllUserProductListState();
}

class _AllUserProductListState extends State<AllUserProductList> {
  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final ThemeData themeData = Theme.of(context);
    final List<String> userLists = daoProductList.getUserLists();
    return Scaffold(
      appBar: AppBar(title: const Text('Lists')),
      body: userLists.isEmpty
          ? const Center(child: Text('No user list'))
          : ListView.builder(
              itemCount: userLists.length,
              itemBuilder: (final BuildContext context, final int index) {
                final String userList = userLists[index];
                final ProductList productList = ProductList.user(userList);
                final int length = daoProductList.getLength(productList);
                return UserPreferencesListTile(
                  title: Text(
                    userList,
                    style: themeData.textTheme.headline4,
                  ),
                  subtitle: Text('$length product(s)'),
                  icon: Icon(ConstantIcons.instance.getForwardIcon()),
                  onTap: () async {
                    await daoProductList.get(productList);
                    if (!mounted) {
                      return;
                    }
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            ProductListPage(productList),
                      ),
                    );
                    setState(() {});
                  },
                  onLongPress: () async {
                    final ProductList productList = ProductList.user(userList);
                    final bool deleted =
                        await ProductListUserDialogHelper(daoProductList)
                            .showDeleteUserListDialog(context, productList);
                    if (!deleted) {
                      return;
                    }
                    setState(() {});
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final ProductList? newProductList =
              await ProductListUserDialogHelper(daoProductList)
                  .showCreateUserListDialog(context);
          if (newProductList == null) {
            return;
          }
          setState(() {});
        },
      ),
    );
  }
}
