import 'package:flutter/cupertino.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<ProductList> _list;
  ProductList _newProductList;

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
              onPressed: () => showDialog<void>(
                context: context,
                // TODO(monsieurtanuki): rename list, delete list
                builder: (BuildContext context) => SmoothAlertDialog(
                  title: 'New list',
                  body: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'My new custom list',
                            ),
                            validator: (final String value) {
                              if (value.isEmpty) {
                                return 'Please enter some text';
                              }
                              if (_list == null) {
                                return null;
                              }
                              _newProductList = ProductList(
                                listType: ProductList.LIST_TYPE_USER_DEFINED,
                                parameters: value,
                              );
                              for (final ProductList productList in _list) {
                                if (productList.lousyKey ==
                                    _newProductList.lousyKey) {
                                  return 'There\'s already a list with that name';
                                }
                              }
                              return null;
                            }),
                      ],
                    ),
                  ),
                  actions: <SmoothSimpleButton>[
                    SmoothSimpleButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      important: false,
                    ),
                    SmoothSimpleButton(
                      text: 'OK',
                      onPressed: () async {
                        if (!_formKey.currentState.validate()) {
                          return;
                        }
                        if (await daoProductList.get(_newProductList)) {
                          // TODO(monsieurtanuki): unexpected, but do something!
                          return;
                        }
                        await daoProductList.put(_newProductList);
                        Navigator.pop(context);
                        setState(() {});
                      },
                      important: true,
                    ),
                  ],
                ),
              ),
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
                      child: ListTile(
                        title: Text(
                          ProductQueryPageHelper.getProductListLabel(item),
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
                                    important: false,
                                  ),
                                  SmoothSimpleButton(
                                    onPressed: () async {
                                      await daoProductList.delete(item);
                                      Navigator.pop(context);
                                      setState(() {});
                                    },
                                    text: AppLocalizations.of(context).yes,
                                    important: true,
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
