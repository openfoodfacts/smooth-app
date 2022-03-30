import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panels_builder.dart';
import 'package:smooth_app/cards/product_cards/product_image_carousel.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/knowledge_panels_query.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/product/category_cache.dart';
import 'package:smooth_app/pages/product/category_picker_page.dart';
import 'package:smooth_app/pages/product/common/product_dialog_helper.dart';
import 'package:smooth_app/pages/product/edit_product_page.dart';
import 'package:smooth_app/pages/product/knowledge_panel_product_cards.dart';
import 'package:smooth_app/pages/product/summary_card.dart';
import 'package:smooth_app/pages/user_preferences_dev_mode.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class ProductPage extends StatefulWidget {
  const ProductPage(this.product);

  final Product product;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

enum ProductPageMenuItem { WEB, REFRESH }

class _ProductPageState extends State<ProductPage> {
  late Product _product;
  late ProductPreferences _productPreferences;
  bool isVisible = true;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _updateLocalDatabaseWithProductHistory(context, _product);
    AnalyticsHelper.trackProductPageOpen(
      product: _product,
    );
  }

  @override
  Widget build(BuildContext context) {
    // All watchers defined here:
    _productPreferences = context.watch<ProductPreferences>();
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final MaterialColor materialColor =
        SmoothTheme.getMaterialColor(themeProvider);

    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: SmoothTheme.getColor(
        colorScheme,
        materialColor,
        ColorDestination.SURFACE_BACKGROUND,
      ),
      floatingActionButton: isVisible
          ? FloatingActionButton(
              backgroundColor: colorScheme.primary,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: Stack(
        children: <Widget>[
          NotificationListener<UserScrollNotification>(
              onNotification: (UserScrollNotification notification) {
                if (notification.direction == ScrollDirection.forward) {
                  if (!isVisible) {
                    setState(() {
                      isVisible = true;
                    });
                  }
                } else if (notification.direction == ScrollDirection.reverse) {
                  if (isVisible) {
                    setState(() {
                      isVisible = false;
                    });
                  }
                }
                return true;
              },
              child: _buildProductBody(context)),

          //! It is a temporary button for Pop-Up action menu
          if (isVisible) ...<Widget>[
            Positioned(
                bottom: size.height * 0.01,
                right: size.width * 0.01,
                child: Container(
                  height: size.height * 0.05,
                  width: size.width * 0.2,
                  decoration: BoxDecoration(
                      color: colorScheme.primary, shape: BoxShape.circle),
                  child: PopupMenuButton<ProductPageMenuItem>(
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<ProductPageMenuItem>>[
                      PopupMenuItem<ProductPageMenuItem>(
                        value: ProductPageMenuItem.WEB,
                        child: Text(appLocalizations.label_web),
                      ),
                      PopupMenuItem<ProductPageMenuItem>(
                        value: ProductPageMenuItem.REFRESH,
                        child: Text(appLocalizations.label_refresh),
                      ),
                    ],
                    onSelected: (final ProductPageMenuItem value) async {
                      switch (value) {
                        case ProductPageMenuItem.WEB:
                          LaunchUrlHelper.launchURL(
                              'https://openfoodfacts.org/product/${_product.barcode}/',
                              false);
                          break;
                        case ProductPageMenuItem.REFRESH:
                          _refreshProduct(context);
                          break;
                      }
                    },
                  ),
                ))
          ]
        ],
      ),
    );
  }

  Future<void> _refreshProduct(BuildContext context) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final ProductDialogHelper productDialogHelper = ProductDialogHelper(
      barcode: _product.barcode!,
      context: context,
      localDatabase: localDatabase,
      refresh: true,
    );
    final FetchedProduct fetchedProduct =
        await productDialogHelper.openUniqueProductSearch();
    if (fetchedProduct.status == FetchedProductStatus.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.product_refreshed),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() => _product = fetchedProduct.product!);
      await _updateLocalDatabaseWithProductHistory(context, _product);
    } else {
      productDialogHelper.openError(fetchedProduct);
    }
  }

  Future<void> _updateLocalDatabaseWithProductHistory(
      BuildContext context, Product product) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    await DaoProductList(localDatabase)
        .push(ProductList.history(), product.barcode!);
    localDatabase.notifyListeners();
  }

  Widget _buildProductBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refreshProduct(context),
      child: ListView(children: <Widget>[
        Align(
          heightFactor: 0.7,
          alignment: Alignment.topLeft,
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
              refreshProductCallback: _refreshProduct,
            ),
          ),
        ),
        _buildKnowledgePanelCards(),
        Padding(
          padding: const EdgeInsets.all(SMALL_SPACE),
          child: SmoothActionButton(
            text: 'Edit product', // TODO(monsieurtanuki): translations
            onPressed: () async {
              final bool? refreshed = await Navigator.push<bool>(
                context,
                MaterialPageRoute<bool>(
                  builder: (BuildContext context) => EditProductPage(_product),
                ),
              );
              if (refreshed ?? false) {
                setState(() {});
              }
            },
          ),
        ),
        if (context.read<UserPreferences>().getFlag(
                UserPreferencesDevMode.userPreferencesFlagAdditionalButton) ??
            false)
          ElevatedButton(
            onPressed: () async {
              if (_product.categoriesTags == null) {
                // TODO(monsieurtanuki): that's another story: how to set an initial category?
                return;
              }
              if (_product.categoriesTags!.length < 2) {
                // TODO(monsieurtanuki): no father, we need to do something with roots
                return;
              }
              final String currentTag =
                  _product.categoriesTags![_product.categoriesTags!.length - 1];
              final String fatherTag =
                  _product.categoriesTags![_product.categoriesTags!.length - 2];
              final CategoryCache categoryCache =
                  CategoryCache(ProductQuery.getLanguage()!);
              final Map<String, TaxonomyCategory>? siblingsData =
                  await categoryCache.getCategorySiblingsAndFather(
                fatherTag: fatherTag,
              );
              if (siblingsData == null) {
                // TODO(monsieurtanuki): what shall we do?
                return;
              }
              final String? newTag = await Navigator.push<String>(
                context,
                MaterialPageRoute<String>(
                  builder: (BuildContext context) => CategoryPickerPage(
                    barcode: _product.barcode!,
                    initialMap: siblingsData,
                    initialTree: _product.categoriesTags!,
                    categoryCache: categoryCache,
                  ),
                ),
              );
              if (newTag != null && newTag != currentTag) {
                setState(() {});
              }
            },
            child: const Text('Additional Button'),
          ),
      ]),
    );
  }

  FutureBuilder<KnowledgePanels> _buildKnowledgePanelCards() {
    // Note that this will make a new request on every rebuild.
    // TODO(jasmeet): Avoid additional requests on rebuilds.
    final Future<KnowledgePanels> knowledgePanels = KnowledgePanelsQuery(
      barcode: _product.barcode!,
    ).getKnowledgePanels();
    return FutureBuilder<KnowledgePanels>(
        future: knowledgePanels,
        builder:
            (BuildContext context, AsyncSnapshot<KnowledgePanels> snapshot) {
          List<Widget> knowledgePanelWidgets = <Widget>[];
          if (snapshot.hasData) {
            // Render all KnowledgePanels
            knowledgePanelWidgets =
                KnowledgePanelsBuilder(setState: () => setState(() {}))
                    .buildAll(
              snapshot.data!,
              context: context,
              product: _product,
            );
          } else if (snapshot.hasError) {
            // TODO(jasmeet): Retry the request.
            // Do nothing for now.
          } else {
            // Query results not available yet.
            knowledgePanelWidgets = <Widget>[_buildLoadingWidget()];
          }
          return KnowledgePanelProductCards(knowledgePanelWidgets);
        });
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const <Widget>[
          SizedBox(
            child: CircularProgressIndicator(),
            width: 60,
            height: 60,
          ),
        ],
      ),
    );
  }
}
