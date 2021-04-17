// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_ui_library/widgets/smooth_card.dart';

// Project imports:
import 'package:smooth_app/bottom_sheet_views/user_preferences_view.dart';
import 'package:smooth_app/cards/data_cards/image_upload_card.dart';
import 'package:smooth_app/cards/expandables/attribute_list_expandable.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/category_product_query.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/functions/launchURL.dart';
import 'package:smooth_app/pages/product/common/product_dialog_helper.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/pages/product_copy_helper.dart';
import 'package:smooth_app/data_models/pantry.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/data_models/user_preferences.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({@required this.product, this.newProduct = false});

  final bool newProduct;
  final Product product;

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Product _product;

  final EdgeInsets padding =
      const EdgeInsets.only(right: 8.0, left: 8.0, top: 4.0, bottom: 20.0);
  final EdgeInsets insets = const EdgeInsets.all(12.0);

  @override
  void initState() {
    super.initState();
    _updateHistory(context);
  }

  static const List<String> _ORDERED_ATTRIBUTE_GROUP_IDS = <String>[
    AttributeGroup.ATTRIBUTE_GROUP_INGREDIENT_ANALYSIS,
    AttributeGroup.ATTRIBUTE_GROUP_NUTRITIONAL_QUALITY,
    AttributeGroup.ATTRIBUTE_GROUP_PROCESSING,
    AttributeGroup.ATTRIBUTE_GROUP_ENVIRONMENT,
    AttributeGroup.ATTRIBUTE_GROUP_LABELS,
    AttributeGroup.ATTRIBUTE_GROUP_ALLERGENS,
  ];

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    _product ??= widget.product;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            _product.productName ?? appLocalizations.unknownProductName,
            //style: themeData.textTheme.headline4,
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/actions/food-cog.svg',
                color: themeData.bottomNavigationBarTheme.selectedItemColor,
              ),
              label: appLocalizations.label_preferences,
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.copy),
              label: 'Copy',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.launch),
              label: appLocalizations.label_web,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.refresh),
              label: appLocalizations.label_refresh,
            ),
            BottomNavigationBarItem(
              icon: Icon(ConstantIcons.getShareIcon()),
              label: appLocalizations.label_share,
            ),
          ],
          onTap: (final int index) async {
            switch (index) {
              case 0:
                UserPreferencesView.showModal(context);
                return;
              case 1:
                await _copy(
                  userPreferences: userPreferences,
                  daoProductList: daoProductList,
                  daoProduct: daoProduct,
                );
                return;
              case 2:
                Launcher().launchURL(
                    context,
                    'https://openfoodfacts.org/product/${_product.barcode}/',
                    false);
                return;
              case 3:
                final ProductDialogHelper productDialogHelper =
                    ProductDialogHelper(
                  barcode: _product.barcode,
                  context: context,
                  localDatabase: localDatabase,
                  refresh: true,
                );
                final Product product =
                    await productDialogHelper.openUniqueProductSearch();
                if (product == null) {
                  productDialogHelper.openProductNotFoundDialog();
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(appLocalizations.product_refreshed),
                    duration: const Duration(seconds: 2),
                  ),
                );
                setState(() {
                  _product = product;
                });
                return;
              case 4:
                Share.share(
                  'Try this food: https://openfoodfacts.org/product/${_product.barcode}/',
                  subject: '${_product.productName} (by openfoodfacts.org)',
                );
                return;
            }
            throw 'Unexpected index $index';
          },
        ),
        body: widget.newProduct
            ? _buildNewProductBody(context)
            : _buildProductBody(context));
  }

  Future<void> _updateHistory(final BuildContext context) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final ProductList productList =
        ProductList(listType: ProductList.LIST_TYPE_HISTORY, parameters: '');
    await daoProductList.get(productList);
    productList.add(_product);
    await daoProductList.put(productList);
    localDatabase.notifyListeners();
  }

  Widget _buildProductImagesCarousel(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
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

    return Container(
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
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return ListView(children: <Widget>[
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
    ]);
  }

  Widget _buildProductBody(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Size screenSize = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);
    final double iconWidth =
        screenSize.width / 10; // TODO(monsieurtanuki): target size?
    final Map<String, String> attributeGroupLabels = <String, String>{};
    for (final AttributeGroup attributeGroup
        in productPreferences.attributeGroups) {
      attributeGroupLabels[attributeGroup.id] = attributeGroup.name;
    }
    final List<String> attributeIds =
        productPreferences.getOrderedImportantAttributeIds();
    final List<Widget> listItems = <Widget>[];

    listItems.add(_buildProductImagesCarousel(context));

    // Brands, quantity
    listItems.add(
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Text(
                _product.brands ?? appLocalizations.unknownBrand,
                style: themeData.textTheme.subtitle1,
              ),
            ),
            Flexible(
              child: Text(
                _product.quantity != null ? '${_product.quantity}' : '',
                style: themeData.textTheme.headline4
                    .copyWith(color: Colors.grey, fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );

    final Map<String, Attribute> attributes =
        _product.getAttributes(attributeIds);
    final double opacity = themeData.brightness == Brightness.light
        ? 1
        : SmoothTheme.ADDITIONAL_OPACITY_FOR_DARK;

    for (final String attributeId in attributeIds) {
      if (attributes[attributeId] != null) {
        listItems.add(
          AttributeListExpandable(
            padding: padding,
            insets: insets,
            product: _product,
            iconWidth: iconWidth,
            attributeIds: <String>[attributeId],
            collapsible: false,
            background: _getBackgroundColor(attributes[attributeId])
                .withOpacity(opacity),
          ),
        );
      }
    }

    for (final AttributeGroup attributeGroup
        in _getOrderedAttributeGroups(productPreferences)) {
      listItems.add(_getAttributeGroupWidget(attributeGroup, iconWidth));
    }

    //Similar foods
    if (_product.categoriesTags != null && _product.categoriesTags.isNotEmpty) {
      for (int i = _product.categoriesTags.length - 1;
          i < _product.categoriesTags.length;
          i++) {
        final String categoryTag = _product.categoriesTags[i];
        const MaterialColor materialColor = Colors.blue;
        listItems.add(
          SmoothCard(
            padding: padding,
            insets: insets,
            color: SmoothTheme.getColor(
              themeData.colorScheme,
              materialColor,
              ColorDestination.SURFACE_BACKGROUND,
            ),
            child: ListTile(
              leading: Icon(
                Icons.search,
                size: iconWidth,
                color: SmoothTheme.getColor(
                  themeData.colorScheme,
                  materialColor,
                  ColorDestination.SURFACE_FOREGROUND,
                ),
              ),
              onTap: () async => await ProductQueryPageHelper().openBestChoice(
                color: materialColor,
                heroTag: 'search_bar',
                name: categoryTag,
                localDatabase: localDatabase,
                productQuery: CategoryProductQuery(
                  category: categoryTag,
                  languageCode: ProductQuery.getCurrentLanguageCode(context),
                  countryCode: ProductQuery.getCurrentCountryCode(),
                  size: 500,
                ),
                context: context,
              ),
              title: Text(
                categoryTag,
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

  Widget _getAttributeGroupWidget(
    final AttributeGroup attributeGroup,
    final double iconWidth,
  ) {
    final List<String> attributeIds = <String>[];
    for (final Attribute attribute in attributeGroup.attributes) {
      attributeIds.add(attribute.id);
    }
    return AttributeListExpandable(
      padding: padding,
      insets: insets,
      product: _product,
      iconWidth: iconWidth,
      attributeIds: attributeIds,
      title: attributeGroup.name,
    );
  }

  List<AttributeGroup> _getOrderedAttributeGroups(
      final ProductPreferences productPreferences) {
    final List<AttributeGroup> attributeGroups = <AttributeGroup>[];
    for (final String attributeGroupId in _ORDERED_ATTRIBUTE_GROUP_IDS) {
      for (final AttributeGroup attributeGroup
          in productPreferences.attributeGroups) {
        if (attributeGroupId == attributeGroup.id) {
          attributeGroups.add(attributeGroup);
        }
      }
    }

    /// in case we get new attribute groups but we haven't included them yet
    for (final AttributeGroup attributeGroup
        in productPreferences.attributeGroups) {
      if (!_ORDERED_ATTRIBUTE_GROUP_IDS.contains(attributeGroup.id)) {
        attributeGroups.add(attributeGroup);
      }
    }
    return attributeGroups;
  }

  Color _getBackgroundColor(final Attribute attribute) {
    if (attribute.status == Attribute.STATUS_KNOWN) {
      if (attribute.match <= 20) {
        return const HSLColor.fromAHSL(1, 0, 1, .9).toColor();
      }
      if (attribute.match <= 40) {
        return const HSLColor.fromAHSL(1, 30, 1, .9).toColor();
      }
      if (attribute.match <= 60) {
        return const HSLColor.fromAHSL(1, 60, 1, .9).toColor();
      }
      if (attribute.match <= 80) {
        return const HSLColor.fromAHSL(1, 90, 1, .9).toColor();
      }
      return const HSLColor.fromAHSL(1, 120, 1, .9).toColor();
    } else {
      return const Color.fromARGB(0xff, 0xEE, 0xEE, 0xEE);
    }
  }

  Future<void> _copy({
    @required final UserPreferences userPreferences,
    @required final DaoProductList daoProductList,
    @required final DaoProduct daoProduct,
  }) async {
    final List<PantryType> pantryTypes = <PantryType>[
      PantryType.PANTRY,
      PantryType.SHOPPING,
    ];
    final Map<PantryType, List<Pantry>> allPantries =
        <PantryType, List<Pantry>>{};
    for (final PantryType pantryType in pantryTypes) {
      final List<Pantry> pantries = await Pantry.getAll(
        userPreferences,
        daoProduct,
        pantryType,
      );
      allPantries[pantryType] = pantries;
    }
    final ProductCopyHelper productCopyHelper = ProductCopyHelper();
    final List<Widget> children = await productCopyHelper.getButtons(
      context: context,
      daoProductList: daoProductList,
      daoProduct: daoProduct,
      allPantries: allPantries,
      userPreferences: userPreferences,
    );
    if (children.isEmpty) {
      // no list to add to
      return;
    }
    final dynamic target = await showModalBottomSheet<dynamic>(
      context: context,
      builder: (final BuildContext context) => Column(
        children: <Widget>[
          const Text('Select the destination:'),
          Wrap(
            direction: Axis.horizontal,
            children: children,
            spacing: 8.0,
          ),
        ],
      ),
    );
    if (target == null) {
      // nothing selected
      return;
    }
    final List<Product> products = <Product>[widget.product];
    productCopyHelper.copy(
      context: context,
      target: target,
      allPantries: allPantries,
      daoProductList: daoProductList,
      products: products,
      userPreferences: userPreferences,
    );
  }
}
