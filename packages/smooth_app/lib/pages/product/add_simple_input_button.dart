import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/pages/product/simple_input/simple_input_page_helpers.dart';

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
        onPressed: () async => ProductFieldSimpleEditor(helper).edit(
          isLoggedInMandatory: true,
          context: context,
          product: product,
        ),
      );
}
