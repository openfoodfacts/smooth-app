import 'dart:async';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_add_other_price.dart';
import 'package:smooth_app/background/background_task_add_price.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/prices/price_amount_model.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';

/// Price Model (checks and background task call) for price adding.
class PriceModel with ChangeNotifier {
  PriceModel({
    required final ProofType proofType,
    required final List<OsmLocation>? locations,
    required final Currency currency,
    final PriceMetaProduct? initialProduct,
    required this.multipleProducts,
  }) : _proof = null,
       existingPrices = null,
       _proofType = proofType,
       _date = DateTime.now(),
       _currency = currency,
       _locations = locations,
       _priceAmountModels = <PriceAmountModel>[
         if (initialProduct != null) PriceAmountModel(product: initialProduct),
       ];

  PriceModel.proof({required Proof proof, this.existingPrices})
    : multipleProducts = true,
      _priceAmountModels = <PriceAmountModel>[] {
    setProof(proof, init: true);
  }

  bool _hasChanged = false;

  bool get hasChanged {
    if (_hasChanged) {
      return true;
    }
    for (final PriceAmountModel priceAmountModel in _priceAmountModels) {
      if (priceAmountModel.hasChanged) {
        return true;
      }
    }
    return false;
  }

  /// "Should we support multiple products?" (instead of a single product).
  final bool multipleProducts;

  void setProof(final Proof proof, {final bool init = false}) {
    if (!init) {
      _hasChanged = true;
    }
    _proof = proof;
    _cropParameters = null;
    _proofType = proof.type!;
    _date = proof.date!;
    _locations = null;
    _currency = proof.currency!;
    if (!init) {
      notifyListeners();
    }
  }

  // Clears the current proof. To be used in the context of bulk proof upload.
  void clearProof() {
    _proof = null;
    _cropParameters = null;
    // needed so that we can exit the page just going back
    _hasChanged = false;
    notifyListeners();
  }

  /// Checks if a proof cannot be reused for prices adding.
  ///
  /// Sometimes we get partial data from the Prices server.
  static bool isProofNotGoodEnough(final Proof proof) =>
      proof.currency == null ||
      proof.date == null ||
      proof.type == null ||
      proof.location == null ||
      proof.locationOSMId == null ||
      proof.locationOSMType == null ||
      proof.imageThumbPath == null ||
      proof.filePath == null;

  bool get hasImage => _proof != null || _cropParameters != null;

  final List<PriceAmountModel> _priceAmountModels;

  final List<Price>? existingPrices;

  void add(final PriceAmountModel priceAmountModel) {
    _hasChanged = true;
    _priceAmountModels.add(priceAmountModel);
    notifyListeners();
  }

  void removeAt(final int index) {
    _hasChanged = true;
    _priceAmountModels.removeAt(index);
    notifyListeners();
  }

  PriceAmountModel elementAt(final int index) => _priceAmountModels[index];

  int get length => _priceAmountModels.length;

  CropParameters? _cropParameters;

  CropParameters? get cropParameters => _cropParameters;

  set cropParameters(final CropParameters? value) {
    _hasChanged = true;
    _cropParameters = value;
    _proof = null;
    notifyListeners();
  }

  Proof? _proof;

  Proof? get proof => _proof;

  late ProofType _proofType;

  ProofType get proofType => _proof != null ? _proof!.type! : _proofType;

  set proofType(final ProofType proofType) {
    _hasChanged = true;
    _proofType = proofType;
    notifyListeners();
  }

  late DateTime _date;

  DateTime get date => _date;

  set date(final DateTime date) {
    _hasChanged = true;
    _date = date;
    notifyListeners();
  }

  final DateTime today = DateTime.now();
  final DateTime firstDate = DateTime.utc(2020, 1, 1);

  List<OsmLocation>? _locations;

  List<OsmLocation>? get locations => _locations;

  set locations(final List<OsmLocation>? locations) {
    _hasChanged = true;
    _locations = locations;
    notifyListeners();
  }

  OsmLocation? get location => proof?.location?.osmId != null
      ? OsmLocation.fromPrice(proof!.location!)
      : _locations!.firstOrNull;

  late Currency _currency;

  Currency get currency => _currency;

  set currency(final Currency currency) {
    _hasChanged = true;
    _currency = currency;
    notifyListeners();
  }

  // overriding in order to make it public
  @override
  void notifyListeners() => super.notifyListeners();

  /// Returns the error message of the parameter check, or null if OK.
  String? checkParameters(final BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if (proof == null) {
      if (cropParameters == null) {
        return appLocalizations.prices_proof_mandatory;
      }
      if (location == null) {
        return appLocalizations.prices_location_mandatory;
      }
    }

    for (final PriceAmountModel priceAmountModel in _priceAmountModels) {
      final String? checkParameters = priceAmountModel.checkParameters(context);
      if (checkParameters != null) {
        return checkParameters;
      }
    }

    final UserPreferences userPreferences = context.read<UserPreferences>();
    unawaited(userPreferences.setUserCurrencyCode(currency.name));

    return null;
  }

  /// Adds the related background task.
  Future<void> addTask(final BuildContext context) async {
    final List<String> barcodes = <String>[];
    final List<String> categories = <String>[];
    final List<List<String>> origins = <List<String>>[];
    final List<List<String>> labels = <List<String>>[];
    final List<String> pricePers = <String>[];
    final List<bool> pricesAreDiscounted = <bool>[];
    final List<double> prices = <double>[];
    final List<double?> pricesWithoutDiscount = <double?>[];
    for (final PriceAmountModel priceAmountModel in _priceAmountModels) {
      barcodes.add(priceAmountModel.product.barcode);
      categories.add(priceAmountModel.product.categoryTag);
      origins.add(priceAmountModel.product.originTags);
      // TODO(monsieurtanuki): to be implemented when supported by "prices"
      labels.add(<String>[]);
      pricePers.add(priceAmountModel.product.pricePer.offTag);
      pricesAreDiscounted.add(priceAmountModel.promo);
      prices.add(priceAmountModel.checkedPaidPrice);
      pricesWithoutDiscount.add(priceAmountModel.checkedPriceWithoutDiscount);
    }
    if (proof != null) {
      return BackgroundTaskAddOtherPrice.addTask(
        context: context,
        // per receipt
        locationOSMId: proof!.locationOSMId!,
        locationOSMType: proof!.locationOSMType!,
        date: proof!.date!,
        currency: proof!.currency!,
        proofId: proof!.id,
        // per item
        barcodes: barcodes,
        categories: categories,
        origins: origins,
        labels: labels,
        pricePers: pricePers,
        pricesAreDiscounted: pricesAreDiscounted,
        prices: prices,
        pricesWithoutDiscount: pricesWithoutDiscount,
      );
    }
    return BackgroundTaskAddPrice.addTask(
      context: context,
      // proof display
      cropObject: cropParameters!,
      // per receipt
      locationOSMId: location!.osmId,
      locationOSMType: location!.osmType,
      date: date,
      proofType: proofType,
      currency: currency,
      // per item
      barcodes: barcodes,
      categories: categories,
      origins: origins,
      labels: labels,
      pricePers: pricePers,
      pricesAreDiscounted: pricesAreDiscounted,
      prices: prices,
      pricesWithoutDiscount: pricesWithoutDiscount,
    );
  }
}
