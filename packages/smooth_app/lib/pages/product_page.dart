import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/cards/expandables/attribute_list_expandable.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/match.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:provider/provider.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/bottom_sheet_views/user_preferences_view.dart';
import 'package:smooth_app/functions/launchURL.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:smooth_app/pages/product_query_page_helper.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({@required this.product});

  final Product product;

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
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

  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final UserPreferencesModel userPreferencesModel =
        context.watch<UserPreferencesModel>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Size screenSize = MediaQuery.of(context).size;
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
                widget.product.brands ?? appLocalizations.unknownBrand,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Flexible(
              child: Text(
                widget.product.quantity != null
                    ? '${widget.product.quantity}'
                    : '',
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(color: Colors.grey, fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
    final Map<String, double> matches =
        Match.getAttributeMatches(widget.product, mainAttributes);
    for (final String attributeId in mainAttributes) {
      listItems.add(
        AttributeListExpandable(
          product: widget.product,
          iconWidth: iconWidth,
          attributeTags: <String>[attributeId],
          collapsible: false,
          background: _getBackgroundColor(matches[attributeId]),
        ),
      );
    }
    for (final AttributeGroup attributeGroup
        in _getOrderedAttributeGroups(userPreferencesModel)) {
      listItems.add(_getAttributeGroupWidget(attributeGroup, iconWidth));
    }
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: Text(
            widget.product.productName ?? appLocalizations.unknownProductName,
            style: Theme.of(context)
                .textTheme
                .headline4
                .copyWith(color: Theme.of(context).colorScheme.onBackground),
          ),
        ),
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onBackground),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/actions/food-cog.svg'),
            label: 'preferences',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.playlist_add),
            label: 'lists',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.launch),
            label: 'Web',
          ),
        ],
        onTap: (final int index) {
          switch (index) {
            case 0:
              UserPreferencesView.showModal(context);
              return;
            case 1:
              _openLists(widget.product.barcode);
              return;
            case 2:
              Launcher().launchURL(
                  context,
                  'https://openfoodfacts.org/product/${widget.product.barcode}/',
                  false);
              return;
          }
          throw 'Unexpected index $index';
        },
      ),
      body: Stack(
        children: <Widget>[
          if (widget.product.imgSmallUrl != null)
            Image.network(
              widget.product.imgSmallUrl,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent progress) {
                if (progress == null) {
                  return child;
                }
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
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
              color: Theme.of(context).colorScheme.surface.withAlpha(220),
              child: ListView(children: listItems),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateHistory(final BuildContext context) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final ProductList productList =
        ProductList(listType: ProductList.LIST_TYPE_HISTORY, parameters: '');
    await daoProductList.get(productList);
    productList.add(widget.product);
    await daoProductList.put(productList);
    localDatabase.notifyListeners();
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
      product: widget.product,
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

  Color _getBackgroundColor(final double match) {
    if (match == null) {
      return const Color.fromARGB(0xff, 0xEE, 0xEE, 0xEE);
    }
    if (match <= 20) {
      return const HSLColor.fromAHSL(1, 0, 1, .9).toColor();
    }
    if (match <= 40) {
      return const HSLColor.fromAHSL(1, 30, 1, .9).toColor();
    }
    if (match <= 60) {
      return const HSLColor.fromAHSL(1, 60, 1, .9).toColor();
    }
    if (match <= 80) {
      return const HSLColor.fromAHSL(1, 90, 1, .9).toColor();
    }
    return const HSLColor.fromAHSL(1, 120, 1, .9).toColor();
  }

  Future<void> _openLists(final String barcode) async {
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
                title: const Text('close'),
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
