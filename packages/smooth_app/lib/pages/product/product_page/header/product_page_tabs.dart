import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_card.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/prices/prices_card.dart';
import 'package:smooth_app/pages/product/website_card.dart';
import 'package:smooth_app/widgets/smooth_tabbar.dart';

class ProductPageTab {
  const ProductPageTab({
    required this.id,
    required this.labelBuilder,
    required this.builder,
  });

  final String id;
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
              onTabChanged: (_) {},
            )),
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

      final KnowledgePanelTitle knowledgePanelTitle =
          children.first as KnowledgePanelTitle;

      children = children.sublist(1);

      tabs.add(
        ProductPageTab(
          id: id,
          labelBuilder: (_) => knowledgePanelTitle.title,
          builder: (_, __) => ListView.builder(
            padding: EdgeInsetsDirectional.zero,
            itemCount: children.length - 1,
            itemBuilder: (BuildContext context, int index) => children[index],
          ),
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

  static List<ProductPageTab> _addHardCodedTabs(
    BuildContext context,
    Product product,
    List<ProductPageTab> tabs,
  ) {
    tabs.insert(
      0,
      ProductPageTab(
        id: 'for_me',
        labelBuilder: (BuildContext context) =>
            AppLocalizations.of(context).product_page_tab_for_me,
        builder: (BuildContext context, __) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SmoothSimpleButton(
              onPressed: () {
                showSmoothReorderBottomSheet<ProductPageTab>(
                  context,
                  items: tabs.map((ProductPageTab tab) {
                    return tab;
                  }).toList(growable: false),
                  onReorder: (List<ProductPageTab> reorderedItems) {
                    context.read<UserPreferences>().setProductPageTabs(
                            reorderedItems.map((ProductPageTab tab) {
                          return tab.id;
                        }).toList(growable: false));
                    tabs
                      ..clear()
                      ..addAll(reorderedItems);
                  },
                  labelBuilder: (
                    BuildContext context,
                    ProductPageTab item,
                    int index,
                  ) {
                    return Text(
                      item.labelBuilder(context),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                  title: AppLocalizations.of(context).product_page_reorder_tabs,
                );
              },
              child:
                  Text(AppLocalizations.of(context).product_page_reorder_tabs),
            ),
          ],
        ),
      ),
    );
    if (product.website?.trim().isNotEmpty == true) {
      tabs.add(
        ProductPageTab(
          id: 'website',
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
        id: 'prices',
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
          id: 'folksonomy',
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
