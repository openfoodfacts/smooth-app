import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_floating_message.dart';

class ProductAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ProductAppBar({
    required this.barcodeVisibleInAppbar,
    required this.product,
  });

  final Product product;
  final bool barcodeVisibleInAppbar;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<ProductAppBar> createState() => _ProductAppBarState();
}

class _ProductAppBarState extends State<ProductAppBar> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final String productName = getProductName(
      widget.product,
      appLocalizations,
    );
    final String productBrand =
        getProductBrands(widget.product, appLocalizations);
    final String barcode = widget.product.barcode ?? '';

    return SmoothAppBar(
      centerTitle: false,
      leading: const SmoothBackButton(),
      title: Semantics(
        value: widget.product.productName,
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AutoSizeText(
                '${productName.trim()}, ${productBrand.trim()}',
                minFontSize:
                    theme.textTheme.titleLarge?.fontSize?.clamp(13.0, 17.0) ??
                        13.0,
                maxLines: !widget.barcodeVisibleInAppbar ? 2 : 1,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              if (barcode.isNotEmpty)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: widget.barcodeVisibleInAppbar ? 14.0 : 0.0,
                  child: Text(
                    barcode,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        Semantics(
          button: true,
          value: appLocalizations.clipboard_barcode_copy,
          excludeSemantics: true,
          child: Builder(builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.copy),
              tooltip: appLocalizations.clipboard_barcode_copy,
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: barcode),
                );

                SmoothFloatingMessage(
                  message: appLocalizations.clipboard_barcode_copied(barcode),
                ).show(context, alignment: AlignmentDirectional.bottomCenter);
              },
            );
          }),
        )
      ],
    );
  }
}
