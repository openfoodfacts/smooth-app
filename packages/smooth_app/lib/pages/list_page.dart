// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:smooth_ui_library/widgets/smooth_card.dart';

// Project imports:
import 'package:smooth_app/cards/product_cards/product_list_preview.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/product/common/product_list_dialog_helper.dart';
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

  static String getCreateListLabel() => 'Create a food list';
}

class _ListPageState extends State<ListPage> {
  List<ProductList> _list;

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final Size screenSize = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);
    final double iconSize = screenSize.width / 10;
    final bool mayAddList =
        widget.typeFilter.contains(ProductList.LIST_TYPE_USER_DEFINED);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          if (mayAddList)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async => await _add(daoProductList),
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
                  if (mayAddList) {
                    return Center(
                      child: _addButtonWhenEmpty(
                        iconSize,
                        themeData,
                        daoProductList,
                      ),
                    );
                  }
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

  Future<void> _add(final DaoProductList daoProductList) async {
    final ProductList newProductList = await ProductListDialogHelper.openNew(
      context,
      daoProductList,
      _list,
    );
    if (newProductList == null) {
      return;
    }
    setState(() {});
  }

  Widget _addButtonWhenEmpty(
    final double iconSize,
    final ThemeData themeData,
    final DaoProductList daoProductList,
  ) =>
      SmoothCard(
        color: SmoothTheme.getColor(
          themeData.colorScheme,
          Colors.blue,
          ColorDestination.SURFACE_BACKGROUND,
        ),
        child: ListTile(
          leading: Icon(Icons.add, size: iconSize),
          onTap: () async => await _add(daoProductList),
          title: Text(
            ListPage.getCreateListLabel(),
            style: themeData.textTheme.headline3,
          ),
        ),
      );
}
