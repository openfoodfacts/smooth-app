import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http_parser/http_parser.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_barcode.dart';
import 'package:smooth_app/background/background_task_upload.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/database/local_database.dart';

// TODO(monsieurtanuki): use transient file, in order to have instant access to proof image?
// TODO(monsieurtanuki): add crop
// TODO(monsieurtanuki): check "is picture big enough?"
// TODO(monsieurtanuki): add source
// TODO(monsieurtanuki): make it work for several products
/// Background task about adding a product price.
class BackgroundTaskAddPrice extends BackgroundTaskBarcode {
  BackgroundTaskAddPrice._({
    required super.processName,
    required super.uniqueId,
    required super.barcode,
    required super.stamp,
    // single
    required this.fullPath,
    required this.proofType,
    required this.date,
    required this.currency,
    // multi
    required this.priceIsDiscounted,
    required this.price,
    required this.priceWithoutDiscount,
    required this.locationOSMId,
    required this.locationOSMType,
  });

  BackgroundTaskAddPrice.fromJson(Map<String, dynamic> json)
      : fullPath = json[_jsonTagImagePath] as String,
        proofType = getProofTypeFromOffTag(json[_jsonTagProofType] as String)!,
        date = JsonHelper.stringTimestampToDate(json[_jsonTagDate] as String),
        currency = getCurrencyFromName(json[_jsonTagCurrency] as String)!,
        priceIsDiscounted = json[_jsonTagIsDiscounted] as bool,
        price = json[_jsonTagPrice] as double,
        priceWithoutDiscount = json[_jsonTagPriceWithoutDiscount] as double?,
        locationOSMId = json[_jsonTagOSMId] as int,
        locationOSMType =
            LocationOSMType.fromOffTag(json[_jsonTagOSMType] as String)!,
        super.fromJson(json);

  static const String _jsonTagImagePath = 'imagePath';
  static const String _jsonTagProofType = 'proofType';
  static const String _jsonTagDate = 'date';
  static const String _jsonTagCurrency = 'currency';
  static const String _jsonTagIsDiscounted = 'isDiscounted';
  static const String _jsonTagPrice = 'price';
  static const String _jsonTagPriceWithoutDiscount = 'priceWithoutDiscount';
  static const String _jsonTagOSMId = 'osmId';
  static const String _jsonTagOSMType = 'osmType';

  static const OperationType _operationType = OperationType.addPrice;

