import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/pages/product_query_page_helper.dart';
import 'package:smooth_app/pages/product_list_dialog_helper.dart';
import 'package:smooth_app/pages/product_list_page.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

class ListPage extends StatefulWidget {
  const ListPage({
    this.title,
    this.typeFilter,
  });

  final String title;
  final List<String> typeFilter;

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<ProductList> _list;

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: colorScheme.onBackground),
        ),
        iconTheme: IconThemeData(color: colorScheme.onBackground),
        actions: <Widget>[
          if (widget.typeFilter.contains(ProductList.LIST_TYPE_USER_DEFINED))
            IconButton(
              icon: Icon(Icons.add, color: colorScheme.onBackground),
              onPressed: () async {
                if (await ProductListDialogHelper.openNew(
                    context, daoProductList, _list)) {
                  setState(() {});
                }
              },
            )
        ],
      ),
      body: FutureBuilder<List<ProductList>>(
          future: daoProductList.getAll(typeFilter: widget.typeFilter),
          builder: (
            final BuildContext context,
            final AsyncSnapshot<List<ProductList>> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.done) {
              _list = snapshot.data;
              if (_list != null) {
                if (_list.isEmpty) {
                  return const Center(child: Text('No list so far'));
                }
                return ListView.builder(
                  itemCount: _list.length,
                  itemBuilder: (final BuildContext context, final int index) {
                    final ProductList item = _list[index];
                    return Card(
                      color: SmoothTheme.getBackgroundColor(
                        colorScheme,
                        item.getMaterialColor(),
                      ),
                      child: ListTile(
                        leading: item.getIcon(colorScheme),
                        title: Text(
                          ProductQueryPageHelper.getProductListLabel(
                            item,
                            verbose: false,
                          ),
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        subtitle: Text(
                          '${ProductQueryPageHelper.getDurationStringFromTimestamp(item.databaseTimestamp)}, '
                          '${ProductQueryPageHelper.getProductCount(item)}',
                        ),
                        onTap: () async {
                          await daoProductList.get(item);
                          await Navigator.push<dynamic>(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (BuildContext context) =>
                                  ProductListPage(
                                item,
                                reverse: _isListReversed(item),
                              ),
                            ),
                          );
                          localDatabase.notifyListeners();
                        },
                        onLongPress: () async {
                          if (await ProductListDialogHelper.openDelete(
                              context, daoProductList, item)) {
                            setState(() {});
                          }
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
