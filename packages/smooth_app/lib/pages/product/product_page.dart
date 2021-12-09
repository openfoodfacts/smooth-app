import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_app/cards/data_cards/image_upload_card.dart';
import 'package:smooth_app/cards/expandables/attribute_list_expandable.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/category_product_query.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_extra.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/product_copy_helper.dart';
import 'package:smooth_app/helpers/product_translation_helper.dart';
import 'package:smooth_app/pages/product/common/product_dialog_helper.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/product/new_product_page.dart';
import 'package:smooth_app/pages/smooth_bottom_navigation_bar.dart';
import 'package:smooth_app/pages/user_preferences_page.dart';
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';
import 'package:smooth_ui_library/widgets/smooth_card.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({
    required this.product,
    this.newProduct = false,
  });

  final bool newProduct;
  final Product product;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late Product _product;
  bool _first = true;

  final EdgeInsets margin = const EdgeInsets.only(
    right: 8.0,
    left: 8.0,
    top: 4.0,
    bottom: 20.0,
  );

  final EdgeInsets padding = const EdgeInsets.all(12.0);

  static const List<String> _ORDERED_ATTRIBUTE_GROUP_IDS = <String>[
    AttributeGroup.ATTRIBUTE_GROUP_INGREDIENT_ANALYSIS,
    AttributeGroup.ATTRIBUTE_GROUP_NUTRITIONAL_QUALITY,
    AttributeGroup.ATTRIBUTE_GROUP_PROCESSING,
    AttributeGroup.ATTRIBUTE_GROUP_ENVIRONMENT,
    AttributeGroup.ATTRIBUTE_GROUP_LABELS,
    AttributeGroup.ATTRIBUTE_GROUP_ALLERGENS,
  ];

  @override
  void initState() {
    super.initState();
    _updateHistory(context);
  }

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    if (_first) {
      _first = false;
      _product = widget.product;
      final Set<ProductImprovement> improvements =
          _product.getProductImprovements();
      if (improvements.isNotEmpty) {
        Future<void>.delayed(
          Duration.zero,
          () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                appLocalizations
                    .product_improvements_count(improvements.length),
              ),
              action: SnackBarAction(
                label: appLocalizations.showAll.toUpperCase(),
                onPressed: () async {
                  // TODO(monsieurtanuki): do something with the result
                  await _getSelectedImprovement(
                    appLocalizations,
                    improvements,
                  );
                },
              ),
            ),
          ),
        );
      }
    }
    return Scaffold(
      bottomNavigationBar: const SmoothBottomNavigationBar(),
      appBar: AppBar(
        title: Text(_getProductName(appLocalizations)),
        actions: <Widget>[
          PopupMenuButton<String>(
            itemBuilder: (final BuildContext context) =>
                <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'web',
                child: Text(appLocalizations.label_web),
              ),
              PopupMenuItem<String>(
                value: 'refresh',
                child: Text(appLocalizations.label_refresh),
              ),
              const PopupMenuItem<String>(
                value: 'new_product_page',
                child: Text('New Product Page (Beta)'),
              ),
            ],
            onSelected: (final String value) async {
              switch (value) {
                case 'web':
                  LaunchUrlHelper.launchURL(
                      'https://openfoodfacts.org/product/${_product.barcode}/',
                      false);
                  break;
                case 'refresh':
                  final ProductDialogHelper productDialogHelper =
                      ProductDialogHelper(
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
                    _product = fetchedProduct.product!;
                    await _updateHistory(context);
                  } else {
                    productDialogHelper.openError(fetchedProduct);
                  }
                  break;
                case 'new_product_page':
                  Navigator.push<Widget>(
                    context,
                    MaterialPageRoute<Widget>(
                      builder: (BuildContext context) =>
                          NewProductPage(_product),
                    ),
                  );
                  break;
                default:
                  throw Exception('Unknown value: $value');
              }
            },
          ),
        ],
      ),
      body: widget.newProduct
          ? _buildNewProductBody(context)
          : _buildProductBody(context),
    );
  }

  Future<void> _updateHistory(final BuildContext context) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    await DaoProductExtra(localDatabase).putLastSeen(widget.product);
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

  Widget _buildNewProductBody(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return ListView(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          margin: const EdgeInsets.only(top: 20.0),
          child: Text(
            appLocalizations.add_product,
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
        ImageUploadCard(
          product: _product,
          imageField: ImageField.FRONT,
          buttonText: appLocalizations.front_photo,
        ),
        ImageUploadCard(
          product: _product,
          imageField: ImageField.INGREDIENTS,
          buttonText: appLocalizations.ingredients_photo,
        ),
        ImageUploadCard(
          product: _product,
          imageField: ImageField.NUTRITION,
          buttonText: appLocalizations.nutrition_facts_photo,
        ),
        ImageUploadCard(
          product: _product,
          imageField: ImageField.OTHER,
          buttonText: appLocalizations.more_photos,
        ),
      ],
    );
  }

  Widget _buildProductBody(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final Size screenSize = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);
    final double iconHeight = IconWidgetSizer.getIconSizeFromContext(context);
    final Map<String, String> attributeGroupLabels = <String, String>{};
    final List<String> attributeIds =
        productPreferences.getOrderedImportantAttributeIds();

    for (final AttributeGroup attributeGroup
        in productPreferences.attributeGroups!) {
      attributeGroupLabels[attributeGroup.id!] = attributeGroup.name!;
    }

    final List<Widget> listItems = <Widget>[
      _buildProductImagesCarousel(context),
    ];

    // Brands, quantity
    listItems.add(
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListTile(
          title: Text(
            _getProductName(appLocalizations),
            style: themeData.textTheme.headline4,
          ),
          subtitle: Text(_product.brands ?? appLocalizations.unknownBrand),
          trailing: Text(
            _product.quantity != null ? _product.quantity! : '',
            style: themeData.textTheme.headline3,
          ),
        ),
      ),
    );

    const int ITEM_COUNT = 3;
    final double itemWidth = screenSize.width / ITEM_COUNT;
    listItems.add(
      Container(
        color: themeData.colorScheme.surface,
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _getClickableIcon(
              label: 'lists',
              icon: const Icon(Icons.playlist_add),
              onTap: () async => _copy(
                userPreferences: userPreferences,
                daoProductList: daoProductList,
                daoProduct: daoProduct,
              ),
              width: itemWidth,
            ),
            _getClickableIcon(
              label: appLocalizations.label_share,
              icon: Icon(ConstantIcons.instance.getShareIcon()),
              onTap: () async => Share.share(
                'Try this food: https://openfoodfacts.org/product/${_product.barcode}/',
                subject: '${_product.productName} (by openfoodfacts.org)',
              ),
              width: itemWidth,
            ),
            _getClickableIcon(
              label: appLocalizations.label_preferences,
              icon: SvgPicture.asset(
                'assets/actions/food-cog.svg',
                color: themeData.colorScheme.onSurface,
              ),
              onTap: () async => Navigator.push<Widget>(
                context,
                MaterialPageRoute<Widget>(
                  builder: (BuildContext context) =>
                      const UserPreferencesPage(),
                ),
              ),
              width: itemWidth,
            ),
          ],
        ),
      ),
    );

    final List<Attribute> attributes =
        AttributeListExpandable.getPopulatedAttributes(_product, attributeIds);
    if (attributes.isNotEmpty) {
      listItems.add(
        AttributeListExpandable(
          margin: margin,
          padding: padding,
          product: _product,
          iconHeight: iconHeight,
          attributes: attributes,
          title: 'Scores',
          initiallyCollapsed: false,
        ),
      );
    }

    for (final AttributeGroup attributeGroup
        in _getOrderedAttributeGroups(productPreferences)) {
      final Widget? grouped =
          _getAttributeGroupWidget(attributeGroup, iconHeight);
      if (grouped != null) {
        listItems.add(grouped);
      }
    }

    //Similar foods
    if (_product.categoriesTags != null &&
        _product.categoriesTags!.isNotEmpty) {
      final String currentLanguageCode =
          ProductQuery.getCurrentLanguageCode(context);
      final OpenFoodFactsLanguage currentLanguage =
          LanguageHelper.fromJson(currentLanguageCode);

      for (int i = _product.categoriesTags!.length - 1;
          i < _product.categoriesTags!.length;
          i++) {
        final String categoryTag = _product.categoriesTags![i];
        final String categoryTagInLocalLanguage =
            _product.categoriesTagsInLanguages?[currentLanguage]?[i] ??
                categoryTag;

        const MaterialColor materialColor = Colors.blue;
        listItems.add(
          SmoothCard(
            margin: margin,
            padding: padding,
            color: SmoothTheme.getColor(
              themeData.colorScheme,
              materialColor,
              ColorDestination.SURFACE_BACKGROUND,
            ),
            child: ListTile(
              leading: Icon(
                Icons.search,
                size: iconHeight,
                color: SmoothTheme.getColor(
                  themeData.colorScheme,
                  materialColor,
                  ColorDestination.SURFACE_FOREGROUND,
                ),
              ),
              onTap: () async => ProductQueryPageHelper().openBestChoice(
                color: materialColor,
                heroTag: 'search_bar',
                name: categoryTagInLocalLanguage,
                localDatabase: localDatabase,
                productQuery: CategoryProductQuery(
                  category: categoryTag,
                  languageCode: currentLanguageCode,
                  countryCode: ProductQuery.getCurrentCountryCode(),
                  size: 500,
                ),
                context: context,
              ),
              title: Text(
                categoryTagInLocalLanguage,
                style: themeData.textTheme.headline3,
              ),
              subtitle: Text(
                appLocalizations.similar_food,
                style: themeData.textTheme.subtitle2,
              ),
            ),
          ),
        );
      }
    }

    return ListView(children: listItems);
  }

  Widget? _getAttributeGroupWidget(
    final AttributeGroup attributeGroup,
    final double iconHeight,
  ) {
    final List<String> attributeIds = <String>[];
    for (final Attribute attribute in attributeGroup.attributes!) {
      attributeIds.add(attribute.id!);
    }
    final List<Attribute> attributes =
        AttributeListExpandable.getPopulatedAttributes(_product, attributeIds);
    if (attributes.isEmpty) {
      return null;
    }
    return AttributeListExpandable(
      margin: margin,
      padding: padding,
      product: _product,
      iconHeight: iconHeight,
      attributes: attributes,
      title: attributeGroup.name!,
    );
  }

  List<AttributeGroup> _getOrderedAttributeGroups(
      final ProductPreferences productPreferences) {
    final List<AttributeGroup> attributeGroups = <AttributeGroup>[];
    for (final String attributeGroupId in _ORDERED_ATTRIBUTE_GROUP_IDS) {
      for (final AttributeGroup attributeGroup
          in productPreferences.attributeGroups!) {
        if (attributeGroupId == attributeGroup.id) {
          attributeGroups.add(attributeGroup);
        }
      }
    }

    /// in case we get new attribute groups but we haven't included them yet
    for (final AttributeGroup attributeGroup
        in productPreferences.attributeGroups!) {
      if (!_ORDERED_ATTRIBUTE_GROUP_IDS.contains(attributeGroup.id)) {
        attributeGroups.add(attributeGroup);
      }
    }
    return attributeGroups;
  }

  Future<void> _copy({
    required final UserPreferences userPreferences,
    required final DaoProductList daoProductList,
    required final DaoProduct daoProduct,
  }) async {
    final ProductList? productList =
        await ProductCopyHelper.instance.showProductListDialog(
      context: context,
      daoProductList: daoProductList,
      daoProduct: daoProduct,
    );
    if (productList == null) {
      // nothing selected
      return;
    }
    final List<Product> products = <Product>[widget.product];
    await ProductCopyHelper.instance.copy(
      context: context,
      productList: productList,
      daoProductList: daoProductList,
      products: products,
    );
  }

  String _getProductName(final AppLocalizations appLocalizations) =>
      _product.productName ?? appLocalizations.unknownProductName;

  Widget _getClickableIcon({
    required final String label,
    required final Widget icon,
    required final Future<void> Function() onTap,
    required final double width,
  }) =>
      InkWell(
        onTap: onTap,
        child: SizedBox(
          width: width,
          child: Column(
            children: <Widget>[
              icon,
              Text(_capitalize(label)),
            ],
          ),
        ),
      );

  static String _capitalize(final String input) =>
      '${input.substring(0, 1).toUpperCase()}${input.substring(1)}';

  Future<ProductImprovement?> _getSelectedImprovement(
    final AppLocalizations appLocalizations,
    final Set<ProductImprovement> improvements,
  ) async =>
      showCupertinoModalBottomSheet<ProductImprovement>(
        context: context,
        builder: (final BuildContext context) {
          final ProductTranslationHelper helper =
              ProductTranslationHelper(appLocalizations);
          final List<Widget> children = <Widget>[];
          // vaguely ordered
          for (final ProductImprovement improvement
              in ProductImprovement.values) {
            if (improvements.contains(improvement)) {
              children.add(
                ListTile(
                  leading: const Icon(Icons.arrow_forward),
                  title: Text(helper.getImprovementTranslation(improvement)),
                  onTap: () => Navigator.pop(context, improvement),
                ),
              );
            }
          }
          children.add(
            ListTile(
              trailing: const Icon(Icons.close),
              onTap: () => Navigator.pop(context),
            ),
          );
          return Material(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          );
        },
      );
}
