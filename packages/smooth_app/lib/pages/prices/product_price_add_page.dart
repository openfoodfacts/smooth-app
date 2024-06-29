import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/dao_osm_location.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/prices/price_amount_card.dart';
import 'package:smooth_app/pages/prices/price_amount_model.dart';
import 'package:smooth_app/pages/prices/price_currency_card.dart';
import 'package:smooth_app/pages/prices/price_date_card.dart';
import 'package:smooth_app/pages/prices/price_location_card.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/prices/price_product_search_page.dart';
import 'package:smooth_app/pages/prices/price_proof_card.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Single page that displays all the elements of price adding.
class ProductPriceAddPage extends StatefulWidget {
  const ProductPriceAddPage({
    required this.product,
    required this.latestOsmLocations,
    required this.proofType,
  });

  final PriceMetaProduct product;
  final List<OsmLocation> latestOsmLocations;
  final ProofType proofType;

  static Future<void> showProductPage({
    required final BuildContext context,
    required final PriceMetaProduct product,
    required final ProofType proofType,
  }) async {
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: true,
    )) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final List<OsmLocation> osmLocations =
        await DaoOsmLocation(localDatabase).getAll();
    if (!context.mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ProductPriceAddPage(
          product: product,
          latestOsmLocations: osmLocations,
          proofType: proofType,
        ),
      ),
    );
  }

  @override
  State<ProductPriceAddPage> createState() => _ProductPriceAddPageState();
}

class _ProductPriceAddPageState extends State<ProductPriceAddPage>
    with TraceableClientMixin {
  late final PriceModel _model = PriceModel(
    proofType: widget.proofType,
    locations: widget.latestOsmLocations,
    product: widget.product,
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int? _latestAddedItem;
  FocusNode? _latestFocusNode;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    // TODO(monsieurtanuki): add WillPopScope2
    return ChangeNotifierProvider<PriceModel>(
      create: (_) => _model,
      child: Form(
        key: _formKey,
        child: SmoothScaffold(
          appBar: SmoothAppBar(
            centerTitle: false,
            leading: const SmoothBackButton(),
            title: Text(
              appLocalizations.prices_add_n_prices(
                _model.priceAmountModels.length,
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.info),
                onPressed: () async => _doesAcceptWarning(justInfo: true),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(LARGE_SPACE),
            child: Column(
              children: <Widget>[
                const PriceProofCard(),
                const SizedBox(height: LARGE_SPACE),
                const PriceDateCard(),
                const SizedBox(height: LARGE_SPACE),
                const PriceLocationCard(),
                const SizedBox(height: LARGE_SPACE),
                const PriceCurrencyCard(),
                const SizedBox(height: LARGE_SPACE),
                for (int i = 0; i < _model.priceAmountModels.length; i++)
                  PriceAmountCard(
                    key: Key(_model.priceAmountModels[i].product.barcode),
                    priceModel: _model,
                    index: i,
                    refresh: () => setState(() {}),
                    focusNode: _latestAddedItem == i ? _latestFocusNode : null,
                  ),
                if (_model.priceAmountModels.isNotEmpty &&
                    _model.priceAmountModels.first.product.barcode.isNotEmpty)
                  SmoothCard(
                    child: SmoothLargeButtonWithIcon(
                      text: appLocalizations.prices_add_an_item,
                      icon: Icons.add,
                      onPressed: () async {
                        final PriceMetaProduct? product =
                            await Navigator.of(context).push<PriceMetaProduct>(
                          MaterialPageRoute<PriceMetaProduct>(
                            builder: (BuildContext context) =>
                                PriceProductSearchPage(
                              barcodes: _model.getBarcodes(),
                            ),
                          ),
                        );
                        if (product == null) {
                          return;
                        }
                        setState(
                          () {
                            _model.priceAmountModels.add(
                              PriceAmountModel(
                                product: product,
                              ),
                            );
                            _latestAddedItem =
                                _model.priceAmountModels.length - 1;
                            _latestFocusNode?.dispose();
                            _latestFocusNode = FocusNode();
                            _latestFocusNode!.requestFocus();
                          },
                        );
                      },
                    ),
                  ),
                // so that the last items don't get hidden by the FAB
                const SizedBox(height: MINIMUM_TOUCH_SIZE * 2),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              if (!await _check(context)) {
                return;
              }
              if (!context.mounted) {
                return;
              }

              final UserPreferences userPreferences =
                  context.read<UserPreferences>();
              const String flagTag = UserPreferences.TAG_PRICE_PRIVACY_WARNING;
              final bool? already = userPreferences.getFlag(flagTag);
              if (already != true) {
                final bool? accepts = await _doesAcceptWarning(justInfo: false);
                if (accepts != true) {
                  return;
                }
                await userPreferences.setFlag(flagTag, true);
              }
              if (!context.mounted) {
                return;
              }

              await _model.addTask(context);
              if (!context.mounted) {
                return;
              }
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.send),
            label: Text(
              appLocalizations.prices_send_n_prices(
                _model.priceAmountModels.length,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _doesAcceptWarning({required final bool justInfo}) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (final BuildContext context) => SmoothAlertDialog(
        title: appLocalizations.prices_privacy_warning_title,
        actionsAxis: Axis.vertical,
        body: Text(appLocalizations.prices_privacy_warning_message),
        positiveAction: SmoothActionButton(
          text: appLocalizations.okay,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        negativeAction: justInfo
            ? null
            : SmoothActionButton(
                text: appLocalizations.cancel,
                onPressed: () => Navigator.of(context).pop(),
              ),
      ),
    );
  }

  /// Returns true if the basic checks passed.
  Future<bool> _check(final BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    String? error;
    try {
      error = _model.checkParameters(context);
    } catch (e) {
      error = e.toString();
    }
    if (error != null) {
      if (!context.mounted) {
        return false;
      }
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => SmoothSimpleErrorAlertDialog(
          title: AppLocalizations.of(context).prices_add_validation_error,
          message: error!,
        ),
      );
      return false;
    }
    return true;
  }

  @override
  String get actionName => 'Opened price_page with ${widget.proofType.offTag}';
}
