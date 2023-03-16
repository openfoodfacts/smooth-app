import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/simple_input_page.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';

/// "Add simple input" button for user contribution.
class AddSimpleInputButton extends StatelessWidget {
  const AddSimpleInputButton({
    required this.product,
    required this.helper,
  });

  final Product product;
  final AbstractSimpleInputPageHelper helper;

  @override
  Widget build(BuildContext context) => addPanelButton(
        helper.getAddButtonLabel(AppLocalizations.of(context)),
        onPressed: () async {
          // ignore: use_build_context_synchronously
          if (!await ProductRefresher().checkIfLoggedIn(context)) {
            return;
          }
          // ignore: use_build_context_synchronously
          await Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => SimpleInputPage(
                helper: helper,
                product: product,
              ),
              fullscreenDialog: true,
            ),
          );
        },
      );
}
