import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/dao_osm_location.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/prices/price_amount_card.dart';
import 'package:smooth_app/pages/prices/price_currency_card.dart';
import 'package:smooth_app/pages/prices/price_date_card.dart';
import 'package:smooth_app/pages/prices/price_location_card.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/prices/price_proof_card.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Single page that displays all the elements of price adding.
class ProductPriceAddPage extends StatefulWidget {
  const ProductPriceAddPage(
    this.product, {
    required this.latestOsmLocations,
  });

  final Product product;
  final List<OsmLocation> latestOsmLocations;

  static Future<void> showPage({
    required final BuildContext context,
    required final Product product,
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
          product,
          latestOsmLocations: osmLocations,
        ),
      ),
    );
  }

  @override
  State<ProductPriceAddPage> createState() => _ProductPriceAddPageState();
}

class _ProductPriceAddPageState extends State<ProductPriceAddPage> {
  late final PriceModel _model = PriceModel(
    proofType: ProofType.priceTag,
    locations: widget.latestOsmLocations,
    barcode: widget.product.barcode!,
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
              getProductNameAndBrands(widget.product, appLocalizations),
              maxLines: 1,
            ),
            subTitle: Text(widget.product.barcode!),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.info),
                onPressed: () async => _doesAcceptWarning(justInfo: true),
              ),
            ],
          ),
          body: const SingleChildScrollView(
            padding: EdgeInsets.all(LARGE_SPACE),
            child: Column(
              children: <Widget>[
                PriceProofCard(),
                SizedBox(height: LARGE_SPACE),
                PriceDateCard(),
                SizedBox(height: LARGE_SPACE),
                PriceLocationCard(),
                SizedBox(height: LARGE_SPACE),
                PriceCurrencyCard(),
                SizedBox(height: LARGE_SPACE),
                PriceAmountCard(),
                // so that the last items don't get hidden by the FAB
                SizedBox(height: MINIMUM_TOUCH_SIZE * 2),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) {
                return;
              }

              String? error;
              try {
                error = await _model.checkParameters(context);
              } catch (e) {
                error = e.toString();
              }
              if (error != null) {
                if (!context.mounted) {
                  return;
                }
                await showDialog<void>(
                  context: context,
                  builder: (BuildContext context) =>
                      SmoothSimpleErrorAlertDialog(
                    title: appLocalizations.prices_add_validation_error,
                    message: error!,
                  ),
                );
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
            label: Text(appLocalizations.prices_send_the_price),
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
}
