import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/prices/price_add_helper.dart';
import 'package:smooth_app/pages/prices/price_add_product_card.dart';
import 'package:smooth_app/pages/prices/price_amount_card.dart';
import 'package:smooth_app/pages/prices/price_currency_card.dart';
import 'package:smooth_app/pages/prices/price_date_card.dart';
import 'package:smooth_app/pages/prices/price_existing_amount_card.dart';
import 'package:smooth_app/pages/prices/price_location_card.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
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

/// Single page that displays all the elements of price adding.
class ProductPriceAddPage extends StatefulWidget {
  const ProductPriceAddPage(
    this.model,
  );

  final PriceModel model;

  static Future<void> showProductPage({
    required final BuildContext context,
    final PriceMetaProduct? product,
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

    final PriceAddHelper priceAddHelper = PriceAddHelper(context);
    final List<OsmLocation> osmLocations = await priceAddHelper.getLocations();
    if (!context.mounted) {
      return;
    }

    final Currency currency = priceAddHelper.getCurrency();

    final bool multipleProducts = product == null;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ProductPriceAddPage(
          PriceModel(
            proofType: proofType,
            locations: osmLocations,
            initialProduct: product,
            currency: currency,
            multipleProducts: multipleProducts,
          ),
        ),
      ),
    );
  }

  @override
  State<ProductPriceAddPage> createState() => _ProductPriceAddPageState();
}

class _ProductPriceAddPageState extends State<ProductPriceAddPage>
    with TraceableClientMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  late final WillPopScope2Controller _willPopScope2Controller;

  @override
  void initState() {
    super.initState();
    _willPopScope2Controller = WillPopScope2Controller(canPop: true);
  }

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
        return ChangeNotifierListener<PriceModel>(
          listener: (BuildContext context, PriceModel model) {
            _willPopScope2Controller.canPop(!model.hasChanged);
          },
          child: WillPopScope2(
            controller: _willPopScope2Controller,
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
                    appLocalizations.prices_add_n_prices(
                      model.length,
                    ),
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
                    ? context
                        .extension<SmoothColorsThemeExtension>()
                        .primaryLight
                    : null,
                body: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsetsDirectional.all(LARGE_SPACE),
                  child: Column(
                    children: <Widget>[
                      const PriceProofCard(),
                      const SizedBox(height: LARGE_SPACE),
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
                      if (model.existingPrices != null)
                        for (final Price price in model.existingPrices!)
                          PriceExistingAmountCard(price),
                      for (int i = 0; i < model.length; i++)
                        PriceAmountCard(
                          key: Key(model.elementAt(i).product.barcode),
                          index: i,
                        ),
                      const SizedBox(height: LARGE_SPACE),
                      if (model.multipleProducts) const PriceAddProductCard(),
                      // so that the last items don't get hidden by the FAB
                      const SizedBox(height: MINIMUM_TOUCH_SIZE * 2),
                    ],
                  ),
                ),
                floatingActionButton: SmoothExpandableFloatingActionButton(
                  scrollController: _scrollController,
                  onPressed: () async => _exitPage(
                    await _mayExitPage(
                      saving: true,
                      model: model,
                    ),
                  ),
                  icon: const Icon(Icons.send),
                  label: Text(
                    appLocalizations.prices_send_n_prices(
                      model.length,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.0,
                    ),
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
  String get actionName =>
      'Opened price_page with ${widget.model.proofType.offTag}';

  /// Exits the page if the [flag] is `true`.
  void _exitPage(final bool flag) {
    if (flag) {
      Navigator.of(context).pop();
    }
  }

  /// Returns `true` if we should really exit the page.
  ///
  /// Parameter [saving] tells about the context: are we leaving the page,
  /// or have we clicked on the "save" button?
  Future<bool> _mayExitPage({
    required final bool saving,
    required PriceModel model,
  }) async {
    if (!model.hasChanged) {
      return true;
    }

    if (!saving) {
      final bool? pleaseSave =
          await MayExitPageHelper().openSaveBeforeLeavingDialog(
        context,
        title: AppLocalizations.of(context).prices_add_n_prices(
          model.length,
        ),
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

    return true;
  }

  @override
  void dispose() {
    _willPopScope2Controller.dispose();
    super.dispose();
  }
}
