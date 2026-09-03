part of '../price_add_product_action.dart';

class _PriceAddProductActionBarcodeReader extends PriceAddProductAction {
  const _PriceAddProductActionBarcodeReader();

  @override
  String label(AppLocalizations appLocalizations) =>
      appLocalizations.prices_barcode_reader_action;

  @override
  Widget icon(BuildContext context) => const Icon(Icons.barcode_reader);

  @override
  Future<void> execute(BuildContext context) async {
    final UserPreferences userPreferences = context.read<UserPreferences>();

    final List<String>? barcodes;
    if (userPreferences.getFlag(
          UserPreferencesDevMode.userPreferencesFlagPricesReceiptMultiSelection,
        ) ??
        false) {
      barcodes = await Navigator.of(context).push<List<String>>(
        MaterialPageRoute<List<String>>(
          builder: (BuildContext context) => const PriceScanPage(
            // TODO(g123k): Reintroduce this feature
            latestScannedBarcode: null,
            isMultiProducts: true,
          ),
        ),
      );
    } else {
      final String? barcode = await showSingleBarcodeScanner(context);
      if (barcode == null) {
        return;
      }

      barcodes = <String>[barcode];
    }

    if (barcodes == null || barcodes.isEmpty) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    await _addBarcodesToList(barcodes, context);
  }
}
