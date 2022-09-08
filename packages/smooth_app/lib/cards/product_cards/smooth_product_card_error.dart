import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_base_card.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/product/common/product_dialog_helper.dart';

/// Product Card when an exception is caught
class SmoothProductCardError extends StatelessWidget {
  const SmoothProductCardError({
    required this.barcode,
    required this.errorType,
  });

  final String barcode;
  final ScannedProductState errorType;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothProductBaseCard(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/misc/error.svg',
            width: MINIMUM_TOUCH_SIZE * 2,
          ),
          const SizedBox(
            height: SMALL_SPACE,
          ),
          Text(
            barcode,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          const SizedBox(
            height: MEDIUM_SPACE,
          ),
          ProductDialogHelper.getErrorMessage(
            _getErrorMessage(
              errorType,
              appLocalizations,
            ),
          ),
          const SizedBox(
            height: MEDIUM_SPACE,
          ),
          ElevatedButton(
            onPressed: () async {
              await context
                  .read<ContinuousScanModel>()
                  .retryBarcodeFetch(barcode);
            },
            child: Text(appLocalizations.retry_button_label),
          ),
        ],
      ),
    );
  }

  String _getErrorMessage(
    ScannedProductState errorType,
    AppLocalizations appLocalizations,
  ) {
    switch (errorType) {
      case ScannedProductState.ERROR_INVALID_CODE:
        return appLocalizations.barcode_invalid_error;
      case ScannedProductState.ERROR_INTERNET:
        return appLocalizations.product_internet_error;
      default:
        return appLocalizations.error_occurred;
    }
  }
}
