import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';

/// Text field that displays a read-only amount for an existing price.
class PriceExistingAmountField extends StatelessWidget {
  const PriceExistingAmountField({
    required this.value,
  });

  final num? value;

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    controller.text = value == null ? '' : '$value';
    return SmoothTextFormField(
      type: TextFieldTypes.PLAIN_TEXT,
      controller: controller,
      enabled: false,
      hintText: '',
    );
  }
}
