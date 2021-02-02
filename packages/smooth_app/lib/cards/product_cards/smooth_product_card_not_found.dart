import 'package:flutter/material.dart';
import 'package:smooth_app/pages/smooth_upload_page.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/pages/product_page.dart';

class SmoothProductCardNotFound extends StatelessWidget {
  SmoothProductCardNotFound({
    @required this.barcode,
    this.callback,
    this.elevation = 0.0,
  }) {
    this.product = Product(
      barcode: barcode,
    );
  }

  final String barcode;
  final Function callback;
  final double elevation;

  Product product;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      borderRadius: const BorderRadius.all(Radius.circular(15.0)),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.all(Radius.circular(15.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('This product is missing'),
            const SizedBox(
              height: 12.0,
            ),
            Text(barcode, style: Theme.of(context).textTheme.subtitle1),
            const SizedBox(
              height: 12.0,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SmoothSimpleButton(
                  text: 'Add',
                  width: 100.0,
                  onPressed: () {
                    Navigator.push<dynamic>(
                      context,
                      MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => ProductPage(
                                product: product,
                                newProduct: true,
                              )),
                    );
                    callback();
                  },
                  //onLongPress: () => ProductPage.showLists(product, context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
