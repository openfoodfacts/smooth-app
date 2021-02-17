import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/cards/data_cards/image_upload_card.dart';
import 'package:smooth_app/cards/expandables/attribute_list_expandable.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/match.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:provider/provider.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/bottom_sheet_views/user_preferences_view.dart';
import 'package:smooth_app/functions/launchURL.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:smooth_app/pages/product_query_page_helper.dart';
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:smooth_app/pages/product_dialog_helper.dart';
import 'package:smooth_app/database/category_product_query.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_ui_library/widgets/smooth_card.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({@required this.product, this.newProduct = false});

  final bool newProduct;
  final Product product;

  @override
  _ProductPageState createState() => _ProductPageState();

  static Future<void> showLists(
    final Product product,
    final BuildContext context,
  ) async {
    final String barcode = product.barcode;
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final List<ProductList> list =
        await daoProductList.getAll(withStats: false);
    final List<ProductList> listWithBarcode =
        await daoProductList.getAllWithBarcode(barcode);
    int index = 0;
    final Set<int> already = <int>{};
    final Set<int> editable = <int>{};
    final Set<int> addable = <int>{};
    for (final ProductList productList in list) {
      switch (productList.listType) {
        case ProductList.LIST_TYPE_HISTORY:
        case ProductList.LIST_TYPE_USER_DEFINED:
        case ProductList.LIST_TYPE_SCAN:
          editable.add(index);
      }
      switch (productList.listType) {
        case ProductList.LIST_TYPE_USER_DEFINED:
          addable.add(index);
      }
      for (final ProductList withBarcode in listWithBarcode) {
        if (productList.lousyKey == withBarcode.lousyKey) {
          already.add(index);
          break;
        }
      }
      index++;
    }
    showCupertinoModalBottomSheet<Widget>(
      expand: false,
      context: context,
      backgroundColor: Colors.transparent,
      bounce: true,
      barrierColor: Colors.black45,
      builder: (BuildContext context) => Material(
        child: ListView.builder(
          itemCount: list.length + 1,
          itemBuilder: (final BuildContext context, int index) {
            if (index == 0) {
              return ListTile(
                onTap: () {
                  Navigator.pop(context);
                },
                title: Text(product.productName),
                leading: const Icon(Icons.close),
              );
            }
            index--;
            final ProductList productList = list[index];
            return StatefulBuilder(
              builder:
                  (final BuildContext context, final StateSetter setState) {
                Function onPressed;
                IconData iconData;
                if (already.contains(index)) {
                  if (!editable.contains(index)) {
                    iconData = Icons.check;
                  } else {
                    iconData = Icons.check_box_outlined;
                    onPressed = () async {
                      already.remove(index);
                      daoProductList.removeBarcode(productList, barcode);
                      localDatabase.notifyListeners();
                      setState(() {});
                    };
                  }
                } else {
                  if (!addable.contains(index)) {
                    iconData = null;
                  } else if (!editable.contains(index)) {
                    iconData = null;
                  } else {
                    iconData = Icons.check_box_outline_blank_outlined;
                    onPressed = () async {
                      already.add(index);
                      daoProductList.addBarcode(productList, barcode);
                      localDatabase.notifyListeners();
                      setState(() {});
                    };
                  }
                }
                return Card(
                  child: ListTile(
                    title: Text(
                      ProductQueryPageHelper.getProductListLabel(productList),
                    ),
                    trailing: iconData == null
                        ? null
                        : IconButton(
                            icon: Icon(iconData),
                            onPressed: () {
                              onPressed();
                            },
                          ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProductPageState extends State<ProductPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Product _product;

  @override
  void initState() {
    super.initState();
    _updateHistory(context);
  }

  static const List<String> _ORDERED_ATTRIBUTE_GROUP_IDS = <String>[
    UserPreferencesModel.ATTRIBUTE_GROUP_INGREDIENT_ANALYSIS,
    UserPreferencesModel.ATTRIBUTE_GROUP_NUTRITIONAL_QUALITY,
    UserPreferencesModel.ATTRIBUTE_GROUP_PROCESSING,
    UserPreferencesModel.ATTRIBUTE_GROUP_ENVIRONMENT,
    UserPreferencesModel.ATTRIBUTE_GROUP_LABELS,
    UserPreferencesModel.ATTRIBUTE_GROUP_ALLERGENS,
  ];

  static const double _OPACITY_FOR_DARK =
      .3; // TODO(monsieurtanuki): make it more public?

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    _product ??= widget.product;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: ListTile(
            title: Text(
              _product.productName ?? appLocalizations.unknownProductName,
              style: themeData.textTheme.headline4
                  .copyWith(color: colorScheme.onBackground),
            ),
          ),
          iconTheme: IconThemeData(color: colorScheme.onBackground),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/actions/food-cog.svg',
                color: themeData.bottomNavigationBarTheme.selectedItemColor,
              ),
              label: 'preferences',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.playlist_add),
              label: 'lists',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.launch),
              label: 'web',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.refresh),
              label: 'refresh',
            ),
            BottomNavigationBarItem(
              icon: Icon(ConstantIcons.getShareIcon()),
              label: 'share',
            ),
          ],
          onTap: (final int index) async {
            switch (index) {
              case 0:
                UserPreferencesView.showModal(context);
                return;
              case 1:
                ProductPage.showLists(_product, context);
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
                _scaffoldKey.currentState.showSnackBar(
                  const SnackBar(
                    content: Text('Product refreshed'),
                    duration: Duration(seconds: 2),
                  ),
                );
                setState(() {
                  _product = product;
                });
                return;
              case 4:
                WcFlutterShare.share(
                    sharePopupTitle: 'Share',
                    subject: '${_product.productName} (by openfoodfacts.org)',
                    text:
                        'Try this food: https://openfoodfacts.org/product/${_product.barcode}/',
                    mimeType: 'text/plain');
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

  Widget _buildNewProductBody(BuildContext context) {
    return ListView(children: <Widget>[
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        margin: const EdgeInsets.only(top: 20.0),
        child: Text(
          'Add a new product',
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
      ImageUploadCard(
          product: _product,
          imageField: ImageField.FRONT,
          buttonText: 'Front photo'),
      ImageUploadCard(
          product: _product,
          imageField: ImageField.INGREDIENTS,
          buttonText: 'Ingredients photo'),
      ImageUploadCard(
        product: _product,
        imageField: ImageField.NUTRITION,
        buttonText: 'Nutrition facts photo',
      ),
      ImageUploadCard(
          product: _product,
          imageField: ImageField.OTHER,
          buttonText: 'More interesting photos'),
    ]);
  }

  Widget _buildProductBody(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final UserPreferencesModel userPreferencesModel =
        context.watch<UserPreferencesModel>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Size screenSize = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);
    final double iconWidth =
        screenSize.width / 10; // TODO(monsieurtanuki): target size?
    final Map<String, String> attributeGroupLabels = <String, String>{};
    for (final AttributeGroup attributeGroup
        in userPreferencesModel.attributeGroups) {
      attributeGroupLabels[attributeGroup.id] = attributeGroup.name;
    }
    final List<String> mainAttributes =
        userPreferencesModel.getOrderedVariables(userPreferences);
    final List<Widget> listItems = <Widget>[];

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
    final Map<String, Attribute> matchingAttributes =
        Match.getMatchingAttributes(_product, mainAttributes);
    final double opacity =
        themeData.brightness == Brightness.light ? 1 : _OPACITY_FOR_DARK;
    for (final String attributeId in mainAttributes) {
      if (matchingAttributes[attributeId] != null) {
        listItems.add(
          AttributeListExpandable(
            product: _product,
            iconWidth: iconWidth,
            attributeTags: <String>[attributeId],
            collapsible: false,
            background: _getBackgroundColor(matchingAttributes[attributeId])
                .withOpacity(opacity),
          ),
        );
      }
    }
    for (final AttributeGroup attributeGroup
        in _getOrderedAttributeGroups(userPreferencesModel)) {
      listItems.add(_getAttributeGroupWidget(attributeGroup, iconWidth));
    }

    if (_product.categoriesTags != null && _product.categoriesTags.isNotEmpty) {
      for (int i = _product.categoriesTags.length - 1;
          i < _product.categoriesTags.length;
          i++) {
        final String categoryTag = _product.categoriesTags[i];
        const MaterialColor materialColor = Colors.blue;
        listItems.add(
          SmoothCard(
            background: SmoothTheme.getBackgroundColor(
              themeData.colorScheme,
              materialColor,
            ),
            collapsed: null,
            content: ListTile(
              leading: Icon(
                Icons.search,
                size: iconWidth,
                color: SmoothTheme.getForegroundColor(
                  themeData.colorScheme,
                  materialColor,
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
                'Similar foods',
                style: themeData.textTheme.subtitle2,
              ),
            ),
          ),
        );
      }
    }

    return Stack(
      children: <Widget>[
        if (_product.imgSmallUrl != null)
          Image.network(
            _product.imgSmallUrl,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
            loadingBuilder:
                (BuildContext context, Widget child, ImageChunkEvent progress) {
              if (progress == null) {
                return child;
              }
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  value: progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes,
                ),
              );
            },
          )
        else
          Container(
            width: screenSize.width,
            height: screenSize.height,
            color: Colors.black54,
          ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
          child: Container(
            color: themeData.colorScheme.surface.withAlpha(220),
            child: ListView(children: listItems),
          ),
        ),
      ],
    );
  }

  Widget _getAttributeGroupWidget(
    final AttributeGroup attributeGroup,
    final double iconWidth,
  ) {
    final List<String> attributeTags = <String>[];
    for (final Attribute attribute in attributeGroup.attributes) {
      attributeTags.add(attribute.id);
    }
    return AttributeListExpandable(
      product: _product,
      iconWidth: iconWidth,
      attributeTags: attributeTags,
      title: attributeGroup.name,
    );
  }

  List<AttributeGroup> _getOrderedAttributeGroups(
      final UserPreferencesModel userPreferencesModel) {
    final List<AttributeGroup> attributeGroups = <AttributeGroup>[];
    for (final String attributeGroupId in _ORDERED_ATTRIBUTE_GROUP_IDS) {
      for (final AttributeGroup attributeGroup
          in userPreferencesModel.attributeGroups) {
        if (attributeGroupId == attributeGroup.id) {
          attributeGroups.add(attributeGroup);
        }
      }
    }

    /// in case we get new attribute groups but we haven't included them yet
    for (final AttributeGroup attributeGroup
        in userPreferencesModel.attributeGroups) {
      if (!_ORDERED_ATTRIBUTE_GROUP_IDS.contains(attributeGroup.id)) {
        attributeGroups.add(attributeGroup);
      }
    }
    return attributeGroups;
  }

  Color _getBackgroundColor(final Attribute attribute) {
    if (attribute.status == Match.KNOWN_STATUS) {
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
}
