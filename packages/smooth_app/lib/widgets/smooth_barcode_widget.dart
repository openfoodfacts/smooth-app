import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/services/smooth_services.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// A widget showing a barcode on screen
/// It simplifies the call to [BarcodeWidget]
class SmoothBarcodeWidget extends StatelessWidget {
  const SmoothBarcodeWidget({
    required this.barcode,
    this.errorBuilder,
    this.backgroundColor,
    this.color,
    this.height,
    this.padding,
    this.onInvalidBarcode,
    super.key,
  }) : assert(barcode.length > 0);

  final String barcode;
  final Color? color;
  final Color? backgroundColor;
  final double? height;
  final WidgetBuilder? errorBuilder;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onInvalidBarcode;

  @override
  Widget build(BuildContext context) {
    final Color contentColor =
        color ?? (context.lightTheme() ? Colors.black : Colors.white);
     if (!_hasValidChecksum) {
      onInvalidBarcode?.call();
      Logs.e('Invalid barcode checksum: $barcode');
      if (errorBuilder != null) return errorBuilder!(context);
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SMALL_SPACE,
            vertical: SMALL_SPACE,
          ),
          color: Colors.grey.withValues(alpha: 0.2),
          child: Text(
            '<$barcode>',
            style: TextStyle(
              letterSpacing: 6.0,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              color: contentColor,
            ),
          ),
        ),
      );
    }
    return Semantics(
      label: AppLocalizations.of(context).barcode_accessibility_label(barcode),
      excludeSemantics: true,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: ColoredBox(
          color: backgroundColor ?? Colors.transparent,
          child: BarcodeWidget(
               padding: EdgeInsets.zero,
               data: barcode,
               barcode: _barcodeType,
            color: color ?? Colors.black,
            style: TextStyle(color: contentColor),
            errorBuilder: (final BuildContext context, String? error) {
              onInvalidBarcode?.call();

              Logs.e('Error with barcode: $barcode', ex: error);

              if (errorBuilder != null) {
                return errorBuilder!(context);
              }

              return Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SMALL_SPACE,
                    vertical: SMALL_SPACE,
                  ),
                  color: Colors.grey.withValues(alpha: 0.2),
                  child: Text(
                    '<$barcode>',
                    style: TextStyle(
                      letterSpacing: 6.0,
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                      color: contentColor,
                    ),
                  ),
                ),
              );
            },
            height: height,
          ),
        ),
      ),
    );
  }

  Barcode get _barcodeType {
    switch (barcode.length) {
      case 7:
      case 8:
        return Barcode.ean8();
      case 12:
        return Barcode.upcA();
      case 13:
        return Barcode.ean13();
      default:
        return Barcode.code128();
    }
  }
bool get _hasValidChecksum {
    if (barcode.length != 8 && barcode.length != 13) return true;
    if (!RegExp(r'^\d+$').hasMatch(barcode)) return false;
    int sum = 0;
    for (int i = 0; i < barcode.length - 1; i++) {
      final int digit = int.parse(barcode[i]);
      if (barcode.length == 8) {
        sum += (i % 2 == 0) ? digit * 3 : digit;
      } else {
        sum += (i % 2 == 0) ? digit : digit * 3;
      }
    }
    final int expected = (10 - (sum % 10)) % 10;
    return expected == int.parse(barcode[barcode.length - 1]);
  }
}