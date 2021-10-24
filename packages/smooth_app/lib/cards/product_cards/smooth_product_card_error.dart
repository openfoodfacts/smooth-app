import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/common/product_dialog_helper.dart';

/// Product Card when an exception is caught
class SmoothProductCardError extends StatelessWidget {
  const SmoothProductCardError({required this.barcode});

  final String barcode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(barcode, style: Theme.of(context).textTheme.subtitle1),
            ],
          ),
          const SizedBox(
            height: 12.0,
          ),
          ProductDialogHelper.getErrorMessage(
            AppLocalizations.of(context)!.product_internet_error,
          ),
        ],
      ),
    );
  }
}
