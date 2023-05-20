import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_new_packagings.dart';
import 'package:smooth_app/pages/product/ocr_packaging_helper.dart';

/// "Add (new) packaging" button for user contribution.
class AddPackagingButton extends StatelessWidget {
  const AddPackagingButton({
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) => addPanelButton(
        OcrPackagingHelper().getAddButtonLabel(AppLocalizations.of(context)),
        onPressed: () async {
          // ignore: use_build_context_synchronously
          if (!await ProductRefresher().checkIfLoggedIn(context)) {
            return;
          }
          // ignore: use_build_context_synchronously
          await Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => EditNewPackagings(
                product: product,
              ),
              fullscreenDialog: true,
            ),
          );
        },
      );
}
