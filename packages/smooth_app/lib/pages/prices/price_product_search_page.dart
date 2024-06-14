import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/price_product_list_tile.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Product Search Page, for Prices.
class PriceProductSearchPage extends StatefulWidget {
  const PriceProductSearchPage({
    this.product,
  });

  final PriceMetaProduct? product;
  // TODO(monsieurtanuki): as a parameter, add a list of barcodes already there: we're not supposed to select twice the same product

  @override
  State<PriceProductSearchPage> createState() => _PriceProductSearchPageState();
}

class _PriceProductSearchPageState extends State<PriceProductSearchPage> {
  final TextEditingController _controller = TextEditingController();

  late PriceMetaProduct? _product = widget.product;

  // TODO(monsieurtanuki): TextInputAction + focus
  static const TextInputType _textInputType = TextInputType.number;

  @override
  void initState() {
    super.initState();
    _controller.text = _product?.barcode ?? '';
  }

  static const String _barcodeHint = '7300400481588';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    // TODO(monsieurtanuki): add WillPopScope2
    return SmoothScaffold(
      appBar: SmoothAppBar(
        centerTitle: false,
        leading: const SmoothBackButton(),
        title: Text(appLocalizations.prices_barcode_search_title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(LARGE_SPACE),
        child: Column(
          children: <Widget>[
            // TODO(monsieurtanuki): add a "clear" button
            // TODO(monsieurtanuki): add an automatic "validate barcode" feature (cf. https://en.wikipedia.org/wiki/International_Article_Number#Check_digit)
            SmoothTextFormField(
              type: TextFieldTypes.PLAIN_TEXT,
              controller: _controller,
              hintText: _barcodeHint,
              textInputType: _textInputType,
              onChanged: (_) async {
                final String barcode = _controller.text;
                final String cleanBarcode = _getCleanBarcode(barcode);
                if (barcode != cleanBarcode) {
                  setState(() => _controller.text = cleanBarcode);
                  return;
                }

                if (_product != null) {
                  setState(
                    () => _product = null,
                  );
                }

                final Product? product = await _localSearch(
                  barcode,
                  localDatabase,
                );
                if (product != null) {
                  setState(
                    () => _product = PriceMetaProduct.product(product),
                  );
                  return;
                }
              },
              onFieldSubmitted: (_) async {
                final String barcode = _controller.text;
                if (barcode.isEmpty) {
                  return;
                }

                final Product? product = await _serverSearch(
                  barcode,
                  localDatabase,
                  context,
                );
                if (product != null) {
                  setState(() => _product = PriceMetaProduct.product(product));
                }
              },
              prefixIcon: const Icon(CupertinoIcons.barcode),
              textInputAction: TextInputAction.search,
            ),
            if (_product != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: LARGE_SPACE),
                child: PriceProductListTile(
                  product: _product!,
                  trailingIconData: Icons.check_circle,
                  onPressed: () => Navigator.of(context).pop(_product),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<Product?> _localSearch(
    final String barcode,
    final LocalDatabase localDatabase,
  ) async =>
      DaoProduct(localDatabase).get(barcode);

  Future<Product?> _serverSearch(
    final String barcode,
    final LocalDatabase localDatabase,
    final BuildContext context,
  ) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final FetchedProduct? fetchAndRefreshed =
        await LoadingDialog.run<FetchedProduct>(
      future: ProductRefresher().silentFetchAndRefresh(
        localDatabase: localDatabase,
        barcode: barcode,
      ),
      context: context,
      title: appLocalizations.prices_barcode_search_running(barcode),
    );
    if (fetchAndRefreshed == null) {
      // the user probably cancelled
      return null;
    }
    if (fetchAndRefreshed.product == null) {
      if (context.mounted) {
        await LoadingDialog.error(
          context: context,
          title: fetchAndRefreshed.getErrorTitle(appLocalizations),
        );
      }
    }
    return fetchAndRefreshed.product;
  }

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
