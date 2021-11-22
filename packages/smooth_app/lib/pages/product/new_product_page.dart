import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/data_cards/image_upload_card.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panels_builder.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/database/dao_product_extra.dart';
import 'package:smooth_app/database/knowledge_panels_query.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/common/product_dialog_helper.dart';
import 'package:smooth_app/pages/product/summary_card.dart';
import 'package:smooth_app/pages/smooth_bottom_navigation_bar.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';

class NewProductPage extends StatefulWidget {
  const NewProductPage(this.product);

  final Product product;

  @override
  State<NewProductPage> createState() => _ProductPageState();
}

enum ProductPageMenuItem { WEB, REFRESH }

class _ProductPageState extends State<NewProductPage> {
  late Product _product;
  late ProductPreferences _productPreferences;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _updateLocalDatabaseWithProductHistory(context, _product);
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
    return Scaffold(
      bottomNavigationBar: SmoothBottomNavigationBar(),
      backgroundColor: SmoothTheme.getColor(
        colorScheme,
        materialColor,
        ColorDestination.SURFACE_BACKGROUND,
      ),
      appBar: AppBar(
        title: Text(getProductName(_product, appLocalizations)),
        actions: <Widget>[
          PopupMenuButton<ProductPageMenuItem>(
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
        ],
      ),
      body: _buildProductBody(context),
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
    await DaoProductExtra(localDatabase).putLastSeen(product);
    localDatabase.notifyListeners();
  }

  Widget _buildProductImagesCarousel(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final List<ImageUploadCard> carouselItems = <ImageUploadCard>[
      ImageUploadCard(
        product: _product,
        imageField: ImageField.FRONT,
        imageUrl: _product.imageFrontUrl,
        title: appLocalizations.product,
        buttonText: appLocalizations.front_photo,
      ),
      ImageUploadCard(
        product: _product,
        imageField: ImageField.INGREDIENTS,
        imageUrl: _product.imageIngredientsUrl,
        title: appLocalizations.ingredients,
        buttonText: appLocalizations.ingredients_photo,
      ),
      ImageUploadCard(
        product: _product,
        imageField: ImageField.NUTRITION,
        imageUrl: _product.imageNutritionUrl,
        title: appLocalizations.nutrition,
        buttonText: appLocalizations.nutrition_facts_photo,
      ),
      ImageUploadCard(
        product: _product,
        imageField: ImageField.PACKAGING,
        imageUrl: _product.imagePackagingUrl,
        title: appLocalizations.packaging_information,
        buttonText: appLocalizations.packaging_information_photo,
      ),
      ImageUploadCard(
        product: _product,
        imageField: ImageField.OTHER,
        imageUrl: null,
        title: appLocalizations.more_photos,
        buttonText: appLocalizations.more_photos,
      ),
    ];

    return SizedBox(
      height: 200,
      child: ListView(
        // This next line does the trick.
        scrollDirection: Axis.horizontal,
        children: carouselItems
            .map(
              (ImageUploadCard item) => Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                decoration: const BoxDecoration(color: Colors.black12),
                child: item,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildProductBody(BuildContext context) {
    return ListView(children: <Widget>[
      Align(
        heightFactor: 0.7,
        alignment: Alignment.topLeft,
        child: _buildProductImagesCarousel(context),
      ),
      SummaryCard(_product, _productPreferences, isRenderedInProductPage: true),
      _buildKnowledgePanelCards(),
    ]);
  }

  FutureBuilder<KnowledgePanels> _buildKnowledgePanelCards() {
    // Note that this will make a new request on every rebuild.
    // TODO(jasmeet): Avoid additional requests on rebuilds.
    final Future<KnowledgePanels> knowledgePanels =
        KnowledgePanelsQuery(barcode: _product.barcode!)
            .getKnowledgePanels(context);
    return FutureBuilder<KnowledgePanels>(
        future: knowledgePanels,
        builder:
            (BuildContext context, AsyncSnapshot<KnowledgePanels> snapshot) {
          List<Widget> knowledgePanelWidgets = <Widget>[];
          if (snapshot.hasData) {
            // Render all KnowledgePanels
            knowledgePanelWidgets =
                const KnowledgePanelsBuilder().build(snapshot.data!);
          } else if (snapshot.hasError) {
            // TODO(jasmeet): Retry the request.
            // Do nothing for now.
          } else {
            // Query results not available yet.
            knowledgePanelWidgets = <Widget>[_buildLoadingWidget()];
          }
          final List<Widget> widgetsWrappedInSmoothCards = <Widget>[];
          for (final Widget widget in knowledgePanelWidgets) {
            widgetsWrappedInSmoothCards.add(
              Padding(
                padding: const EdgeInsets.only(top: VERY_LARGE_SPACE),
                child: buildProductSmoothCard(
                  body: widget,
                  padding: SMOOTH_CARD_PADDING,
                ),
              ),
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: widgetsWrappedInSmoothCards,
            ),
          );
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
