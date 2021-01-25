import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/cards/expandables/attribute_list_expandable.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:provider/provider.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';

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
    final List<String> mainVariables =
        userPreferencesModel.getOrderedVariables(userPreferences);
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
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            widget.product.brands ??
                                appLocalizations.unknownBrand,
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
                  if (mainVariables.isNotEmpty)
                    AttributeListExpandable(
                      product: widget.product,
                      iconWidth: iconWidth,
                      attributeTags: mainVariables,
                      title: 'MY PREFERENCES',
                    ),
                  AttributeListExpandable(
                    product: widget.product,
                    iconWidth: iconWidth,
                    attributeTags: const <String>[
                      UserPreferencesModel.ATTRIBUTE_VEGAN,
                      UserPreferencesModel.ATTRIBUTE_VEGETARIAN,
                      UserPreferencesModel.ATTRIBUTE_PALM_OIL_FREE,
                    ],
                    title: attributeGroupLabels[UserPreferencesModel
                        .ATTRIBUTE_GROUP_INGREDIENT_ANALYSIS],
                  ),
                  AttributeListExpandable(
                    product: widget.product,
                    iconWidth: iconWidth,
                    attributeTags: const <String>[
                      UserPreferencesModel.ATTRIBUTE_NUTRISCORE,
                      UserPreferencesModel.ATTRIBUTE_LOW_SALT,
                      UserPreferencesModel.ATTRIBUTE_LOW_SUGARS,
                      UserPreferencesModel.ATTRIBUTE_LOW_FAT,
                      UserPreferencesModel.ATTRIBUTE_LOW_SATURATED_FAT,
                    ],
                    title: attributeGroupLabels[UserPreferencesModel
                        .ATTRIBUTE_GROUP_NUTRITIONAL_QUALITY],
                  ),
                  AttributeListExpandable(
                    product: widget.product,
                    iconWidth: iconWidth,
                    attributeTags: const <String>[
                      UserPreferencesModel.ATTRIBUTE_NOVA,
                      UserPreferencesModel.ATTRIBUTE_ADDITIVES,
                    ],
                    title: attributeGroupLabels[
                        UserPreferencesModel.ATTRIBUTE_GROUP_PROCESSING],
                  ),
                  AttributeListExpandable(
                    product: widget.product,
                    iconWidth: iconWidth,
                    attributeTags: const <String>[
                      UserPreferencesModel.ATTRIBUTE_ECOSCORE,
                      UserPreferencesModel.ATTRIBUTE_ORGANIC,
                      UserPreferencesModel.ATTRIBUTE_FAIR_TRADE,
                    ],
                    title: attributeGroupLabels[
                        UserPreferencesModel.ATTRIBUTE_GROUP_ENVIRONMENT],
                  ),
                ],
              ),
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
}
