import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/price_amount_model.dart';

/// Text field that displays a single amount for price adding.
class PriceAmountField extends StatelessWidget {
  const PriceAmountField({
    required this.model,
    required this.isPaidPrice,
    required this.controller,
  });

  final PriceAmountModel model;
  final bool isPaidPrice;
  final TextEditingController controller;

  // TODO(monsieurtanuki): TextInputAction + focus
  static const TextInputType _priceTextInputType =
      TextInputType.numberWithOptions(signed: false, decimal: true);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothTextFormField(
      type: TextFieldTypes.PLAIN_TEXT,
      controller: controller,
      hintText: !isPaidPrice
          ? appLocalizations.prices_amount_price_not_discounted
          : model.promo
          ? appLocalizations.prices_amount_price_discounted
          : appLocalizations.prices_amount_price_normal,
      textInputType: _priceTextInputType,
      onChanged: (final String? value) {
        if (isPaidPrice) {
          model.paidPrice = value ?? '';
          return;
        }
        model.priceWithoutDiscount = value ?? '';
      },
      validator: (String? value) {
        if (isPaidPrice) {
          if (value == null || value.isEmpty) {
            return appLocalizations.prices_amount_price_mandatory;
          }
          final double? doubleValue = PriceAmountModel.validateDouble(value);
          if (doubleValue == null) {
            return appLocalizations.prices_amount_price_incorrect;
          }
          return null;
        }

        // price without discount: only visible if discounted.
        if (value == null || value.isEmpty) {
          return null;
        }
        final double? doubleValue = PriceAmountModel.validateDouble(value);
        if (doubleValue == null) {
          return appLocalizations.prices_amount_price_incorrect;
        }
        return null;
      },
    );
  }
}
