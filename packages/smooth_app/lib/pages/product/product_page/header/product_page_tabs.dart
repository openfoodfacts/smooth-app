import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/data_cards/score_card.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/score_card_helper.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_page.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/product_price_refresher.dart';
import 'package:smooth_app/pages/product/product_page/tabs/folksonomy/product_folksonomy_tab.dart';
import 'package:smooth_app/pages/product/product_page/tabs/for_me/product_for_me_tab.dart';
import 'package:smooth_app/pages/product/product_page/tabs/prices/product_prices_tab.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_circle.dart';
import 'package:smooth_app/widgets/smooth_tabbar.dart';

enum ProductPageHarcodedTabs {
  FOR_ME(key: 'for_me'),
  PRICES(key: 'prices'),
  FOLKSONOMY(key: 'folksonomy');

  const ProductPageHarcodedTabs({required this.key});

  final String key;

  String label(AppLocalizations appLocalizations) {
    return switch (this) {
      ProductPageHarcodedTabs.FOR_ME =>
        appLocalizations.product_page_tab_for_me,
      ProductPageHarcodedTabs.PRICES =>
        appLocalizations.product_page_tab_prices,
      ProductPageHarcodedTabs.FOLKSONOMY =>
        appLocalizations.product_page_tab_folksonomy,
    };
  }
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
    final bool lightTheme = context.lightTheme();

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
            overflowMainColor: lightTheme
                ? Theme.of(context).tabBarTheme.unselectedLabelColor
                : Theme.of(context).scaffoldBackgroundColor,
            unselectedTabColor: lightTheme ? Colors.black87 : Colors.white70,
          ),
        ),
      ),
      pinned: true,
    );
  }
}

class ProductPageTabsGenerator {
  const ProductPageTabsGenerator();

  List<ProductPageTab> getTabs(BuildContext context, Product product) {
    final List<ProductPageTab> tabs = <ProductPageTab>[];

    final List<KnowledgePanelElement> roots =
        KnowledgePanelsBuilder.getRootPanelElements(product, simplified: true);

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
        simplified: true,
      );

      if (children.isEmpty) {
        continue;
      }

      children.add(
        TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => KnowledgePanelPage(
                panelId: id.replaceAll('_simplified', ''),
                product: product,
              ),
            ),
          ),
          child: Text(AppLocalizations.of(context).learnMore),
        ),
      );

      final KnowledgePanelTitle knowledgePanelTitle =
          children.first as KnowledgePanelTitle;

      children = children.sublist(1);

      tabs.add(
        ProductPageTab(
          id: id,
          labelBuilder: (_) => knowledgePanelTitle.title,
          prefix: _extractPrefix(product, knowledgePanelTitle),
          builder: (_, _) => ListView.builder(
            padding: const EdgeInsetsDirectional.only(bottom: LARGE_SPACE),
            itemCount: children.length,
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

  List<ProductPageTab> _addHardCodedTabs(
    BuildContext context,
    Product product,
    List<ProductPageTab> tabs,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    tabs.insert(
      0,
      ProductPageTab(
        id: ProductPageHarcodedTabs.FOR_ME.key,
        labelBuilder: (_) =>
            ProductPageHarcodedTabs.FOR_ME.label(appLocalizations),
        builder: (BuildContext context, _) => const ProductForMeTab(),
      ),
    );

    tabs.add(
      ProductPageTab(
        id: ProductPageHarcodedTabs.PRICES.key,
        labelBuilder: (_) =>
            ProductPageHarcodedTabs.PRICES.label(appLocalizations),
        builder: (_, Product product) => ProductPricesTab(product),
        suffix: FutureBuilder<int?>(
          future: _getPricesTotal(product, context),
          builder: (BuildContext context, AsyncSnapshot<int?> snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return EMPTY_WIDGET;
            }
            return _ProductPageTabBadge(snapshot.data!);
          },
        ),
      ),
    );

    tabs.add(
      ProductPageTab(
        id: ProductPageHarcodedTabs.FOLKSONOMY.key,
        labelBuilder: (_) =>
            ProductPageHarcodedTabs.FOLKSONOMY.label(appLocalizations),
        builder: (_, Product product) => ProductFolksonomyTab(product),
        suffix: FutureBuilder<int?>(
          future: _getFolksonomyTotal(product),
          builder: (BuildContext context, AsyncSnapshot<int?> snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return EMPTY_WIDGET;
            }
            return _ProductPageTabBadge(snapshot.data!);
          },
        ),
      ),
    );

    return tabs;
  }

  Future<int?> _getPricesTotal(Product product, BuildContext context) async {
    final GetPricesModel model = GetPricesModel.product(
      product: PriceMetaProduct.product(product),
      context: context,
    );
    final ProductPriceRefresher refresher = ProductPriceRefresher(
      model: model,
      userPreferences: context.read<UserPreferences>(),
      pricesResult: null,
      refreshDisplay: () {},
    );

    await refresher.runIfNeeded();

    return refresher.pricesResult?.total;
  }

  Future<int?> _getFolksonomyTotal(Product product) async {
    final Map<String, ProductTag> tags =
        await FolksonomyAPIClient.getProductTags(
          barcode: product.barcode!,
          uriHelper: ProductQuery.uriFolksonomyHelper,
        );
    return tags.length;
  }

  Widget? _extractPrefix(Product product, KnowledgePanelTitle title) {
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

class _ProductPageTabBadge extends StatelessWidget {
  const _ProductPageTabBadge(this.count);

  final int count;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: VERY_SMALL_SPACE * 2 + 16.0),
    decoration: BoxDecoration(
      color: context.extension<SmoothColorsThemeExtension>().secondaryNormal,
      borderRadius: ANGULAR_BORDER_RADIUS,
    ),
    padding: const EdgeInsetsDirectional.symmetric(
      horizontal: SMALL_SPACE,
      vertical: 6.0,
    ),
    child: Text(
      (count == 0) ? '-' : count.toString(),
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white, fontSize: 12.0, height: 1.0),
    ),
  );
}
