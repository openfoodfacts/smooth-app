import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_app/cards/product_cards/product_image_carousel.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/up_to_date_product_provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_product_cards.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/pages/inherited_data_manager.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/product/common/product_list_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_product_page.dart';
import 'package:smooth_app/pages/product/summary_card.dart';
import 'package:smooth_app/pages/product_list_user_dialog_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class ProductPage extends StatefulWidget {
  const ProductPage(this.product);

  final Product product;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> with TraceableClientMixin {
  late Product _product;
  late ProductPreferences _productPreferences;
  late ScrollController _scrollController;
  bool _mustScrollToTheEnd = false;
  bool scrollingUp = true;

  @override
  String get traceName => 'Opened product_page';

  @override
  String get traceTitle => 'product_page';

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateLocalDatabaseWithProductHistory(context);
    });
    AnalyticsHelper.trackProductPageOpen(
      product: _product,
    );
  }

  @override
  Widget build(BuildContext context) {
    final InheritedDataManagerState inheritedDataManager =
        InheritedDataManager.of(context);
    inheritedDataManager.setCurrentBarcode(_product.barcode ?? '');
    final ThemeData themeData = Theme.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mustScrollToTheEnd) {
        _scrollToTheEnd();
      }
    });
    // All watchers defined here:
    _productPreferences = context.watch<ProductPreferences>();

    return SmoothScaffold(
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
            child: Consumer<UpToDateProductProvider>(
              builder: (
                final BuildContext context,
                final UpToDateProductProvider provider,
                final Widget? child,
              ) {
                final Product? refreshedProduct = provider.get(_product);
                if (refreshedProduct != null) {
                  _product = refreshedProduct;
                }
                return _buildProductBody(context);
              },
            ),
          ),
          SafeArea(
            child: AnimatedContainer(
              duration: SmoothAnimationsDuration.short,
              width: kToolbarHeight,
              height: kToolbarHeight,
              decoration: BoxDecoration(
                color:
                    scrollingUp ? themeData.primaryColor : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Offstage(
                offstage: !scrollingUp,
                child: InkWell(
                  onTap: () {
                    Navigator.maybePop(context);
                  },
                  child: Tooltip(
                    message:
                        MaterialLocalizations.of(context).backButtonTooltip,
                    child: Icon(
                      ConstantIcons.instance.getBackIcon(),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _scrollToTheEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: SmoothAnimationsDuration.long,
    );
    _mustScrollToTheEnd = false;
  }

  Future<bool> _refreshProduct(BuildContext context) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final bool result = await ProductRefresher().fetchAndRefresh(
      context: context,
      localDatabase: localDatabase,
      barcode: _product.barcode!,
    );
    if (mounted && result) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.product_refreshed),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    return result;
  }

  Future<void> _updateLocalDatabaseWithProductHistory(
    final BuildContext context,
  ) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    await DaoProductList(localDatabase).push(
      ProductList.history(),
      _product.barcode!,
    );
    localDatabase.notifyListeners();
  }

  Widget _buildProductBody(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    return RefreshIndicator(
      onRefresh: () => _refreshProduct(context),
      child: ListView(
        // /!\ Smart Dart
        // `physics: const AlwaysScrollableScrollPhysics()`
        // means that we will always scroll, even if it's pointless.
        // Why do we need to? For the RefreshIndicator, that wouldn't be
        // triggered on a ListView smaller than the screen
        // (as there will be no scroll).
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          Align(
            heightFactor: 0.7,
            alignment: AlignmentDirectional.topStart,
            child: ProductImageCarousel(
              _product,
              height: 200,
              onUpload: _refreshProduct,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SMALL_SPACE,
            ),
            child: Hero(
              tag: _product.barcode ?? '',
              child: SummaryCard(
                _product,
                _productPreferences,
                isFullVersion: true,
                showUnansweredQuestions: true,
              ),
            ),
          ),
          _buildActionBar(appLocalizations),
          _buildListIfRelevantWidget(
            appLocalizations,
            daoProductList,
          ),
          _buildKnowledgePanelCards(),
          if (context.read<UserPreferences>().getFlag(
                  UserPreferencesDevMode.userPreferencesFlagAdditionalButton) ??
              false)
            ElevatedButton(
              onPressed: () {},
              child: const Text('Additional Button'),
            ),
        ],
      ),
    );
  }

  Widget _buildKnowledgePanelCards() {
    final List<Widget> knowledgePanelWidgets = <Widget>[];
    if (_product.knowledgePanels != null) {
      final List<KnowledgePanelElement> elements =
          KnowledgePanelWidget.getPanelElements(_product.knowledgePanels!);
      for (final KnowledgePanelElement panelElement in elements) {
        knowledgePanelWidgets.add(
          KnowledgePanelWidget(
            panelElement: panelElement,
            knowledgePanels: _product.knowledgePanels!,
            product: _product,
            onboardingMode: false,
          ),
        );
      }
    }
    return KnowledgePanelProductCards(knowledgePanelWidgets);
  }

  Future<void> _editList() async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final bool refreshed = await ProductListUserDialogHelper(daoProductList)
        .showUserListsWithBarcodeDialog(context, widget.product);
    if (refreshed) {
      setState(() {});
    }
  }

  Future<void> _shareProduct() async {
    AnalyticsHelper.trackShareProduct(barcode: widget.product.barcode!);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    // We need to provide a sharePositionOrigin to make the plugin work on ipad
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final String url = 'https://'
        '${ProductQuery.getCountry()!.iso2Code}.openfoodfacts.org'
        '/product/${widget.product.barcode}';
    Share.share(
      appLocalizations.share_product_text(url),
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  Widget _buildActionBar(final AppLocalizations appLocalizations) => Padding(
        padding: const EdgeInsets.all(SMALL_SPACE),
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
              () async => Navigator.push<bool>(
                context,
                MaterialPageRoute<bool>(
                  builder: (BuildContext context) => EditProductPage(_product),
                ),
              ),
            ),
            _buildActionBarItem(
              ConstantIcons.instance.getShareIcon(),
              appLocalizations.share,
              _shareProduct,
            ),
          ],
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(
                  18), // TODO(monsieurtanuki): cf. FloatingActionButton
              primary: colorScheme.primary,
            ),
            child: Icon(iconData, color: colorScheme.onPrimary),
          ),
          const SizedBox(height: VERY_SMALL_SPACE),
          AutoSizeText(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildListIfRelevantWidget(
    final AppLocalizations appLocalizations,
    final DaoProductList daoProductList,
  ) =>
      FutureBuilder<List<String>>(
        future: daoProductList.getUserLists(withBarcode: _product.barcode),
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
        SmoothActionButtonsBar(
          positiveAction: SmoothActionButton(
            text: productListName,
            onPressed: () async {
              final ProductList productList = ProductList.user(productListName);
              await daoProductList.get(productList);
              if (!mounted) {
                return;
              }
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      ProductListPage(productList),
                ),
              );
              setState(() {});
            },
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
              style: Theme.of(context).textTheme.headline3,
            ),
            Wrap(
              alignment: WrapAlignment.start,
              direction: Axis.horizontal,
              spacing: VERY_SMALL_SPACE,
              runSpacing: VERY_SMALL_SPACE,
              children: children,
            ),
          ],
        ),
      ),
    );
  }
}
