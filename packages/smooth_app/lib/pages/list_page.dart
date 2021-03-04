import 'package:flutter/material.dart';
import 'package:smooth_app/cards/product_cards/product_list_preview.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/pages/product_list_dialog_helper.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          if (widget.typeFilter.contains(ProductList.LIST_TYPE_USER_DEFINED))
            IconButton(
              icon: const Icon(Icons.add),
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
                    return ProductListPreview(
                      daoProductList: daoProductList,
                      productList: item,
                      nbInPreview: 5,
                    );
                  },
                );
              }
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}
