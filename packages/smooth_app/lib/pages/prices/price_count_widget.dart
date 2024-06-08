import 'package:flutter/material.dart';
import 'package:smooth_app/pages/prices/price_button.dart';

/// Price Count display.
class PriceCountWidget extends StatelessWidget {
  const PriceCountWidget(this.count);

  final int count;

  @override
  Widget build(BuildContext context) => PriceButton(
        onPressed: null,
        iconData: Icons.label,
        title: '$count',
        buttonStyle: ElevatedButton.styleFrom(
          disabledForegroundColor: _getForegroundColor(),
          disabledBackgroundColor: _getBackgroundColor(),
        ),
      );

  Color? _getForegroundColor() => switch (count) {
        0 => Colors.red,
        1 => Colors.orange,
        _ => Colors.green,
      };

  Color? _getBackgroundColor() => switch (count) {
        0 => Colors.red[100],
        1 => Colors.orange[100],
        _ => Colors.green[100],
      };
}
