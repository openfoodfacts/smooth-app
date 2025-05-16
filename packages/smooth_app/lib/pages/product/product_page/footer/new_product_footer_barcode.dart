import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_barcode_widget.dart';

class ProductFooterBarcodeButton extends StatelessWidget {
  const ProductFooterBarcodeButton();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ProductFooterButton(
      label: appLocalizations.product_footer_action_barcode,
      semanticsLabel: appLocalizations.product_footer_action_barcode,
      icon: const icons.Barcode.rounded(),
      onTap: () => _openBarcode(context, context.read<Product>().barcode!),
    );
  }

  Future<void> _openBarcode(BuildContext context, String barcode) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    showSmoothModalSheet(
      context: context,
      builder: (BuildContext context) => SmoothModalSheet(
        title: appLocalizations.barcode,
        prefixIndicator: true,
        headerBackgroundColor: context.lightTheme()
            ? context.extension<SmoothColorsThemeExtension>().primaryBlack
            : null,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              FractionallySizedBox(
                widthFactor: 0.65,
                child: SmoothBarcodeWidget(
                  padding: EdgeInsets.zero,
                  color: context.lightTheme() ? Colors.black : Colors.white,
                  barcode: barcode,
                  height: 110.0,
                ),
              ),
              const SizedBox(height: LARGE_SPACE),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  Clipboard.setData(
                    ClipboardData(text: barcode),
                  );

                  SmoothHapticFeedback.click();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SmoothFloatingSnackbar.positive(
                      context: context,
                      margin: EdgeInsetsDirectional.only(
                        start: SMALL_SPACE,
                        end: SMALL_SPACE,
                        bottom: ProductFooter.kHeight +
                            MediaQuery.viewPaddingOf(context).bottom,
                      ),
                      text: appLocalizations.clipboard_barcode_copied(barcode),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const icons.Copy(),
                    const SizedBox(width: SMALL_SPACE),
                    Text(appLocalizations.clipboard_barcode_copy),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
