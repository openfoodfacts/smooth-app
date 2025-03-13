import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/prices/price_add_helper.dart';
import 'package:smooth_app/pages/prices/price_currency_card.dart';
import 'package:smooth_app/pages/prices/price_date_card.dart';
import 'package:smooth_app/pages/prices/price_location_card.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/prices/price_proof_card.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_expandable_floating_action_button.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/will_pop_scope.dart';

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
        return WillPopScope2(
          onWillPop: () async => (
            await _mayExitPage(
              saving: false,
              model: model,
            ),
            null
          ),
          child: Form(
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
                    onPressed: () async => PriceAddHelper(context)
                        .doesAcceptWarning(justInfo: true),
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
                    const PriceProofCard(
                      forcedProofType: ProofType.priceTag,
                      includeMyProofs: false,
                    ),
                    // so that the last items don't get hidden by the FAB
                    const SizedBox(height: MINIMUM_TOUCH_SIZE * 2),
                  ],
                ),
              ),
              floatingActionButton: SmoothExpandableFloatingActionButton(
                scrollController: _scrollController,
                onPressed: () async => _mayExitPage(
                  saving: true,
                  model: model,
                ),
                icon: const Icon(Icons.send),
                label: Text(
                  appLocalizations.prices_bulk_proof_upload_action,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  String get actionName => 'Opened bulk proof upload page';

  /// Returns `true` if we should really exit the page.
  ///
  /// Parameter [saving] tells about the context: are we leaving the page,
  /// or have we clicked on the "save" button?
  Future<bool> _mayExitPage({
    required final bool saving,
    required PriceModel model,
  }) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if (!model.hasChanged && !saving) {
      return true;
    }

    if (!saving) {
      final bool? pleaseSave =
          await MayExitPageHelper().openSaveBeforeLeavingDialog(
        context,
        title: appLocalizations.prices_bulk_proof_upload_title,
      );
      if (pleaseSave == null) {
        return false;
      }
      if (pleaseSave == false) {
        return true;
      }
      if (!mounted) {
        return false;
      }
    }

    final PriceAddHelper priceAddHelper = PriceAddHelper(context);
    if (!await priceAddHelper.check(model, _formKey)) {
      return false;
    }
    if (!mounted) {
      return false;
    }

    if (!await priceAddHelper.acceptsWarning()) {
      return false;
    }
    if (!mounted) {
      return true;
    }

    await model.addTask(context);

    if (saving) {
      model.clearProof();
    }

    return true;
  }
}
