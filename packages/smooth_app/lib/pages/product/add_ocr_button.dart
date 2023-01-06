import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_ingredients_page.dart';
import 'package:smooth_app/pages/product/ocr_helper.dart';

/// "Add OCR image" button for user contribution.
class AddOCRButton extends StatelessWidget {
  const AddOCRButton({
    required this.product,
    required this.helper,
  });

  final Product product;
  final OcrHelper helper;

  @override
  Widget build(BuildContext context) => addPanelButton(
        helper.getAddButtonLabel(AppLocalizations.of(context)),
        onPressed: () async {
          if (!await ProductRefresher().checkIfLoggedIn(context)) {
            return;
          }
          await Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => EditOcrPage(
                product: product,
                helper: helper,
              ),
            ),
          );
        },
      );
}
