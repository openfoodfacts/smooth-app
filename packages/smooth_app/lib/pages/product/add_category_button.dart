import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/simple_input_page.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';

/// "Add category" button for user contribution.
class AddCategoryButton extends StatelessWidget {
  const AddCategoryButton(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) => addPanelButton(
        AppLocalizations.of(context).score_add_missing_product_category,
        onPressed: () async {
          if (!await ProductRefresher().checkIfLoggedIn(context)) {
            return;
          }
          await Navigator.push<Product>(
            context,
            MaterialPageRoute<Product>(
              builder: (BuildContext context) => SimpleInputPage(
                helper: SimpleInputPageCategoryHelper(),
                product: product,
              ),
            ),
          );
        },
      );
}
