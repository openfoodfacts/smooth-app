import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/helpers/border_radius_helper.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_barcode_widget.dart';

class EditProductBarcode extends StatefulWidget {
  EditProductBarcode({
    required this.barcode,
  })  : assert(barcode.isNotEmpty == true),
        assert(isAValidBarcode(barcode));

  static const double barcodeHeight = 120.0;

  final String barcode;

  @override
  State<EditProductBarcode> createState() => _EditProductBarcodeState();

  static bool isAValidBarcode(String? barcode) =>
      barcode != null && <int>[7, 8, 12, 13].contains(barcode.length);

  static Color borderColor = const Color(0xFFC3C3C3);
}

class _EditProductBarcodeState extends State<EditProductBarcode> {
  bool _isAnInvalidBarcode = false;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    final Color color = context.lightTheme()
        ? EditProductBarcode.borderColor
        : extension.primaryLight;

    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          top: VERY_SMALL_SPACE,
          bottom: SMALL_SPACE,
          start: SMALL_SPACE,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              ExcludeSemantics(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusHelper.fromDirectional(
                      context: context,
                      topStart: ROUNDED_RADIUS,
                      bottomStart: ROUNDED_RADIUS,
                      topEnd: ROUNDED_RADIUS,
                    ),
                    border: Border.all(
                      color: color,
                      width: 2.0,
                    ),
                    color: Colors.white70,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: screenSize.width / 1.4,
                      maxHeight: 120.0,
                    ),
                    child: SmoothBarcodeWidget(
                      padding: const EdgeInsetsDirectional.only(
                        top: MEDIUM_SPACE,
                        start: 14.0,
                        end: 19.0,
                        bottom: MEDIUM_SPACE,
                      ),
                      color: context.lightTheme() ? Colors.black : Colors.white,
                      barcode: widget.barcode,
                      onInvalidBarcode: () {
                        if (!_isAnInvalidBarcode) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() => _isAnInvalidBarcode = true);
                          });
                        }
                      },
                      height: _isAnInvalidBarcode
                          ? null
                          : EditProductBarcode.barcodeHeight,
                    ),
                  ),
                ),
              ),
              _EditProductBarcodeCopyButton(
                barcode: widget.barcode,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditProductBarcodeCopyButton extends StatelessWidget {
  const _EditProductBarcodeCopyButton({
    required this.barcode,
    required this.color,
  });

  final String barcode;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final BorderRadius borderRadius = BorderRadiusHelper.fromDirectional(
      context: context,
      bottomEnd: ROUNDED_RADIUS,
      topEnd: ROUNDED_RADIUS,
    );

    return Ink(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: color,
      ),
      child: Tooltip(
        message: appLocalizations.clipboard_barcode_copy,
        child: InkWell(
          borderRadius: borderRadius,
          splashColor: Colors.white54,
          child: const Padding(
            padding: EdgeInsetsDirectional.only(
              start: 6.0,
              end: 13.0,
              top: SMALL_SPACE,
              bottom: 9.0,
            ),
            child: Icon(Icons.copy),
          ),
          onTap: () {
            Clipboard.setData(
              ClipboardData(text: barcode),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SmoothFloatingSnackbar.positive(
                context: context,
                text: appLocalizations.clipboard_barcode_copied(barcode),
              ),
            );
          },
        ),
      ),
    );
  }
}
