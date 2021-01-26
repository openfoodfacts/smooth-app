import 'package:flutter/material.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/pages/product_query_page_helper.dart';
import 'package:smooth_app/pages/product_list_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_alert_dialog.dart';

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lists',
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
        ),
      ),
      body: FutureBuilder<List<ProductList>>(
          future: daoProductList.getAll(),
          builder: (
            final BuildContext context,
            final AsyncSnapshot<List<ProductList>> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.done) {
              final List<ProductList> list = snapshot.data;
              if (list != null) {
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (final BuildContext context, final int index) {
                    final ProductList item = list[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          ProductQueryPageHelper.getProductListLabel(item),
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        subtitle: Text(
                          '${ProductQueryPageHelper.getDurationStringFromTimestamp(item.databaseTimestamp)}, '
                          '${ProductQueryPageHelper.getProductCount(item)}',
                        ),
                        onTap: () {
                          Navigator.push<dynamic>(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (BuildContext context) =>
                                  ProductListPage(
                                item,
                                reverse: _isListReversed(item),
                              ),
                            ),
                          );
                        },
                        onLongPress: () {
                          showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return SmoothAlertDialog(
                                //title: AppLocalizations.of(context).contribute_translate_header,
                                body: const Text(
                                    'Do you want to delete this product list?'),
                                actions: <SmoothSimpleButton>[
                                  SmoothSimpleButton(
                                    onPressed: () => Navigator.pop(context),
                                    text: AppLocalizations.of(context).no,
                                    width: 100,
                                  ),
                                  SmoothSimpleButton(
                                    onPressed: () async {
                                      await daoProductList.delete(item);
                                      Navigator.pop(context);
                                      setState(() {});
                                    },
                                    text: AppLocalizations.of(context).yes,
                                    width: 100,
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              }
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }

  bool _isListReversed(final ProductList productList) =>
      productList.listType == ProductList.LIST_TYPE_HISTORY ||
      productList.listType == ProductList.LIST_TYPE_SCAN;
}
