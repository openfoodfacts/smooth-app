import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_barcode_widget.dart';

class EditProductBarcode extends StatefulWidget {
  EditProductBarcode({
    required this.barcode,
  })  : assert(barcode.isNotEmpty == true),
        assert(isAValidBarcode(barcode));

  static const double barcodeHeight = 110.0;

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
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothCardWithRoundedHeader(
      title: appLocalizations.barcode,
      leading: const Barcode.rounded(),
      trailing: _EditProductBarcodeCopyButton(barcode: widget.barcode),
      titlePadding: const EdgeInsetsDirectional.only(
        top: 2.0,
        start: LARGE_SPACE,
        end: SMALL_SPACE,
        bottom: 2.0,
      ),
      contentPadding: const EdgeInsetsDirectional.only(
        top: SMALL_SPACE,
        bottom: VERY_SMALL_SPACE,
      ),
      child: MergeSemantics(
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            top: VERY_SMALL_SPACE,
            bottom: SMALL_SPACE,
            start: SMALL_SPACE,
          ),
          child: Center(
            child: FractionallySizedBox(
              widthFactor: 0.65,
              child: SmoothBarcodeWidget(
                padding: EdgeInsets.zero,
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
      ),
    );
  }
}

class _EditProductBarcodeCopyButton extends StatelessWidget {
  const _EditProductBarcodeCopyButton({
    required this.barcode,
  });

  final String barcode;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothCardHeaderButton(
      tooltip: appLocalizations.clipboard_barcode_copy,
      child: const Icon(Icons.copy),
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
    );
  }
}
