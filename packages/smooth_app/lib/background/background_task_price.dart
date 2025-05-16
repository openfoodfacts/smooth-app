import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/prices/product_price_refresher.dart';
import 'package:smooth_app/query/product_query.dart';

/// Abstract background task about adding prices.
abstract class BackgroundTaskPrice extends BackgroundTask {
  BackgroundTaskPrice({
    required super.processName,
    required super.uniqueId,
    required super.stamp,
    // single
    required this.date,
    required this.currency,
    required this.locationOSMId,
    required this.locationOSMType,
    // multi
    required this.barcodes,
    required this.pricesAreDiscounted,
    required this.prices,
    required this.pricesWithoutDiscount,
  });

  BackgroundTaskPrice.fromJson(super.json)
      : date = JsonHelper.stringTimestampToDate(json[_jsonTagDate] as String),
        currency = Currency.fromName(json[_jsonTagCurrency] as String)!,
        locationOSMId = json[_jsonTagOSMId] as int,
        locationOSMType =
            LocationOSMType.fromOffTag(json[_jsonTagOSMType] as String)!,
        barcodes = json.containsKey(_jsonTagBarcode)
            ? <String>[json[_jsonTagBarcode] as String]
            : _fromJsonListString(json[_jsonTagBarcodes])!,
        pricesAreDiscounted = json.containsKey(_jsonTagIsDiscounted)
            ? <bool>[json[_jsonTagIsDiscounted] as bool]
            : _fromJsonListBool(json[_jsonTagAreDiscounted])!,
        prices = json.containsKey(_jsonTagPrice)
            ? <double>[json[_jsonTagPrice] as double]
            : fromJsonListDouble(json[_jsonTagPrices])!,
        pricesWithoutDiscount = json.containsKey(_jsonTagPriceWithoutDiscount)
            ? <double?>[json[_jsonTagPriceWithoutDiscount] as double?]
            : _fromJsonListNullableDouble(json[_jsonTagPricesWithoutDiscount])!,
        super.fromJson();

  static const String _jsonTagDate = 'date';
  static const String _jsonTagCurrency = 'currency';
  static const String _jsonTagOSMId = 'osmId';
  static const String _jsonTagOSMType = 'osmType';
  static const String _jsonTagBarcodes = 'barcodes';
  static const String _jsonTagAreDiscounted = 'areDiscounted';
  static const String _jsonTagPrices = 'prices';
  static const String _jsonTagPricesWithoutDiscount = 'pricesWithoutDiscount';
  @Deprecated('Use [_jsonTagBarcodes] instead')
  static const String _jsonTagBarcode = 'barcode';
  @Deprecated('Use [_jsonTagAreDiscounted] instead')
  static const String _jsonTagIsDiscounted = 'isDiscounted';
  @Deprecated('Use [_jsonTagPrices] instead')
  static const String _jsonTagPrice = 'price';
  @Deprecated('Use [_jsonTagPricesWithoutDiscount] instead')
  static const String _jsonTagPriceWithoutDiscount = 'priceWithoutDiscount';

  static List<double>? fromJsonListDouble(final List<dynamic>? input) {
    if (input == null) {
      return null;
    }
    final List<double> result = <double>[];
    for (final dynamic item in input) {
      result.add(item as double);
    }
    return result;
  }

  static List<double?>? _fromJsonListNullableDouble(
    final List<dynamic>? input,
  ) {
    if (input == null) {
      return null;
    }
    final List<double?> result = <double?>[];
    for (final dynamic item in input) {
      result.add(item as double?);
    }
    return result;
  }

  static List<String>? _fromJsonListString(final List<dynamic>? input) {
    if (input == null) {
      return null;
    }
    final List<String> result = <String>[];
    for (final dynamic item in input) {
      result.add(item as String);
    }
    return result;
  }

  static List<bool>? _fromJsonListBool(final List<dynamic>? input) {
    if (input == null) {
      return null;
    }
    final List<bool> result = <bool>[];
    for (final dynamic item in input) {
      result.add(item as bool);
    }
    return result;
  }

  final DateTime date;
  final Currency currency;
  final int locationOSMId;
  final LocationOSMType locationOSMType;

  // per line
  final List<String> barcodes;
  final List<bool> pricesAreDiscounted;
  final List<double> prices;
  final List<double?> pricesWithoutDiscount;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = super.toJson();
    result[_jsonTagDate] = date.toIso8601String();
    result[_jsonTagCurrency] = currency.name;
    result[_jsonTagOSMId] = locationOSMId;
    result[_jsonTagOSMType] = locationOSMType.offTag;
    result[_jsonTagBarcodes] = barcodes;
    result[_jsonTagAreDiscounted] = pricesAreDiscounted;
    result[_jsonTagPrices] = prices;
    result[_jsonTagPricesWithoutDiscount] = pricesWithoutDiscount;
    return result;
  }

  @override
  (String, AlignmentGeometry)? getFloatingMessage(
          final AppLocalizations appLocalizations) =>
      (
        appLocalizations.add_price_queued,
        AlignmentDirectional.bottomCenter,
      );

  @protected
  static String getStamp({
    required final DateTime date,
    required final int locationOSMId,
    required final LocationOSMType locationOSMType,
  }) =>
      'no_barcode;price;$date;$locationOSMId;$locationOSMType';

  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async {}

  @protected
  Future<String> getBearerToken() async {
    final User user = getUser();
    final MaybeError<String> token =
        await OpenPricesAPIClient.getAuthenticationToken(
      username: user.userId,
      password: user.password,
      uriHelper: ProductQuery.uriPricesHelper,
    );
    if (token.isError) {
      throw Exception('Could not get token: ${token.error}');
    }
    if (token.value.isEmpty) {
      throw Exception('Unexpected empty token');
    }
    return token.value;
  }

  @protected
  Future<void> addPrices({
    required final String bearerToken,
    required final int proofId,
    required final LocalDatabase localDatabase,
  }) async {
    for (int i = 0; i < barcodes.length; i++) {
      final String barcode = barcodes[i];
      final Price newPrice = Price()
        ..date = date
        ..currency = currency
        ..locationOSMId = locationOSMId
        ..locationOSMType = locationOSMType
        ..proofId = proofId
        ..priceIsDiscounted = pricesAreDiscounted[i]
        ..price = prices[i]
        ..priceWithoutDiscount = pricesWithoutDiscount[i]
        ..productCode = barcode;

      // create price
      final MaybeError<Price?> addedPrice =
          await OpenPricesAPIClient.createPrice(
        price: newPrice,
        bearerToken: bearerToken,
        uriHelper: ProductQuery.uriPricesHelper,
      );
      if (addedPrice.isError) {
        throw Exception('Could not add price: ${addedPrice.error}');
      }
      ProductPriceRefresher.setLatestUpdate(barcode);
    }
    localDatabase.notifyListeners();
  }

  @protected
  Future<void> closeSession({
    required final String bearerToken,
  }) async {
    final MaybeError<bool> closedSession =
        await OpenPricesAPIClient.deleteUserSession(
      uriHelper: ProductQuery.uriPricesHelper,
      bearerToken: bearerToken,
    );
    if (closedSession.isError) {
      // TODO(monsieurtanuki): do we really care?
      // throw Exception('Could not close session: ${closedSession.error}');
      return;
    }
    if (!closedSession.value) {
      // TODO(monsieurtanuki): do we really care?
      // throw Exception('Could not really close session');
      return;
    }
  }

  @override
  bool isDeduplicable() => false;
}
