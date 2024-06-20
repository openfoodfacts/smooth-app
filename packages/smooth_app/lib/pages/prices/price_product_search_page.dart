import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/price_product_list_tile.dart';
import 'package:smooth_app/pages/prices/price_scan_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Product Search Page, for Prices.
class PriceProductSearchPage extends StatefulWidget {
  const PriceProductSearchPage({
    required this.barcodes,
  });

  /// List of barcodes already in the list.
  final List<String> barcodes;

  /// "Should we check the server?", saved here at the session level.
  static bool? checkServer;

  @override
  State<PriceProductSearchPage> createState() => _PriceProductSearchPageState();
}

class _PriceProductSearchPageState extends State<PriceProductSearchPage> {
  late final TextEditingController _controller;

  PriceMetaProduct? _product;
  late FocusNode _focusNode;

  static const TextInputType _textInputType = TextInputType.number;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '');
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  static const String _barcodeHint = '7300400481588';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final PriceMetaProduct priceMetaProduct =
        _product ?? PriceMetaProduct.unknown(_controller.text);
    // TODO(monsieurtanuki): add WillPopScope2
    return SmoothScaffold(
      appBar: SmoothAppBar(
        centerTitle: false,
        leading: const SmoothBackButton(),
        title: Text(appLocalizations.prices_barcode_search_title),
      ),
      floatingActionButton: !CameraHelper.hasACamera
          ? null
          : FloatingActionButton.extended(
              onPressed: () async => _scan(context),
              label: Text(appLocalizations.prices_barcode_reader_action),
              icon: const Icon(Icons.barcode_reader),
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(LARGE_SPACE),
        child: Column(
          children: <Widget>[
            // TODO(monsieurtanuki): add a "clear" button
            // TODO(monsieurtanuki): add an automatic "validate barcode" feature (cf. https://en.wikipedia.org/wiki/International_Article_Number#Check_digit)
            SmoothTextFormField(
              focusNode: _focusNode,
              type: TextFieldTypes.PLAIN_TEXT,
              controller: _controller,
              hintText: _barcodeHint,
              textInputType: _textInputType,
              onChanged: (_) async => _onChanged(context),
              onFieldSubmitted: (_) async => _onFieldSubmitted(context),
              prefixIcon: const Icon(CupertinoIcons.barcode),
              textInputAction: TextInputAction.search,
              validator: (final String? value) {
                if (value == null || value.isEmpty) {
                  return null;
                }
                if (widget.barcodes.contains(value)) {
                  return appLocalizations.prices_barcode_already(value);
                }
                return null;
              },
            ),
            if (priceMetaProduct.isValid &&
                !widget.barcodes.contains(priceMetaProduct.barcode))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: LARGE_SPACE),
                child: PriceProductListTile(
                  product: priceMetaProduct,
                  trailingIconData: Icons.check_circle,
                  onPressed: () => Navigator.of(context).pop(priceMetaProduct),
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

  Future<void> _onChanged(final BuildContext context) async {
    final String barcode = _controller.text;
    final String cleanBarcode = _getCleanBarcode(barcode);
    if (barcode != cleanBarcode) {
      setState(() => _controller.text = cleanBarcode);
      return;
    }

    if (_product != null) {
      setState(() => _product = null);
    }

    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final Product? product = await _localSearch(
      barcode,
      localDatabase,
    );
    if (product != null) {
      setState(() => _product = PriceMetaProduct.product(product));
      return;
    }
    setState(() {});
  }

  Future<void> _onFieldSubmitted(final BuildContext context) async {
    final String barcode = _controller.text;
    if (barcode.isEmpty) {
      return;
    }

    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final Product? product = await _serverSearch(
      barcode,
      localDatabase,
      context,
    );
    if (product != null) {
      setState(() => _product = PriceMetaProduct.product(product));
    }
  }

  Future<void> _scan(final BuildContext context) async {
    final String? barcode = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (BuildContext context) => const PriceScanPage(),
      ),
    );
    if (barcode == null) {
      return;
    }
    _controller.text = barcode;
    if (!context.mounted) {
      return;
    }
    _focusNode.requestFocus();
    await _onChanged(context);
    if (_product != null) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final bool accepts = await _shouldCheckServer();
    if (!context.mounted) {
      return;
    }
    if (accepts != true) {
      return;
    }
    await _onFieldSubmitted(context);
  }

  Future<bool> _shouldCheckServer() async {
    if (PriceProductSearchPage.checkServer != null) {
      return PriceProductSearchPage.checkServer!;
    }
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    bool remember = false;
    final bool? accepts = await showDialog(
      context: context,
      builder: (final BuildContext context) => StatefulBuilder(
        builder: (
          BuildContext context,
          void Function(VoidCallback fn) setState,
        ) =>
            SmoothAlertDialog(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                title: Text(appLocalizations.prices_barcode_search_question),
              ),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: remember,
                title: Text(appLocalizations.remember_my_choice_session),
                onChanged: (_) => setState(() => remember = !remember),
              ),
            ],
          ),
          neutralAction: SmoothActionButton(
            text: appLocalizations.cancel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          positiveAction: SmoothActionButton(
            text: appLocalizations.yes,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ),
      ),
    );
    if (accepts == null) {
      return false;
    }
    if (remember) {
      PriceProductSearchPage.checkServer = accepts;
    }
    return accepts;
  }
}
