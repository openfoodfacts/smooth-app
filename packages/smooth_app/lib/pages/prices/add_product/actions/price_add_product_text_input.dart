part of '../price_add_product_action.dart';

class _PriceAddProductActionBarcodeInput extends PriceAddProductAction {
  const _PriceAddProductActionBarcodeInput();

  @override
  String label(AppLocalizations appLocalizations) =>
      appLocalizations.prices_barcode_enter;

  @override
  Widget icon(BuildContext context) => const Icon(Icons.text_fields);

  @override
  Future<void> execute(BuildContext context) async {
    final String? barcode = await _textInput(context);
    if (barcode == null) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    await _addBarcodesToList(<String>[barcode], context);
  }

  Future<String?> _textInput(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return showDialog<String>(
      context: context,
      builder: (final BuildContext context) => StatefulBuilder(
        builder:
            (
              final BuildContext context,
              void Function(VoidCallback fn) setState,
            ) => SmoothAlertDialog(
              title: appLocalizations.prices_add_an_item,
              body: SmoothTextFormField(
                autofocus: true,
                type: TextFieldTypes.PLAIN_TEXT,
                controller: controller,
                hintText: appLocalizations.barcode,
                textInputType: TextInputType.number,
                onChanged: (_) {
                  final String barcode = controller.text;
                  final String cleanBarcode = _getCleanBarcode(barcode);
                  setState(() => controller.text = cleanBarcode);
                },
                onFieldSubmitted: (_) => !_isValidBarcode(controller.text)
                    ? null
                    : Navigator.of(context).pop(controller.text),
              ),
              positiveAction: SmoothActionButton(
                text: appLocalizations.validate,
                onPressed: !_isValidBarcode(controller.text)
                    ? null
                    : () => Navigator.of(context).pop(controller.text),
              ),
              negativeAction: SmoothActionButton(
                text: appLocalizations.cancel,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
      ),
    );
  }

  bool _isValidBarcode(final String barcode) => barcode.length >= 8;

  // Probably there's a regexp for that, but at least it's readable code.
  String _getCleanBarcode(final String input) {
    const int ascii0 = 48;
    const int ascii9 = 48 + 10 - 1;

    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final int charCode = input.codeUnitAt(i);
      if (charCode >= ascii0 && charCode <= ascii9) {
        buffer.writeCharCode(charCode);
      }
    }
    return buffer.toString();
  }
}
