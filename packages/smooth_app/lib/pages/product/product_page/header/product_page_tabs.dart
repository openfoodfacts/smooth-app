import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/knowledge_panel/preview_knowledge_panels/environment_knowledge_panel.dart';
import 'package:smooth_app/knowledge_panel/preview_knowledge_panels/health_knowledge_panel.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_card.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/prices/prices_card.dart';
import 'package:smooth_app/pages/product/website_card.dart';
import 'package:smooth_app/widgets/smooth_tabbar.dart';

enum ProductPageHarcodedTabs {
  FOR_ME(key: 'for_me'),
  WEBSITE(key: 'website'),
  PRICES(key: 'prices'),
  FOLKSONOMY(key: 'folksonomy'),
  RAW_DATA(key: 'raw_data');

  const ProductPageHarcodedTabs({required this.key});

  final String key;
}

class ProductPageTab {
  const ProductPageTab({
    required this.id,
    this.indicatorColor,
    required this.labelBuilder,
    required this.builder,
  });

  final String id;
  final Color? indicatorColor;
  final String Function(BuildContext) labelBuilder;
  final Widget Function(BuildContext, Product) builder;
}

class ProductPageTabBar extends StatelessWidget {
  const ProductPageTabBar({
    required this.tabController,
    required this.tabs,
  });

  final TabController tabController;
  final List<ProductPageTab> tabs;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: _TabBarDelegate(
        PreferredSize(
          preferredSize: const Size.fromHeight(SmoothTabBar.TAB_BAR_HEIGHT),
          child: SmoothTabBar<ProductPageTab>(
            tabController: tabController,
            items: tabs.map((ProductPageTab tab) {
              return SmoothTabBarItem<ProductPageTab>(
                label: tab.labelBuilder(context),
                value: tab,
              );
            }).toList(growable: false),
            leadingItems: tabs.map(
              (ProductPageTab tab) {
                if (tab.indicatorColor == null) {
                  return null;
                }

                return Container(
                  width: 20.0,
                  height: 20.0,
                  margin:
                      const EdgeInsetsDirectional.only(end: VERY_SMALL_SPACE),
                  decoration: BoxDecoration(
                    color: tab.indicatorColor,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                );
              },
            ),
            onTabChanged: (_) {},
          ),
        ),
      ),
      pinned: true,
    );
  }

  static List<ProductPageTab> extractTabsFromProduct({
    required BuildContext context,
    required Product product,
  }) {
    final List<ProductPageTab> tabs = <ProductPageTab>[];

    final List<KnowledgePanelElement> roots =
        KnowledgePanelsBuilder.getRootPanelElements(product);
    for (final KnowledgePanelElement root in roots) {
      final String? id = root.panelElement?.panelId;
      if (id == null) {
        continue;
      }

      List<Widget> children = KnowledgePanelsBuilder.getChildren(
        context,
        panelElement: root,
        product: product,
        onboardingMode: false,
      );

      if (children.isEmpty) {
        continue;
      }

      final KnowledgePanelTitle knowledgePanelTitle =
          children.first as KnowledgePanelTitle;

      children = children.sublist(1);

      Color? indicatorColor;
      late Widget child;

      if (id == 'health_card') {
        indicatorColor = _getIndicatorColor(product.nutriscore);
        child = HealthKnowledgePanel(
          product: product,
          panels: children,
        );
      } else if (id == 'environment_card') {
        indicatorColor = _getIndicatorColor(product.ecoscoreGrade);
        child = EnvironmentKnowledgePanel(
          product: product,
          panels: children,
        );
      } else {
        child = ListView.builder(
          padding: EdgeInsetsDirectional.zero,
          itemCount: children.length,
          itemBuilder: (BuildContext context, int index) => children[index],
        );
      }

      tabs.add(
        ProductPageTab(
          id: id,
          indicatorColor: indicatorColor,
          labelBuilder: (_) => knowledgePanelTitle.title,
          builder: (_, __) => child,
        ),
      );
    }

    _addHardCodedTabs(context, product, tabs);

    final List<String> order = context.read<UserPreferences>().productPageTabs;

    if (order.isNotEmpty) {
      tabs.sort((ProductPageTab a, ProductPageTab b) {
        final int indexA = order.indexOf(a.id);
        final int indexB = order.indexOf(b.id);
        if (indexA < 0) {
          return 1;
        }
        if (indexB < 0) {
          return -1;
        }
        return indexA - indexB;
      });
    }

    return tabs;
  }

  static Color? _getIndicatorColor(String? grade) {
    switch (grade) {
      case 'a':
        return Colors.green;
      case 'b':
        return Colors.lightGreen;
      case 'c':
        return Colors.yellow;
      case 'd':
        return Colors.orange;
      case 'e':
        return Colors.red;
      default:
        return null;
    }
  }

  static List<ProductPageTab> _addHardCodedTabs(
    BuildContext context,
    Product product,
    List<ProductPageTab> tabs,
  ) {
    tabs.insert(
      0,
      ProductPageTab(
        id: ProductPageHarcodedTabs.FOR_ME.key,
        labelBuilder: (BuildContext context) =>
            AppLocalizations.of(context).product_page_tab_for_me,
        builder: (BuildContext context, __) => const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[],
        ),
      ),
    );
    if (product.website?.trim().isNotEmpty == true) {
      tabs.add(
        ProductPageTab(
          id: ProductPageHarcodedTabs.WEBSITE.key,
          labelBuilder: (BuildContext context) =>
              AppLocalizations.of(context).product_page_tab_website,
          builder: (_, Product product) => ListView(
            padding: EdgeInsetsDirectional.zero,
            children: <Widget>[
              WebsiteCard(product.website!),
            ],
          ),
        ),
      );
    }
    tabs.add(
      ProductPageTab(
        id: ProductPageHarcodedTabs.PRICES.key,
        labelBuilder: (BuildContext context) =>
            AppLocalizations.of(context).product_page_tab_prices,
        builder: (_, Product product) => ListView(
          padding: EdgeInsetsDirectional.zero,
          children: <Widget>[
            PricesCard(product),
          ],
        ),
      ),
    );

    if (context.read<UserPreferences>().getFlag(
            UserPreferencesDevMode.userPreferencesFlagHideFolksonomy) ==
        false) {
      tabs.add(
        ProductPageTab(
          id: ProductPageHarcodedTabs.FOLKSONOMY.key,
          labelBuilder: (BuildContext context) =>
              AppLocalizations.of(context).product_page_tab_folksonomy,
          builder: (_, Product product) => ListView(
            padding: EdgeInsetsDirectional.zero,
            children: <Widget>[FolksonomyCard(product)],
          ),
        ),
      );
    }

    return tabs;
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);

  final PreferredSizeWidget tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => minExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
