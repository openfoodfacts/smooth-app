// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_alert_dialog.dart';

// Project imports:
import 'package:smooth_app/database/barcode_product_query.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';

/// Dialog helper for product barcode search
class ProductDialogHelper {
  ProductDialogHelper({
    this.barcode,
    this.context,
    this.localDatabase,
    this.refresh,
  });

  final String barcode;
  final BuildContext context;
  final LocalDatabase localDatabase;
  final bool refresh;
  bool _popEd = false;

  Future<Product> openBestChoice() async {
    final Product product = await DaoProduct(localDatabase).get(barcode);
    if (product != null) {
      return product;
    }
    return openUniqueProductSearch();
  }

  Future<Product> openUniqueProductSearch() => showDialog<Product>(
        context: context,
        builder: (BuildContext context) {
          BarcodeProductQuery(
            barcode: barcode,
            languageCode: ProductQuery.getCurrentLanguageCode(context),
            countryCode: ProductQuery.getCurrentCountryCode(),
          ).getProduct().then((Product value) async {
            if (value != null) {
              await DaoProduct(localDatabase).put(value);
            }
            _popSearchingDialog(value);
            /* TODO(monsieurtanuki): better granularity - being able to say
             1. you clicked on 'stop'
             2. no internet connection
             3. no result at all
             4. time out
             5. of course, the product (when everything is fine)
             */
          });
          return _getSearchingDialog();
        },
      );

  void _popSearchingDialog(final Product product) {
    if (_popEd) {
      return;
    }
    _popEd = true;
    Navigator.pop(context, product);
  }

  Widget _getSearchingDialog() => SmoothAlertDialog(
        close: false,
        body: ListTile(
          leading: const CircularProgressIndicator(),
          title: Text(
            refresh ? 'Refreshing product' : 'Looking for : $barcode',
          ),
        ),
        actions: <SmoothSimpleButton>[
          SmoothSimpleButton(
            text: 'Stop',
            important: false,
            onPressed: () => _popSearchingDialog(null),
          ),
        ],
      );

  void openProductNotFoundDialog() => showDialog<Widget>(
        context: context,
        builder: (BuildContext context) {
          return SmoothAlertDialog(
            close: false,
            body: Text(
              refresh
                  ? 'Could not refresh product'
                  : 'No product found with matching barcode : $barcode',
            ),
            actions: <SmoothSimpleButton>[
              SmoothSimpleButton(
                text: 'Close',
                important: false,
                onPressed: () => Navigator.pop(context),
              ),
              SmoothSimpleButton(
                text: 'Contribute',
                important: true,
                onPressed: () => Navigator.pop(
                    context), // TODO(monsieurtanuki): to be implemented
              ),
            ],
          );
        },
      );
}
