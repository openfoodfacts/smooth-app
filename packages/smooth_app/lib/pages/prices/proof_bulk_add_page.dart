import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/prices/price_add_helper.dart';
import 'package:smooth_app/pages/prices/price_bulk_proof_card.dart';
import 'package:smooth_app/pages/prices/price_currency_card.dart';
import 'package:smooth_app/pages/prices/price_date_card.dart';
import 'package:smooth_app/pages/prices/price_location_card.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Single page that displays all the elements of bulk proof adding.
class ProofBulkAddPage extends StatefulWidget {
  const ProofBulkAddPage(
    this.model,
  );

  final PriceModel model;

  static Future<PriceModel?> _getPriceModel({
    required final BuildContext context,
  }) async {
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: true,
    )) {
      return null;
    }
    if (!context.mounted) {
      return null;
    }

    final PriceAddHelper priceAddHelper = PriceAddHelper(context);
    final List<OsmLocation> osmLocations = await priceAddHelper.getLocations();
    if (!context.mounted) {
      return null;
    }

    final Currency currency = priceAddHelper.getCurrency();

    return PriceModel(
      proofType: ProofType.priceTag,
      locations: osmLocations,
      currency: currency,
      multipleProducts: true,
    );
  }

  static Future<void> showPage({
    required final BuildContext context,
  }) async {
    final PriceModel? priceModel = await _getPriceModel(context: context);
    if (priceModel == null) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ProofBulkAddPage(priceModel),
      ),
    );
  }

  @override
  State<ProofBulkAddPage> createState() => _ProofBulkAddPageState();
}

class _ProofBulkAddPageState extends State<ProofBulkAddPage>
    with TraceableClientMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PriceModel>.value(
      value: widget.model,
      builder: (
        final BuildContext context,
        final Widget? child,
      ) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);
        final PriceModel model = Provider.of<PriceModel>(context);
        return Form(
          key: _formKey,
          child: SmoothScaffold(
            appBar: SmoothAppBar(
              centerTitle: false,
              leading: const SmoothBackButton(),
              title: Text(
                appLocalizations.prices_bulk_proof_upload_title,
              ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.info),
                  onPressed: () async =>
                      PriceAddHelper(context).doesAcceptWarning(justInfo: true),
                ),
              ],
            ),
            backgroundColor: context.lightTheme()
                ? context.extension<SmoothColorsThemeExtension>().primaryLight
                : null,
            body: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(LARGE_SPACE),
              child: Column(
                children: <Widget>[
                  const PriceDateCard(),
                  const SizedBox(height: LARGE_SPACE),
                  PriceLocationCard(
                    onLocationChanged: (
                      OsmLocation? oldLocation,
                      OsmLocation location,
                    ) =>
                        PriceAddHelper(context).updateCurrency(
                      oldLocation,
                      location,
                      model,
                    ),
                  ),
                  const SizedBox(height: LARGE_SPACE),
                  const PriceCurrencyCard(),
                  const SizedBox(height: LARGE_SPACE),
                  PriceBulkProofCard(_formKey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  String get actionName => 'Opened bulk proof upload page';
}
