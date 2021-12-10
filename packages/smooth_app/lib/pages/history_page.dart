import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/product/common/product_list_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage();
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ProductList productList = ProductList.history();

  @protected
  @mustCallSuper
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    DaoProductList(context.watch<LocalDatabase>()).get(productList).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProductListPage(productList);
  }
}
