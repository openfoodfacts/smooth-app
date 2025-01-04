import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/price_button.dart';

/// Price Count display.
class PriceCountWidget extends StatelessWidget {
  const PriceCountWidget({
    required this.count,
    required this.onPressed,
  });

  final int count;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => PriceButton(
        onPressed: onPressed,
        iconData: PriceButton.priceIconData,
        title: '$count',
        buttonStyle: ElevatedButton.styleFrom(
          disabledForegroundColor:
              onPressed != null ? null : _getForegroundColor(count),
          disabledBackgroundColor:
              onPressed != null ? null : _getBackgroundColor(count),
          foregroundColor:
              onPressed == null ? null : _getForegroundColor(count),
          backgroundColor:
              onPressed == null ? null : _getBackgroundColor(count),
        ),
        tooltip: AppLocalizations.of(context).prices_button_count_price(
          count,
        ),
      );

  static Color? _getForegroundColor(final int count) => switch (count) {
        0 => Colors.red,
        1 => Colors.orange,
        _ => Colors.green,
      };

  static Color? _getBackgroundColor(final int count) => switch (count) {
        0 => Colors.red[100],
        1 => Colors.orange[100],
        _ => Colors.green[100],
      };
}
