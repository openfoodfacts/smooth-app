import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/data_cards/score_card.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/score_card_helper.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_card.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/prices/prices_card.dart';
import 'package:smooth_app/pages/product/website_card.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_circle.dart';
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
    required this.labelBuilder,
    required this.builder,
    this.prefix,
    this.suffix,
  });

  final String id;
  final String Function(BuildContext) labelBuilder;
  final Widget Function(BuildContext, Product) builder;
  final Widget? prefix;
  final Widget? suffix;
}

class ProductPageTabBar extends StatelessWidget {
  const ProductPageTabBar({required this.tabController, required this.tabs});

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
            items: tabs
                .map((ProductPageTab tab) {
                  return SmoothTabBarItem<ProductPageTab>(
                    label: tab.labelBuilder(context),
                    value: tab,
                  );
                })
                .toList(growable: false),
            leadingItems: tabs
                .map((ProductPageTab tab) => tab.prefix)
                .toList(growable: false),
            trailingItems: tabs
                .map((ProductPageTab tab) => tab.suffix)
                .toList(growable: false),
            onTabChanged: (_) {},
            overflowMainColor: context.lightTheme()
                ? Theme.of(context).tabBarTheme.unselectedLabelColor
                : Theme.of(context).scaffoldBackgroundColor,
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

      tabs.add(
        ProductPageTab(
          id: id,
          labelBuilder: (_) => knowledgePanelTitle.title,
          prefix: _extractPrefix(product, knowledgePanelTitle),
          builder: (_, _) => ListView.builder(
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
        id: ProductPageHarcodedTabs.FOR_ME.key,
        labelBuilder: (BuildContext context) =>
            AppLocalizations.of(context).product_page_tab_for_me,
        builder: (BuildContext context, _) => const Row(
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
            children: <Widget>[WebsiteCard(product.website!)],
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
          children: <Widget>[PricesCard(product)],
        ),
        suffix: PricesCounter(product: product),
      ),
    );

    if (context.read<UserPreferences>().getFlag(
          UserPreferencesDevMode.userPreferencesFlagHideFolksonomy,
        ) ==
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

  static Widget? _extractPrefix(Product product, KnowledgePanelTitle title) {
    final String? attribute = switch (title.topics?.firstOrNull) {
      'health' => Attribute.ATTRIBUTE_NUTRISCORE,
      'environment' => Attribute.ATTRIBUTE_ECOSCORE,
      _ => null,
    };

    if (attribute == null) {
      return null;
    }

    final List<Attribute> attributes = getPopulatedAttributes(product, <String>[
      attribute,
    ], <String>[]);

    if (attributes.isEmpty) {
      return null;
    }

    final CardEvaluation eval = getCardEvaluationFromAttribute(
      attributes.first,
    );

    return SmoothCircle.indicator(color: eval.textColor, size: 15.0);
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
