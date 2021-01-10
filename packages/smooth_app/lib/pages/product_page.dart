import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/cards/expandables/labels_expandable.dart';
import 'package:smooth_app/cards/expandables/attribute_expandable.dart';
import 'package:smooth_app/cards/expandables/nutrition_levels_expandable.dart';
import 'package:smooth_app/cards/expandables/product_processing_expandable.dart';
import 'package:smooth_app/cards/information_cards/palm_oil_free_information_card.dart';
import 'package:smooth_app/cards/information_cards/vegan_information_card.dart';
import 'package:smooth_app/cards/information_cards/vegetarian_information_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:provider/provider.dart';
import 'package:openfoodfacts/model/Attribute.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({@required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final UserPreferencesModel userPreferencesModel =
        context.watch<UserPreferencesModel>();
    final Attribute nutriscoreAttribute =
        userPreferencesModel.getAttribute(product, 'nutriscore');
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
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black54,
            ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
            child: Container(
              color: Theme.of(context).cardColor.withAlpha(220),
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
                                AppLocalizations.of(context).unknownProductName,
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
                            product.brands ??
                                AppLocalizations.of(context).unknownBrand,
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
                  if (product.ingredientsAnalysisTags != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 12.0),
                      child: VeganInformationCard(
                        status: product.ingredientsAnalysisTags.veganStatus,
                      ),
                    )
                  else
                    Container(),
                  if (product.ingredientsAnalysisTags != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 12.0),
                      child: VegetarianInformationCard(
                        status:
                            product.ingredientsAnalysisTags.vegetarianStatus,
                      ),
                    )
                  else
                    Container(),
                  if (product.ingredientsAnalysisTags != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 12.0),
                      child: PalmOilFreeInformationCard(
                        status:
                            product.ingredientsAnalysisTags.palmOilFreeStatus,
                      ),
                    )
                  else
                    Container(),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 14.0, right: 16.0, left: 16.0, bottom: 8.0),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context).nutrition,
                            style: Theme.of(context).textTheme.headline2,
                          ),
                        )
                      ],
                    ),
                  ),
                  AttributeExpandable(nutriscoreAttribute),
                  NutritionLevelsExpandable(
                      nutrientLevels: product.nutrientLevels,
                      nutriments: product.nutriments),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 14.0, right: 16.0, left: 16.0, bottom: 8.0),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context).ingredients,
                            style: Theme.of(context).textTheme.headline2,
                          ),
                        )
                      ],
                    ),
                  ),
                  ProductProcessingExpandable(
                    additives: product.additives,
                    novaGroup: product.nutriments.novaGroup,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 14.0, right: 16.0, left: 16.0, bottom: 8.0),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context).ecology,
                            style: Theme.of(context).textTheme.headline2,
                          ),
                        )
                      ],
                    ),
                  ),
                  LabelsExpandable(labels: product.labelsTags ?? <String>[]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
