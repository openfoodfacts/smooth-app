import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/up_to_date_changes.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/dao_product_last_access.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/product_compatibility_helper.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer.dart';
import 'package:smooth_app/pages/product/product_page/header/product_page_tabs.dart';
import 'package:smooth_app/pages/product/product_page/new_product_header.dart';
import 'package:smooth_app/pages/product/product_page/new_product_page_loading_indicator.dart';
import 'package:smooth_app/pages/product/product_questions_widget.dart';
import 'package:smooth_app/pages/product/summary_card.dart';
import 'package:smooth_app/pages/scan/carousel/scan_carousel_manager.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/widget_height.dart';

class ProductPage extends StatefulWidget {
  const ProductPage(
    this.product, {
    this.heroTag,
    this.withHeroAnimation = true,
    this.backButton,
  });

  final Product product;

  final String? heroTag;
  final ProductPageBackButton? backButton;

  // When using a deep link the Hero animation shouldn't be used
  final bool withHeroAnimation;

  @override
  State<ProductPage> createState() => ProductPageState();
}

class ProductPageState extends State<ProductPage>
    with TraceableClientMixin, UpToDateMixin, SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  late final TabController _tabController;
  late List<ProductPageTab> _tabs;

  late ProductPreferences _productPreferences;
  bool _keepRobotoffQuestionsAlive = true;

  double bottomPadding = 0.0;

  @override
  String get actionName => 'Opened product_page';

  @override
  void initState() {
    super.initState();
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    initUpToDate(widget.product, localDatabase);
    DaoProductLastAccess(localDatabase).put(barcode);

    _tabs = ProductPageTabBar.extractTabsFromProduct(
      context: context,
      product: upToDateProduct,
    );

    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: 1,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateLocalDatabaseWithProductHistory(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ExternalScanCarouselManagerState carouselManager =
        ExternalScanCarouselManager.read(context);
    carouselManager.currentBarcode = barcode;

    _productPreferences = context.watch<ProductPreferences>();
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    refreshUpToDate();

    final MatchedProductV2 matchedProductV2 = MatchedProductV2(
      upToDateProduct,
      _productPreferences,
    );

    final bool hasPendingOperations = UpToDateChanges(
      localDatabase,
    ).hasNotTerminatedOperations(upToDateProduct.barcode!);

    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<Product>.value(value: upToDateProduct),
        Provider<ProductPageState>.value(value: this),
        Provider<ProductPageCompatibility>.value(
          value: ProductPageCompatibility(
            color: ProductCompatibilityHelper.product(
              matchedProductV2,
            ).getColor(context),
            matchedProductV2: matchedProductV2,
          ),
        ),
        ChangeNotifierProvider<ScrollController>.value(
          value: _scrollController,
        ),
      ],
      child: _buildTabLayout(hasPendingOperations),
    );
  }

  Widget _buildTabLayout(bool hasPendingOperations) {
    return SmoothScaffold(
      contentBehindStatusBar: true,
      spaceBehindStatusBar: false,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool value) {
          return <Widget>[
            SliverAppBar(
              floating: false,
              pinned: true,
              leading: EMPTY_WIDGET,
              leadingWidth: 0.0,
              titleSpacing: 0.0,
              title: ProductHeader(backButtonType: widget.backButton),
            ),
            SliverToBoxAdapter(
              child: HeroMode(
                enabled:
                    widget.withHeroAnimation &&
                    widget.heroTag?.isNotEmpty == true,
                child: SummaryCard(
                  upToDateProduct,
                  _productPreferences,
                  heroTag: widget.heroTag,
                  isFullVersion: true,
                ),
              ),
            ),
            ProductPageTabBar(tabController: _tabController, tabs: _tabs),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: _tabs
              .map(
                (ProductPageTab tab) => tab.builder(context, upToDateProduct),
              )
              .toList(growable: false),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MeasureSize(
            onChange: (Size size) {
              if (size.height != bottomPadding) {
                setState(() => bottomPadding = size.height);
              }
            },
            child: hasPendingOperations
                ? const ProductPageLoadingIndicator()
                : KeepQuestionWidgetAlive(
                    keepWidgetAlive: _keepRobotoffQuestionsAlive,
                    child: ProductQuestionsWidget(upToDateProduct),
                  ),
          ),
          const ProductFooter(),
        ],
      ),
    );
  }

  Future<void> _updateLocalDatabaseWithProductHistory(
    final BuildContext context,
  ) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    await DaoProductList(localDatabase).push(ProductList.history(), barcode);
    localDatabase.notifyListeners();
  }

  void startRobotoffQuestion() {
    setState(() => _keepRobotoffQuestionsAlive = true);
  }

  void stopRobotoffQuestion() {
    setState(() => _keepRobotoffQuestionsAlive = false);
  }

  static ProductPageState of(BuildContext context) {
    final ProductPageState? result = context
        .findAncestorStateOfType<ProductPageState>();
    assert(result != null, 'No ProductPageState found in context');
    return result!;
  }
}

class ProductPageCompatibility {
  ProductPageCompatibility({
    required Color color,
    required MatchedProductV2 matchedProductV2,
  }) : _color = color,
       score = ProductCompatibilityHelper.product(
         matchedProductV2,
       ).getFormattedScore();

  final Color _color;
  final String? score;

  Color? get color => score != null ? _color : null;

  @override
  //ignore: avoid_equals_and_hash_code_on_mutable_classes (false positive)
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductPageCompatibility &&
          runtimeType == other.runtimeType &&
          _color == other._color &&
          score == other.score;

  @override
  //ignore: avoid_equals_and_hash_code_on_mutable_classes (false positive)
  int get hashCode => _color.hashCode ^ score.hashCode;
}
