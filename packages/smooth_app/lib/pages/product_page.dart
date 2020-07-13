import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/cards/expandables/nutriscore_expandable.dart';
import 'package:smooth_app/cards/expandables/nutrition_levels_expandable.dart';
import 'package:smooth_app/cards/expandables/product_processing_expandable.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({@required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                top: 18.0, right: 16.0, left: 16.0, bottom: 12.0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    product.productName,
                    style: Theme.of(context).textTheme.headline1,
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 16.0, bottom: 14.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Text(
                    product.brands,
                    style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.black, fontSize: 18.0),
                  ),
                ),
                Flexible(
                  child: Text(
                    '(${product.quantity})',
                    style: Theme.of(context).textTheme.headline4.copyWith(color: Colors.grey, fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 14.0, right: 16.0, left: 16.0, bottom: 8.0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    'Nutrition',
                    style: Theme.of(context).textTheme.headline2,
                  ),
                )
              ],
            ),
          ),
          NutriscoreExpandable(nutriscore: product.nutriscore,),
          NutritionLevelsExpandable(nutrientLevels: product.nutrientLevels, nutriments: product.nutriments),
          Padding(
            padding: const EdgeInsets.only(
                top: 14.0, right: 16.0, left: 16.0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    'Ingredients',
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
                top: 14.0, right: 16.0, left: 16.0, bottom: 14.0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    'Ecology',
                    style: Theme.of(context).textTheme.headline2,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
