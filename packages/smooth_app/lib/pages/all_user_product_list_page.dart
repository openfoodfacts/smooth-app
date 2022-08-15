import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
import 'package:smooth_app/pages/product/common/product_list_page.dart';
import 'package:smooth_app/pages/product_list_user_dialog_helper.dart';
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page that lists all user product lists.
class AllUserProductList extends StatelessWidget {
  const AllUserProductList();

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    return FutureBuilder<List<String>>(
      future: daoProductList.getUserLists(),
      builder: (
        final BuildContext context,
        final AsyncSnapshot<List<String>> snapshot,
      ) {
        if (snapshot.data != null) {
          return _AllUserProductListLoaded(snapshot.data!);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

/// Page that lists all user product lists, with already loaded data.
class _AllUserProductListLoaded extends StatefulWidget {
  const _AllUserProductListLoaded(this.userLists);

  final List<String> userLists;

  @override
  State<_AllUserProductListLoaded> createState() =>
      _AllUserProductListLoadedState();
}

class _AllUserProductListLoadedState extends State<_AllUserProductListLoaded> {
  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    final List<String> userLists = widget.userLists;
    return SmoothScaffold(
      appBar: AppBar(title: Text(appLocalizations.user_list_all_title)),
      body: userLists.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/misc/empty-list.svg',
                    height: MediaQuery.of(context).size.height * .4,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(SMALL_SPACE),
                    child: AutoSizeText(
                      appLocalizations.user_list_all_empty,
                      style: themeData.textTheme.headline1,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: userLists.length,
              itemBuilder: (final BuildContext context, final int index) {
                final String userList = userLists[index];
                final ProductList productList = ProductList.user(userList);
                return UserPreferencesListTile(
                  title: Text(userList),
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
                  trailing: Icon(ConstantIcons.instance.getForwardIcon()),
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
                  onLongPress: () async =>
                      ProductListUserDialogHelper(daoProductList)
                          .showDeleteUserListDialog(
                    context,
                    ProductList.user(userList),
                  ),
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
