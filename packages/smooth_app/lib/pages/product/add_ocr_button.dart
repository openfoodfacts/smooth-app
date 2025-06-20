import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';

/// "Add OCR image" button for user contribution.
class AddOcrButton extends StatelessWidget {
  const AddOcrButton({
    required this.product,
    required this.editor,
  });

  final Product product;
  final ProductFieldOcrEditor editor;

  @override
  Widget build(BuildContext context) => addPanelButton(
        editor.getLabel(AppLocalizations.of(context)),
        onPressed: () async => editor.edit(context: context, product: product),
      );
}
