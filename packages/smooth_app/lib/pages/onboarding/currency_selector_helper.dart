import 'package:flutter/cupertino.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

/// Helper for currency selection.
class CurrencySelectorHelper {
  factory CurrencySelectorHelper() {
    _instance ??= CurrencySelectorHelper._();
    return _instance!;
  }

  CurrencySelectorHelper._();

  static CurrencySelectorHelper? _instance;

  IconData get currencyIconData => CupertinoIcons.money_dollar_circle;

  Currency getSelected(String? code) {
    if (code != null) {
      for (final Currency currency in Currency.values) {
        if (currency.name == code) {
          return currency;
        }
      }
    }
    return Currency.values.first;
  }
}