  final String fullPath;
  final ProofType proofType;
  final DateTime date;
  final Currency currency;
  final bool priceIsDiscounted;
  final double price;
  final double? priceWithoutDiscount;
  final int locationOSMId;
  final LocationOSMType locationOSMType;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = super.toJson();
    result[_jsonTagImagePath] = fullPath;
    result[_jsonTagProofType] = proofType.offTag;
    result[_jsonTagDate] = date.toIso8601String();
    result[_jsonTagCurrency] = currency.name;
    result[_jsonTagIsDiscounted] = priceIsDiscounted;
    result[_jsonTagPrice] = price;
    result[_jsonTagPriceWithoutDiscount] = priceWithoutDiscount;
    result[_jsonTagOSMId] = locationOSMId;
    result[_jsonTagOSMType] = locationOSMType.offTag;
    return result;
  }

  /// Adds the background task about uploading a product image.
  static Future<void> addTask(
    final String barcode, {
    required final File fullFile,
    required final ProofType proofType,
    required final DateTime date,
    required final Currency currency,
    required final bool priceIsDiscounted,
    required final double price,
    required final double? priceWithoutDiscount,
    required final int locationOSMId,
    required final LocationOSMType locationOSMType,
    required final BuildContext context,
  }) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      barcode: barcode,
    );
    final BackgroundTaskBarcode task = _getNewTask(
      barcode,
      fullFile: fullFile,
      proofType: proofType,
      date: date,
      currency: currency,
      priceIsDiscounted: priceIsDiscounted,
      price: price,
      priceWithoutDiscount: priceWithoutDiscount,
      locationOSMId: locationOSMId,
      locationOSMType: locationOSMType,
      uniqueId: uniqueId,
    );
    if (!context.mounted) {
      return;
    }
    await task.addToManager(localDatabase, context: context);
  }

  @override
  (String, AlignmentGeometry)? getFloatingMessage(
          final AppLocalizations appLocalizations) =>
      (
        appLocalizations.add_price_queued,
        AlignmentDirectional.center,
      );

  /// Returns a new background task about changing a product.
  static BackgroundTaskAddPrice _getNewTask(
    final String barcode, {
    required final File fullFile,
    required final ProofType proofType,
    required final DateTime date,
    required final Currency currency,
    required final bool priceIsDiscounted,
    required final double price,
    required final double? priceWithoutDiscount,
    required final int locationOSMId,
    required final LocationOSMType locationOSMType,
    required final String uniqueId,
  }) =>
      BackgroundTaskAddPrice._(
        uniqueId: uniqueId,
        barcode: barcode,
        processName: _operationType.processName,
        fullPath: fullFile.path,
        proofType: proofType,
        date: date,
        currency: currency,
        priceIsDiscounted: priceIsDiscounted,
        price: price,
        priceWithoutDiscount: priceWithoutDiscount,
        locationOSMId: locationOSMId,
        locationOSMType: locationOSMType,
        stamp: _getStamp(
          barcode: barcode,
          date: date,
          locationOSMId: locationOSMId,
          locationOSMType: locationOSMType,
        ),
      );

  static String _getStamp({
    required final String barcode,
    required final DateTime date,
    required final int locationOSMId,
    required final LocationOSMType locationOSMType,
  }) =>
      '$barcode;price;$date;$locationOSMId;$locationOSMType';

  @override
  Future<void> postExecute(
    final LocalDatabase localDatabase,
    final bool success,
  ) async {
    await super.postExecute(localDatabase, success);
    try {
      (await BackgroundTaskUpload.getFile(fullPath)).deleteSync();
    } catch (e) {
      // not likely, but let's not spoil the task for that either.
    }
  }

  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async {}

  // Here we don't need the product refresh
  @override
  Future<void> execute(final LocalDatabase localDatabase) async => upload();

  /// Sends the product price to the server
  @override
  Future<void> upload() async {
    final Price newPrice = Price()
      ..date = date
      ..currency = currency
      ..priceIsDiscounted = priceIsDiscounted
      ..price = price
      ..priceWithoutDiscount = priceWithoutDiscount
      ..productCode = barcode
      ..locationOSMId = locationOSMId
      ..locationOSMType = locationOSMType;

    // authentication
    final User user = getUser();
    final MaybeError<String> token =
        await OpenPricesAPIClient.getAuthenticationToken(
      username: user.userId,
      password: user.password,
      uriHelper: uriProductHelper,
    );
    if (token.isError) {
      throw Exception('Could not get token: ${token.error}');
    }
    if (token.value.isEmpty) {
      throw Exception('Unexpected empty token');
    }
    final String bearerToken = token.value;

    // proof upload
    final File file = File(fullPath);
    final Uri initialImageUri = Uri.parse(file.path);
    final MediaType initialMediaType =
        HttpHelper().imagineMediaType(initialImageUri.path)!;
    final MaybeError<Proof> uploadProof = await OpenPricesAPIClient.uploadProof(
      proofType: proofType,
      imageUri: initialImageUri,
      mediaType: initialMediaType,
      bearerToken: bearerToken,
      uriHelper: uriProductHelper,
    );
    if (uploadProof.isError) {
      throw Exception('Could not upload proof: ${uploadProof.error}');
    }
    newPrice.proofId = uploadProof.value.id;

    // create price
    final MaybeError<Price> addedPrice = await OpenPricesAPIClient.createPrice(
      price: newPrice,
      bearerToken: bearerToken,
      uriHelper: uriProductHelper,
    );
    if (addedPrice.isError) {
      throw Exception('Could not add price: ${addedPrice.error}');
    }

    // close session
    final MaybeError<bool> closedSession =
        await OpenPricesAPIClient.deleteUserSession(
      uriHelper: uriProductHelper,
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

  // TODO(monsieurtanuki): move it to off-dart
  static Currency? getCurrencyFromName(final String name) {
    for (final Currency currency in Currency.values) {
      if (currency.name == name) {
        return currency;
      }
    }
    return null;
  }

  // TODO(monsieurtanuki): move it to off-dart
  static ProofType? getProofTypeFromOffTag(final String offTag) {
    for (final ProofType value in ProofType.values) {
      if (value.offTag == offTag) {
        return value;
      }
    }
    return null;
  }
}
