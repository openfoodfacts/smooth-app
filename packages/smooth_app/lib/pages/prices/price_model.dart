import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_add_price.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/onboarding/currency_selector_helper.dart';

/// Price Model (checks and background task call) for price adding.
class PriceModel with ChangeNotifier {
  PriceModel({
    required final ProofType proofType,
    required final List<OsmLocation> locations,
    required this.barcode,
  })  : _proofType = proofType,
        _date = DateTime.now(),
        _locations = locations;

  final String barcode;

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

  bool _promo = false;

  bool get promo => _promo;

  set promo(final bool promo) {
    _promo = promo;
    notifyListeners();
  }

  String _paidPrice = '';
  String _priceWithoutDiscount = '';

  set paidPrice(final String value) => _paidPrice = value;
  set priceWithoutDiscount(final String value) => _priceWithoutDiscount = value;

  double? validateDouble(final String value) =>
      double.tryParse(value) ??
      double.tryParse(
        value.replaceAll(',', '.'),
      );

  Future<String?> addPrice(final BuildContext context) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if (cropParameters == null) {
      return appLocalizations.prices_proof_mandatory;
    }

    final UserPreferences userPreferences = context.read<UserPreferences>();
    final Currency currency =
        CurrencySelectorHelper().getSelected(userPreferences.userCurrencyCode);

    final double paidPrice = validateDouble(_paidPrice)!;
    double? priceWithoutDiscount;
    if (promo) {
      if (_priceWithoutDiscount.isNotEmpty) {
        priceWithoutDiscount = validateDouble(_priceWithoutDiscount);
        if (priceWithoutDiscount == null) {
          return appLocalizations.prices_amount_price_incorrect;
        }
      }
    }

    if (location == null) {
      return appLocalizations.prices_location_mandatory;
    }

    await BackgroundTaskAddPrice.addTask(
      cropObject: cropParameters!,
      locationOSMId: location!.osmId,
      locationOSMType: location!.osmType,
      date: date,
      proofType: proofType,
      currency: currency,
      barcode: barcode,
      priceIsDiscounted: promo,
      price: paidPrice,
      priceWithoutDiscount: priceWithoutDiscount,
      context: context,
    );
    return null;
  }
}
