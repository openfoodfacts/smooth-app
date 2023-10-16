import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_floating_message.dart';

class ProductAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ProductAppBar(
      {required this.barcodeVisibleInAppbar,
      required this.productName,
      required this.productBrand,
      required this.barcode});

  final String productName;
  final String productBrand;
  final String barcode;
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

    return SmoothAppBar(
      centerTitle: false,
      leading: const SmoothBackButton(),
      title: Semantics(
        value: widget.productName,
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AutoSizeText(
                '${widget.productName.trim()}, ${widget.productBrand.trim()}',
                minFontSize:
                    theme.textTheme.titleLarge?.fontSize?.clamp(13.0, 17.0) ??
                        13.0,
                maxLines: !widget.barcodeVisibleInAppbar ? 2 : 1,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              if (widget.barcode.isNotEmpty)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: widget.barcodeVisibleInAppbar ? 14.0 : 0.0,
                  child: Text(
                    widget.barcode,
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
                  ClipboardData(text: widget.barcode),
                );

                SmoothFloatingMessage(
                  message:
                      appLocalizations.clipboard_barcode_copied(widget.barcode),
                ).show(context, alignment: AlignmentDirectional.bottomCenter);
              },
            );
          }),
        )
      ],
    );
  }
}
