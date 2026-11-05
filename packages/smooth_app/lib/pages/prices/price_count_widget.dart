import 'package:flutter/material.dart';

/// Price count helpers.
class PriceCountWidget {
  const PriceCountWidget._();

  static Color getForegroundColor(final int count) => switch (count) {
    0 => Colors.red,
    1 => Colors.orange,
    _ => Colors.green,
  };
}
