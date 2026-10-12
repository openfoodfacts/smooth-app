import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/discount_type_extension.dart';

/// Text field that displays a read-only discount type for an existing price.
class PriceExistingDiscountTypeField extends StatelessWidget {
  const PriceExistingDiscountTypeField({required this.value, super.key});

  final DiscountType? value;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final TextEditingController controller = TextEditingController();
    controller.text = value == null ? '' : value!.getTitle(appLocalizations);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
      child: SmoothTextFormField(
        type: TextFieldTypes.PLAIN_TEXT,
        controller: controller,
        enabled: false,
        hintText: appLocalizations.prices_discount_type,
      ),
    );
  }
}
