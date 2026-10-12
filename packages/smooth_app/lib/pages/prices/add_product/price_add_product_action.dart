import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/prices/price_amount_model.dart';
import 'package:smooth_app/pages/prices/price_category_input_page.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/prices/price_scan_modal.dart';
import 'package:smooth_app/pages/prices/price_scan_page.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

part 'actions/price_add_product_barcode_reader.dart';
part 'actions/price_add_product_category.dart';
part 'actions/price_add_product_text_input.dart';

sealed class PriceAddProductAction {
  const PriceAddProductAction();

  String label(AppLocalizations appLocalizations);

  Widget icon(BuildContext context);

  Future<void> execute(BuildContext context);
}

List<PriceAddProductAction> get priceAddProductActions =>
    <PriceAddProductAction>[
      const _PriceAddProductActionBarcodeReader(),
      const _PriceAddProductActionBarcodeInput(),
      const _PriceAddProductActionCategoryInput(),
    ];

Future<void> _addBarcodesToList(
  final List<String> barcodes,
  final BuildContext context,
) async {
  final AppLocalizations appLocalizations = AppLocalizations.of(context);
  final LocalDatabase localDatabase = context.read<LocalDatabase>();
  final PriceModel priceModel = Provider.of<PriceModel>(context, listen: false);

  bool barcodeAlreadyThere(final String barcode) {
    for (int i = 0; i < priceModel.length; i++) {
      final PriceAmountModel model = priceModel.elementAt(i);
      if (model.product.barcode == barcode) {
        return true;
      }
    }
    if (priceModel.existingPrices != null) {
      for (final Price price in priceModel.existingPrices!) {
        if (price.productCode == barcode) {
          return true;
        }
      }
    }
    return false;
  }

  final List<String> alreadyThere = <String>[];
  final List<String> notThere = <String>[];
  for (final String barcode in barcodes) {
    if (barcodeAlreadyThere(barcode)) {
      alreadyThere.add(barcode);
    } else {
      notThere.add(barcode);
    }
  }

  if (notThere.isNotEmpty) {
    for (final String barcode in notThere) {
      _addProductToList(
        priceModel,
        PriceMetaProduct.unknown(barcode, localDatabase, priceModel),
        context,
      );
    }
    priceModel.notifyListeners();
  }

  for (final String barcode in alreadyThere) {
    if (!context.mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (final BuildContext context) => SmoothAlertDialog(
        body: Text(appLocalizations.prices_barcode_already(barcode)),
        positiveAction: SmoothActionButton(
          text: appLocalizations.okay,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

void _addProductToList(
  final PriceModel priceModel,
  final PriceMetaProduct product,
  final BuildContext context,
) => priceModel.add(PriceAmountModel(product: product));
