import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/product/product_page/header/product_page_tabs.dart';

class ProductPageTabController extends StatefulWidget {
  const ProductPageTabController({
    required this.product,
    required this.childBuilder,
  });

  final Product product;
  final Widget Function(List<ProductPageTab> tabs, TabController tabController)
  childBuilder;

  @override
  State<ProductPageTabController> createState() =>
      _ProductPageTabControllerState();
}

class _ProductPageTabControllerState extends State<ProductPageTabController>
    with TickerProviderStateMixin {
  late List<ProductPageTab> _tabs;
  late TabController _tabController;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _tabs = const ProductPageTabsGenerator().getTabs(context, widget.product);
      _tabController = TabController(
        length: _tabs.length,
        vsync: this,
        initialIndex: 1,
      );
      _isInitialized = true;
    }
  }

  @override
  void didUpdateWidget(covariant ProductPageTabController oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.product != oldWidget.product) {
      setState(() {
        final List<ProductPageTab> newTabs = const ProductPageTabsGenerator()
            .getTabs(context, widget.product);

        final int oldIndex = _tabController.index;
        _tabController.dispose();

        _tabs = newTabs;
        _tabController = TabController(
          length: _tabs.length,
          vsync: this,
          initialIndex: oldIndex < _tabs.length ? oldIndex : 0,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.childBuilder(_tabs, _tabController);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
