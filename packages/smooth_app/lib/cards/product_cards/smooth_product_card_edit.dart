import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_template.dart';
import 'package:smooth_app/pages/product_page.dart';
import 'package:smooth_app/views//smooth_product_sneak_peek_view.dart';
import 'package:smooth_ui_library/page_routes/smooth_sneak_peek_route.dart';
import 'package:smooth_ui_library/widgets/smooth_product_image.dart';

class SmoothProductCardEdit extends SmoothProductCardTemplate {
  SmoothProductCardEdit(
      {@required this.product,
        @required this.heroTag});

  final Product product;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //_openSneakPeek(context);
        Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(builder: (BuildContext context) => ProductPage(product: product,)),
        );
      },
      child: Hero(
        tag: heroTag,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SmoothProductImage(
                    product: product,
                    width: 100.0,
                    height: 120.0,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10.0),
                    padding: const EdgeInsets.only(top: 7.5),
                    width: 150.0,
                    height: 120.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                product.productName,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 4.0,
                        ),
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                product.brands ?? 'Unknown brand',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w300,
                                    fontStyle: FontStyle.italic),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 8.0,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 100.0,
                    child: product.nutriscore != null
                        ? Image.asset(
                      'assets/product/nutri_score_${product.nutriscore}.png',
                      fit: BoxFit.contain,
                    )
                        : Center(
                      child: Text(
                        'Nutri-score unavailable',
                        style: Theme.of(context).textTheme.subtitle1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Container(
                    width: 50.0,
                    height: 50.0,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      color: Colors.white,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 16.0,
                          offset: Offset(4.0, 4.0),
                        )
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add,
                        size: 32.0,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSneakPeek(BuildContext context) {
    Navigator.push<dynamic>(
        context,
        SmoothSneakPeekRoute<dynamic>(
            builder: (BuildContext context) {
              return Material(
                color: Colors.transparent,
                child: Center(
                  child: SmoothProductSneakPeekView(
                    product: product,
                    context: context,
                    heroTag: heroTag,
                  ),
                ),
              );
            },
            duration: 250));
  }
}
