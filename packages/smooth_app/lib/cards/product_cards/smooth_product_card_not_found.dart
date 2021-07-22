import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/pages/product/product_page.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';

class SmoothProductCardNotFound extends StatelessWidget {
  const SmoothProductCardNotFound({
    required this.product,
    this.callback,
    this.elevation = 0.0,
    Key? key,
  }) : super(key: key);

  final VoidCallback? callback;
  final double elevation;
  final Product product;

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
            Text(AppLocalizations.of(context)!.missing_product),
            const SizedBox(
              height: 12.0,
            ),
            Text(
              product.barcode ?? 'Unknown',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            const SizedBox(
              height: 12.0,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SmoothSimpleButton(
                  text: AppLocalizations.of(context)!.add,
                  minWidth: 100.0,
                  onPressed: () {
                    Navigator.push<Widget>(
                      context,
                      MaterialPageRoute<Widget>(
                        builder: (BuildContext context) => ProductPage(
                          product: product,
                          newProduct: true,
                        ),
                      ),
                    );
                    if (callback != null) {
                      callback!();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
