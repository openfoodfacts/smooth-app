import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';

/// Text field that displays a read-only amount for an existing price.
class PriceExistingAmountField extends StatelessWidget {
  const PriceExistingAmountField({
    required this.value,
    required this.pricePer,
  });

  final num? value;
  final PricePer? pricePer;

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    controller.text = value == null ? '' : '$value${_getPricePer()}';
    return SmoothTextFormField(
      type: TextFieldTypes.PLAIN_TEXT,
      controller: controller,
      enabled: false,
      hintText: '',
    );
  }

  // TODO(monsieurtanuki): localize
  String? _getPricePer() => switch (pricePer) {
        null => '',
        PricePer.kilogram => ' / kg',
        PricePer.unit => ' / unit'
      };
}
