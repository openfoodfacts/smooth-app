import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';

/// Model for the price of a single product.
class PriceAmountModel {
  PriceAmountModel({
    required this.product,
  });

  PriceMetaProduct product;

  String paidPrice = '';
  String priceWithoutDiscount = '';

  late double _checkedPaidPrice;
  double? _checkedPriceWithoutDiscount;

  double get checkedPaidPrice => _checkedPaidPrice;

  double? get checkedPriceWithoutDiscount => _checkedPriceWithoutDiscount;

  bool promo = false;

  static double? validateDouble(final String value) =>
      double.tryParse(value) ??
      double.tryParse(
        value.replaceAll(',', '.'),
      );

  String? checkParameters(final BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if (product.barcode.isEmpty) {
      return appLocalizations.prices_amount_no_product;
    }
    _checkedPaidPrice = validateDouble(paidPrice)!;
    _checkedPriceWithoutDiscount = null;
    if (promo) {
      if (priceWithoutDiscount.isNotEmpty) {
        _checkedPriceWithoutDiscount = validateDouble(priceWithoutDiscount);
        if (_checkedPriceWithoutDiscount == null) {
          return appLocalizations.prices_amount_price_incorrect;
        }
      }
    }
    return null;
  }
}
