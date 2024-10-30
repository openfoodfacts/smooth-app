import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/product_image_carousel.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/dao_product_last_access.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/prices/prices_card.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/product_page/new_product_footer.dart';
import 'package:smooth_app/pages/product/product_questions_widget.dart';
import 'package:smooth_app/pages/product/reorderable_knowledge_panel_page.dart';
import 'package:smooth_app/pages/product/reordered_knowledge_panel_cards.dart';
import 'package:smooth_app/pages/product/standard_knowledge_panel_cards.dart';
import 'package:smooth_app/pages/product/summary_card.dart';
import 'package:smooth_app/pages/product/website_card.dart';
import 'package:smooth_app/pages/scan/carousel/scan_carousel_manager.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/widget_height.dart';

class ProductPage extends StatefulWidget {
  const ProductPage(
    this.product, {
    this.heroTag,
    this.withHeroAnimation = true,
  });

  final Product product;

  final String? heroTag;

  // When using a deep link the Hero animation shouldn't be used
  final bool withHeroAnimation;

  @override
  State<ProductPage> createState() => ProductPageState();
}

class ProductPageState extends State<ProductPage>
    with TraceableClientMixin, UpToDateMixin {
  final ScrollController _carouselController = ScrollController();

  late ProductPreferences _productPreferences;
  late ProductQuestionsLayout questionsLayout;
  bool _keepRobotoffQuestionsAlive = true;

  bool scrollingUp = true;
  double bottomPadding = 0.0;

  @override
  String get actionName => 'Opened product_page';

  @override
  void initState() {
    super.initState();
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    initUpToDate(widget.product, localDatabase);
    DaoProductLastAccess(localDatabase).put(barcode);
    questionsLayout = getUserQuestionsLayout(context.read<UserPreferences>());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateLocalDatabaseWithProductHistory(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ExternalScanCarouselManagerState carouselManager =
        ExternalScanCarouselManager.read(context);
    carouselManager.currentBarcode = barcode;
    final ThemeData themeData = Theme.of(context);
    final SmoothColorsThemeExtension themeExtension =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    _productPreferences = context.watch<ProductPreferences>();
    context.watch<LocalDatabase>();
    refreshUpToDate();

    return MultiProvider(
      providers: <Provider<dynamic>>[
        Provider<Product>.value(value: upToDateProduct),
        Provider<ProductPageState>.value(value: this),
      ],
      child: Provider<Product>.value(
        value: upToDateProduct,
        child: SmoothScaffold(
          contentBehindStatusBar: true,
          spaceBehindStatusBar: false,
          statusBarBackgroundColor: SmoothScaffold.semiTranslucentStatusBar,
          backgroundColor:
              !context.darkTheme() ? themeExtension.primaryLight : null,
          body: Stack(
            children: <Widget>[
              NotificationListener<UserScrollNotification>(
                onNotification: (UserScrollNotification notification) {
                  if (notification.direction == ScrollDirection.forward) {
                    if (!scrollingUp) {
                      setState(() => scrollingUp = true);
                    }
                  } else if (notification.direction ==
                      ScrollDirection.reverse) {
                    if (scrollingUp) {
                      setState(() => scrollingUp = false);
                    }
                  }
                  return true;
                },
                child: _buildProductBody(context),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: SMALL_SPACE),
                child: SafeArea(
                  child: AnimatedContainer(
                    duration: SmoothAnimationsDuration.short,
                    width: kToolbarHeight,
                    height: kToolbarHeight,
                    decoration: BoxDecoration(
                      color: scrollingUp
                          ? themeData.primaryColor
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Offstage(
                      offstage: !scrollingUp,
                      child: const SmoothBackButton(iconColor: Colors.white),
                    ),
                  ),
                ),
              ),
              if (questionsLayout == ProductQuestionsLayout.banner)
                Positioned.directional(
                  start: 0.0,
                  end: 0.0,
                  bottom: 0.0,
                  textDirection: Directionality.of(context),
                  child: MeasureSize(
                    onChange: (Size size) {
                      if (size.height != bottomPadding) {
                        setState(() => bottomPadding = size.height);
                      }
                    },
                    child: ProductQuestionsWidget(
                      upToDateProduct,
                      layout: ProductQuestionsLayout.banner,
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: const ProductFooter(),
        ),
      ),
    );
  }

  Future<void> _updateLocalDatabaseWithProductHistory(
    final BuildContext context,
  ) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    await DaoProductList(localDatabase).push(
      ProductList.history(),
      barcode,
    );
    localDatabase.notifyListeners();
  }

  Widget _buildProductBody(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    return RefreshIndicator(
      onRefresh: () async => ProductRefresher().fetchAndRefresh(
        barcode: barcode,
        context: context,
      ),
      child: ListView(
        // /!\ Smart Dart
        // `physics: const AlwaysScrollableScrollPhysics()`
        // means that we will always scroll, even if it's pointless.
        // Why do we need to? For the RefreshIndicator, that wouldn't be
        // triggered on a ListView smaller than the screen
        // (as there will be no scroll).
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          bottom: SMALL_SPACE,
        ),
        children: <Widget>[
          Align(
            heightFactor: 0.7,
            alignment: AlignmentDirectional.topStart,
            child: ProductImageCarousel(
              upToDateProduct,
              height: 200,
              controller: _carouselController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SMALL_SPACE,
            ),
            child: HeroMode(
              enabled: widget.withHeroAnimation &&
                  widget.heroTag?.isNotEmpty == true,
              child: Hero(
                tag: widget.heroTag ?? '',
                child: KeepQuestionWidgetAlive(
                  keepWidgetAlive: _keepRobotoffQuestionsAlive,
                  child: SummaryCard(
                    upToDateProduct,
                    _productPreferences,
                    isFullVersion: true,
                  ),
                ),
              ),
            ),
          ),
          if (userPreferences.getFlag(
                  UserPreferencesDevMode.userPreferencesFlagUserOrderedKP) ??
              false)
            ReorderedKnowledgePanelCards(upToDateProduct)
          else
            StandardKnowledgePanelCards(upToDateProduct),
          // TODO(monsieurtanuki): include website in reordered knowledge panels
          if (upToDateProduct.website != null &&
              upToDateProduct.website!.trim().isNotEmpty)
            WebsiteCard(upToDateProduct.website!),
          PricesCard(upToDateProduct),
          if (userPreferences.getFlag(
                  UserPreferencesDevMode.userPreferencesFlagUserOrderedKP) ??
              false)
            Padding(
              padding: const EdgeInsets.all(SMALL_SPACE),
              child: SmoothLargeButtonWithIcon(
                text: appLocalizations.reorder_attribute_action,
                icon: Icons.sort,
                onPressed: () async => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ReorderableKnowledgePanelPage(upToDateProduct),
                  ),
                ),
              ),
            ),
          if (questionsLayout == ProductQuestionsLayout.banner)
            // assuming it's tall enough in order to go above the banner
            const SizedBox(height: 4 * VERY_LARGE_SPACE),
        ],
      ),
    );
  }

  void startRobotoffQuestion() {
    setState(() => _keepRobotoffQuestionsAlive = true);
  }

  void stopRobotoffQuestion() {
    setState(() => _keepRobotoffQuestionsAlive = false);
  }

  static ProductPageState of(BuildContext context) {
    final ProductPageState? result =
        context.findAncestorStateOfType<ProductPageState>();
    assert(result != null, 'No ProductPageState found in context');
    return result!;
  }
}
