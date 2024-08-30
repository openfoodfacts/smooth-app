import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_add_price.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/onboarding/currency_selector_helper.dart';
import 'package:smooth_app/pages/prices/price_amount_model.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';

/// Price Model (checks and background task call) for price adding.
class PriceModel with ChangeNotifier {
  PriceModel({
    required final ProofType proofType,
    required final List<OsmLocation> locations,
    final PriceMetaProduct? initialProduct,
  })  : _proofType = proofType,
        _date = DateTime.now(),
        _locations = locations,
        priceAmountModels = <PriceAmountModel>[
          if (initialProduct != null) PriceAmountModel(product: initialProduct),
        ];

  final List<PriceAmountModel> priceAmountModels;

  CropParameters? _cropParameters;

  CropParameters? get cropParameters => _cropParameters;

  set cropParameters(final CropParameters? value) {
    _cropParameters = value;
    notifyListeners();
  }

  ProofType _proofType;

  ProofType get proofType => _proofType;

  set proofType(final ProofType proofType) {
    _proofType = proofType;
    notifyListeners();
  }

  DateTime _date;

  DateTime get date => _date;

  set date(final DateTime date) {
    _date = date;
    notifyListeners();
  }

  final DateTime today = DateTime.now();
  final DateTime firstDate = DateTime.utc(2020, 1, 1);

  late List<OsmLocation> _locations;

  List<OsmLocation> get locations => _locations;

  set locations(final List<OsmLocation> locations) {
    _locations = locations;
    notifyListeners();
  }

  OsmLocation? get location => _locations.firstOrNull;

  late Currency _checkedCurrency;

  // overriding in order to make it public
  @override
  void notifyListeners() => super.notifyListeners();

  /// Returns the error message of the parameter check, or null if OK.
  String? checkParameters(final BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if (cropParameters == null) {
      return appLocalizations.prices_proof_mandatory;
    }

    final UserPreferences userPreferences = context.read<UserPreferences>();
    _checkedCurrency =
        CurrencySelectorHelper().getSelected(userPreferences.userCurrencyCode);

    for (final PriceAmountModel priceAmountModel in priceAmountModels) {
      final String? checkParameters = priceAmountModel.checkParameters(context);
      if (checkParameters != null) {
        return checkParameters;
      }
    }

    if (location == null) {
      return appLocalizations.prices_location_mandatory;
    }

    return null;
  }

  /// Adds the related background task.
  Future<void> addTask(final BuildContext context) async {
    final List<String> barcodes = <String>[];
    final List<bool> pricesAreDiscounted = <bool>[];
    final List<double> prices = <double>[];
    final List<double?> pricesWithoutDiscount = <double?>[];
    for (final PriceAmountModel priceAmountModel in priceAmountModels) {
      barcodes.add(priceAmountModel.product.barcode);
      pricesAreDiscounted.add(priceAmountModel.promo);
      prices.add(priceAmountModel.checkedPaidPrice);
      pricesWithoutDiscount.add(priceAmountModel.checkedPriceWithoutDiscount);
    }
    return BackgroundTaskAddPrice.addTask(
      context: context,
      // per receipt
      cropObject: cropParameters!,
      locationOSMId: location!.osmId,
      locationOSMType: location!.osmType,
      date: date,
      proofType: proofType,
      currency: _checkedCurrency,
      // per item
      barcodes: barcodes,
      pricesAreDiscounted: pricesAreDiscounted,
      prices: prices,
      pricesWithoutDiscount: pricesWithoutDiscount,
    );
  }
}
