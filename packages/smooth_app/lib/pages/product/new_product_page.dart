import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
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
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/prices/prices_card.dart';
import 'package:smooth_app/pages/product/common/product_list_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_product_page.dart';
import 'package:smooth_app/pages/product/product_questions_widget.dart';
import 'package:smooth_app/pages/product/reorderable_knowledge_panel_page.dart';
import 'package:smooth_app/pages/product/reordered_knowledge_panel_cards.dart';
import 'package:smooth_app/pages/product/standard_knowledge_panel_cards.dart';
import 'package:smooth_app/pages/product/summary_card.dart';
import 'package:smooth_app/pages/product/website_card.dart';
import 'package:smooth_app/pages/product_list_user_dialog_helper.dart';
import 'package:smooth_app/pages/scan/carousel/scan_carousel_manager.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/constant_icons.dart';
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
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
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
    _productPreferences = context.watch<ProductPreferences>();
    context.watch<LocalDatabase>();
    refreshUpToDate();

    return Provider<Product>.value(
      value: upToDateProduct,
      child: SmoothScaffold(
        contentBehindStatusBar: true,
        spaceBehindStatusBar: false,
        statusBarBackgroundColor: SmoothScaffold.semiTranslucentStatusBar,
        body: Stack(
          children: <Widget>[
            NotificationListener<UserScrollNotification>(
              onNotification: (UserScrollNotification notification) {
                if (notification.direction == ScrollDirection.forward) {
                  if (!scrollingUp) {
                    setState(() => scrollingUp = true);
                  }
                } else if (notification.direction == ScrollDirection.reverse) {
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
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
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
          _buildActionBar(appLocalizations),
          _buildListIfRelevantWidget(
            appLocalizations,
            daoProductList,
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
          // Space for the navigation bar
          SizedBox(height: MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }

  Future<void> _editList() async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final bool? refreshed = await ProductListUserDialogHelper(daoProductList)
        .showUserAddProductsDialog(
      context,
      <String>{widget.product.barcode!},
    );
    if (refreshed == true) {
      setState(() {});
    }
  }

  Future<void> _shareProduct() async {
    AnalyticsHelper.trackEvent(
      AnalyticsEvent.shareProduct,
      barcode: barcode,
    );
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    // We need to provide a sharePositionOrigin to make the plugin work on ipad
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final String url = 'https://'
        '${ProductQuery.getCountry().offTag}.openfoodfacts.org'
        '/product/$barcode';
    Share.share(
      appLocalizations.share_product_text(url),
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    );
  }

  Widget _buildActionBar(final AppLocalizations appLocalizations) => Padding(
        padding: const EdgeInsets.all(SMALL_SPACE),
        child: Semantics(
          explicitChildNodes: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildActionBarItem(
                Icons.bookmark_border,
                appLocalizations.user_list_button_add_product,
                _editList,
              ),
              _buildActionBarItem(
                Icons.edit,
                appLocalizations.edit_product_label,
                () async {
                  setState(() => _keepRobotoffQuestionsAlive = false);

                  AnalyticsHelper.trackEvent(
                    AnalyticsEvent.openProductEditPage,
                    barcode: barcode,
                  );

                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          EditProductPage(upToDateProduct),
                    ),
                  );

                  // Force Robotoff questions to be reloaded
                  setState(() => _keepRobotoffQuestionsAlive = true);
                },
              ),
              _buildActionBarItem(
                ConstantIcons.instance.getShareIcon(),
                appLocalizations.share,
                _shareProduct,
              ),
            ],
          ),
        ),
      );

  Widget _buildActionBarItem(
    final IconData iconData,
    final String label,
    final Function() onPressed,
  ) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    return Expanded(
      child: Semantics(
        value: label,
        button: true,
        excludeSemantics: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(
                  18,
                ), // TODO(monsieurtanuki): cf. FloatingActionButton
                backgroundColor: colorScheme.primary,
              ),
              child: Icon(iconData, color: colorScheme.onPrimary),
            ),
            const SizedBox(height: VERY_SMALL_SPACE),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: AutoSizeText(label, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListIfRelevantWidget(
    final AppLocalizations appLocalizations,
    final DaoProductList daoProductList,
  ) =>
      FutureBuilder<List<String>>(
        future: daoProductList.getUserListsWithBarcodes(<String>[barcode]),
        builder: (
          final BuildContext context,
          final AsyncSnapshot<List<String>> snapshot,
        ) {
          if (snapshot.data != null && snapshot.data!.isNotEmpty) {
            return _buildListWidget(
              appLocalizations,
              snapshot.data!,
              daoProductList,
            );
          }
          return EMPTY_WIDGET;
        },
      );

  Widget _buildListWidget(
    final AppLocalizations appLocalizations,
    final List<String> productListNames,
    final DaoProductList daoProductList,
  ) {
    final List<Widget> children = <Widget>[];
    for (final String productListName in productListNames) {
      children.add(
        Padding(
          padding: const EdgeInsetsDirectional.only(
            top: VERY_SMALL_SPACE,
            end: VERY_SMALL_SPACE,
          ),
          child: ElevatedButton(
            style: ButtonStyle(
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(
                      horizontal: VERY_LARGE_SPACE, vertical: MEDIUM_SPACE),
                ),
                shape: MaterialStateProperty.all(
                  const RoundedRectangleBorder(
                    borderRadius: ROUNDED_BORDER_RADIUS,
                  ),
                )),
            onPressed: () async {
              final ProductList productList = ProductList.user(productListName);
              await daoProductList.get(productList);
              if (!mounted) {
                return;
              }
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => ProductListPage(
                    productList,
                    allowToSwitchBetweenLists: false,
                  ),
                ),
              );
              setState(() {});
            },
            child: Text(
              productListName.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                // color: buttonData.textColor ?? themeData.colorScheme.primary,
              ),
            ),
          ),
        ),
      );
    }
    return SmoothCard(
      child: Padding(
        padding: const EdgeInsets.all(SMALL_SPACE),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              appLocalizations.user_list_subtitle_product,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            WrapSuper(
              wrapType: WrapType.fit,
              wrapFit: WrapFit.proportional,
              spacing: VERY_SMALL_SPACE,
              children: children,
            ),
          ],
        ),
      ),
    );
  }
}
