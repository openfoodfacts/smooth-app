import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/up_to_date_changes.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/dao_product_last_access.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/product_compatibility_helper.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_card.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/prices/prices_card.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer.dart';
import 'package:smooth_app/pages/product/product_page/new_product_header.dart';
import 'package:smooth_app/pages/product/product_page/new_product_page_loading_indicator.dart';
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
    with TraceableClientMixin, UpToDateMixin {
  final ScrollController _scrollController = ScrollController();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateLocalDatabaseWithProductHistory(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ExternalScanCarouselManagerState carouselManager =
        ExternalScanCarouselManager.read(context);
    carouselManager.currentBarcode = barcode;
    final SmoothColorsThemeExtension themeExtension =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    _productPreferences = context.watch<ProductPreferences>();
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    refreshUpToDate();

    final MatchedProductV2 matchedProductV2 = MatchedProductV2(
      upToDateProduct,
      _productPreferences,
    );

    final bool hasPendingOperations = UpToDateChanges(localDatabase)
        .hasNotTerminatedOperations(upToDateProduct.barcode!);

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
      child: SmoothScaffold(
        contentBehindStatusBar: true,
        spaceBehindStatusBar: false,
        changeStatusBarBrightness: false,
        statusBarBackgroundColor: Colors.transparent,
        backgroundColor:
            !context.darkTheme() ? themeExtension.primaryLight : null,
        body: Stack(
          children: <Widget>[
            _buildProductBody(context, bottomPadding),
            Positioned(
              left: 0.0,
              right: 0.0,
              top: 0.0,
              child: ProductHeader(
                backButtonType: widget.backButton,
              ),
            ),
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: MeasureSize(
                onChange: (Size size) {
                  if (size.height != bottomPadding) {
                    setState(() => bottomPadding = size.height);
                  }
                },
                child: !hasPendingOperations
                    ? const ProductPageLoadingIndicator()
                    : ProductQuestionsWidget(
                        upToDateProduct,
                      ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const ProductFooter(),
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

  Widget _buildProductBody(BuildContext context, double bottomPadding) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    return SafeArea(
      child: RefreshIndicator(
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
          controller: _scrollController,
          padding: const EdgeInsets.only(
            top: kToolbarHeight + LARGE_SPACE,
            bottom: LARGE_SPACE,
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SMALL_SPACE,
              ),
              child: HeroMode(
                enabled: widget.withHeroAnimation &&
                    widget.heroTag?.isNotEmpty == true,
                child: KeepQuestionWidgetAlive(
                  keepWidgetAlive: _keepRobotoffQuestionsAlive,
                  child: SummaryCard(
                    upToDateProduct,
                    _productPreferences,
                    heroTag: widget.heroTag,
                    isFullVersion: true,
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
                    UserPreferencesDevMode.userPreferencesFlagHideFolksonomy) ==
                false)
              FolksonomyCard(upToDateProduct),
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
            if (bottomPadding > 0) SizedBox(height: bottomPadding),
          ],
        ),
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

class ProductPageCompatibility {
  ProductPageCompatibility({
    required Color color,
    required MatchedProductV2 matchedProductV2,
  })  : _color = color,
        score = ProductCompatibilityHelper.product(matchedProductV2)
            .getFormattedScore();

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
