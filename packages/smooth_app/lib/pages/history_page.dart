import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/product/common/product_list_widget.dart';
import 'package:smooth_app/pages/smooth_bottom_navigation_bar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage();
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ProductList productList = ProductList(
    listType: ProductList.LIST_TYPE_HISTORY,
    parameters: '',
  );

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
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(appLocalizations.history),
      ),
      body: ProductListWidget(productList),
      bottomNavigationBar: SmoothBottomNavigationBar(
        tab: SmoothBottomNavigationTab.History,
      ),
    );
  }
}
