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
    super.key,
  }) : assert(barcode.length > 0);

  final String barcode;
  final double height;

  @override
  Widget build(BuildContext context) {
    const Color color = Colors.black;
    const Color backgroundColor = Colors.white;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return Semantics(
      label: appLocalizations.barcode_accessibility_label(barcode),
      excludeSemantics: true,
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
        child: BarcodeWidget(
          padding: EdgeInsets.zero,
          data: barcode,
          barcode: _barcodeType,
          color: color,
          style: const TextStyle(color: color),
          errorBuilder: (final BuildContext context, String? error) {
            return Container(
              width: double.infinity,
              height: height,
              padding: const EdgeInsets.symmetric(
                horizontal: SMALL_SPACE,
                vertical: SMALL_SPACE,
              ),
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
                      const icons.Warning(color: color),
                      const SizedBox(width: SMALL_SPACE),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            appLocalizations.barcode_probably_invalid,
                            style: const TextStyle(color: color),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '<$barcode>',
                    style: const TextStyle(
                      letterSpacing: 6.0,
                      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
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
