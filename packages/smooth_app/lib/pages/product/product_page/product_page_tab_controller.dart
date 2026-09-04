import 'package:flutter/foundation.dart';
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
        initialIndex: 0,
      );
      _isInitialized = true;
    }
  }

  @override
  void didUpdateWidget(covariant ProductPageTabController oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.product == oldWidget.product) {
      return;
    }

    // `Product` has no value equality, so the check above triggers on every
    // rebuild that hands us a new (even data-identical) `Product` instance.
    // We must not treat that alone as a reason to recreate the
    // `TabController`: doing so replaces the `TabBarView`'s controller
    // identity, which makes it jump back to the committed tab and can abort
    // an in-progress swipe gesture (see #7698). Only recreate the
    // `TabController` when the ordered tab structure actually changed.
    final List<ProductPageTab> newTabs = const ProductPageTabsGenerator()
        .getTabs(context, widget.product);

    final bool sameTabStructure = listEquals(
      _tabs.map((ProductPageTab tab) => tab.id).toList(growable: false),
      newTabs.map((ProductPageTab tab) => tab.id).toList(growable: false),
    );

    setState(() {
      _tabs = newTabs;

      if (!sameTabStructure) {
        final int oldIndex = _tabController.index;
        _tabController.dispose();
        _tabController = TabController(
          length: _tabs.length,
          vsync: this,
          initialIndex: oldIndex < _tabs.length ? oldIndex : 0,
        );
      }
    });
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
