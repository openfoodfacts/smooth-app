import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/cards/expandables/attribute_list_expandable.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({@required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Size screenSize = MediaQuery.of(context).size;
    final double iconWidth =
        screenSize.width / 10; // TODO(monsieurtanuki): target size?
    return Scaffold(
      body: Stack(
        children: <Widget>[
          if (product.imgSmallUrl != null)
            Image.network(
              product.imgSmallUrl,
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
                    padding: const EdgeInsets.only(
                        top: 18.0, right: 16.0, left: 16.0, bottom: 12.0),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            product.productName ??
                                appLocalizations.unknownProductName,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 16.0, left: 16.0, bottom: 14.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            product.brands ?? appLocalizations.unknownBrand,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            product.quantity != null
                                ? '${product.quantity}'
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
                  AttributeListExpandable(
                    product: product,
                    iconWidth: iconWidth,
                    attributeTags: const <String>[
                      UserPreferencesModel.ATTRIBUTE_VEGAN,
                      UserPreferencesModel.ATTRIBUTE_VEGETARIAN,
                      UserPreferencesModel.ATTRIBUTE_PALM_OIL_FREE,
                    ],
                    title: appLocalizations.nutrition,
                  ),
                  AttributeListExpandable(
                    product: product,
                    iconWidth: iconWidth,
                    attributeTags: const <String>[
                      UserPreferencesModel.ATTRIBUTE_NUTRISCORE,
                      UserPreferencesModel.ATTRIBUTE_LOW_SALT,
                      UserPreferencesModel.ATTRIBUTE_LOW_SUGARS,
                      UserPreferencesModel.ATTRIBUTE_LOW_FAT,
                      UserPreferencesModel.ATTRIBUTE_LOW_SATURATED_FAT,
                    ],
                    title: 'Nutrition levels',
                  ),
                  AttributeListExpandable(
                    product: product,
                    iconWidth: iconWidth,
                    attributeTags: const <String>[
                      UserPreferencesModel.ATTRIBUTE_NOVA,
                      UserPreferencesModel.ATTRIBUTE_ADDITIVES,
                    ],
                    title: appLocalizations.ingredients,
                  ),
                  AttributeListExpandable(
                    product: product,
                    iconWidth: iconWidth,
                    attributeTags: const <String>[
                      UserPreferencesModel.ATTRIBUTE_ECOSCORE,
                      UserPreferencesModel.ATTRIBUTE_ORGANIC,
                      UserPreferencesModel.ATTRIBUTE_FAIR_TRADE,
                    ],
                    title: appLocalizations.ecology,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
