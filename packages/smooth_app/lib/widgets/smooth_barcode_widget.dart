import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
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
            style: TextStyle(
              color: contentColor,
            ),
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
      case 13:
        return Barcode.ean13();
      default:
        return Barcode.code128();
    }
  }
}
