import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panels_builder.dart';
import 'package:smooth_app/cards/product_cards/product_image_carousel.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/product/category_cache.dart';
import 'package:smooth_app/pages/product/category_picker_page.dart';
import 'package:smooth_app/pages/product/common/product_dialog_helper.dart';
import 'package:smooth_app/pages/product/common/product_list_page.dart';
import 'package:smooth_app/pages/product/edit_product_page.dart';
import 'package:smooth_app/pages/product/knowledge_panel_product_cards.dart';
import 'package:smooth_app/pages/product/summary_card.dart';
import 'package:smooth_app/pages/product_list_user_dialog_helper.dart';
import 'package:smooth_app/pages/user_preferences_dev_mode.dart';
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

class ProductPage extends StatefulWidget {
  const ProductPage(this.product);

  final Product product;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late Product _product;
  late ProductPreferences _productPreferences;
  bool scrollingUp = true;

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
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final MaterialColor materialColor = SmoothTheme.getMaterialColor(context);
    return Scaffold(
      backgroundColor: SmoothTheme.getColor(
        colorScheme,
        materialColor,
        ColorDestination.SURFACE_BACKGROUND,
      ),
      floatingActionButton: scrollingUp
          ? FloatingActionButton(
              backgroundColor: colorScheme.primary,
              onPressed: () {
                Navigator.maybePop(context);
              },
              child: Icon(
                ConstantIcons.instance.getBackIcon(),
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
                  if (!scrollingUp) {
                    setState(() {
                      scrollingUp = true;
                    });
                  }
                } else if (notification.direction == ScrollDirection.reverse) {
                  if (scrollingUp) {
                    setState(() {
                      scrollingUp = false;
                    });
                  }
                }
                return true;
              },
              child: _buildProductBody(context)),
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
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final List<String> productListNames =
        daoProductList.getUserLists(withBarcode: widget.product.barcode);
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
        _buildActionBar(appLocalizations),
        if (productListNames.isNotEmpty)
          _buildListWidget(appLocalizations, productListNames, daoProductList),
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

  Widget _buildKnowledgePanelCards() {
    final List<Widget> knowledgePanelWidgets;
    if (_product.knowledgePanels == null) {
      knowledgePanelWidgets = <Widget>[];
    } else {
      knowledgePanelWidgets = KnowledgePanelsBuilder(
        setState: () => setState(() {}),
        refreshProductCallback: _refreshProduct,
      ).buildAll(
        _product.knowledgePanels!,
        context: context,
        product: _product,
      );
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

  Widget _buildActionBar(final AppLocalizations appLocalizations) => Padding(
        padding: const EdgeInsets.all(SMALL_SPACE),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
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
                final bool? refreshed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute<bool>(
                    builder: (BuildContext context) =>
                        EditProductPage(_product),
                  ),
                );
                if (refreshed == true) {
                  await _refreshProduct(context);
                }
              },
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: onPressed,
          child: Icon(iconData, color: colorScheme.onPrimary),
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(
                18), // TODO(monsieurtanuki): cf. FloatingActionButton
            primary: colorScheme.primary,
          ),
        ),
        const SizedBox(height: VERY_SMALL_SPACE),
        Text(label),
      ],
    );
  }

  Widget _buildListWidget(
    final AppLocalizations appLocalizations,
    final List<String> productListNames,
    final DaoProductList daoProductList,
  ) {
    final List<Widget> children = <Widget>[];
    for (final String productListName in productListNames) {
      children.add(
        SmoothActionButton(
          text: productListName,
          onPressed: () async {
            final ProductList productList = ProductList.user(productListName);
            await daoProductList.get(productList);
            await Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => ProductListPage(productList),
              ),
            );
            setState(() {});
          },
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
              children: children,
              spacing: VERY_SMALL_SPACE,
              runSpacing: VERY_SMALL_SPACE,
            ),
          ],
        ),
      ),
    );
  }
}
