import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

/// A widget showing a barcode on screen
/// It simplifies the call to [BarcodeWidget]
class SmoothBarcodeWidget extends StatelessWidget {
  const SmoothBarcodeWidget({
    required this.barcode,
    required this.height,
    required this.color,
    this.backgroundColor,
    this.padding,
    super.key,
  }) : assert(barcode.length > 0);

  final String barcode;
  final double height;
  final Color color;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return Semantics(
      label: appLocalizations.barcode_accessibility_label(barcode),
      excludeSemantics: true,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: ColoredBox(
          color: backgroundColor ?? Colors.transparent,
          child: BarcodeWidget(
            padding: EdgeInsets.zero,
            data: barcode,
            barcode: _barcodeType,
            color: color,
            style: TextStyle(color: color),
            errorBuilder: (final BuildContext context, String? error) {
              return Container(
                width: double.infinity,
                height: height,
                padding: const EdgeInsets.symmetric(
                  horizontal: SMALL_SPACE,
                  vertical: SMALL_SPACE,
                ),
                color: Colors.grey.withValues(alpha: 0.2),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        icons.Warning(color: color),
                        const SizedBox(width: SMALL_SPACE),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              appLocalizations.barcode_probably_invalid,
                              style: TextStyle(color: color),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '<$barcode>',
                      style: TextStyle(
                        letterSpacing: 6.0,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                        color: color,
                      ),
                    ),
                  ],
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
}
