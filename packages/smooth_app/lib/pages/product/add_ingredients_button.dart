import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_ingredients_page.dart';
import 'package:smooth_app/pages/product/ocr_ingredients_helper.dart';

/// "Add ingredients" button for user contribution.
class AddIngredientsButton extends StatelessWidget {
  const AddIngredientsButton(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) => addPanelButton(
        AppLocalizations.of(context).score_add_missing_ingredients,
        onPressed: () async {
          if (!await ProductRefresher().checkIfLoggedIn(context)) {
            return;
          }
          await Navigator.push<bool>(
            context,
            MaterialPageRoute<bool>(
              builder: (BuildContext context) => EditOcrPage(
                product: product,
                helper: OcrIngredientsHelper(),
              ),
            ),
          );
        },
      );
}
