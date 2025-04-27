import 'dart:async';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/background/background_task_price.dart';
import 'package:smooth_app/background/background_task_queue.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/database/local_database.dart';

/// Background task about adding prices to an existing proof.
class BackgroundTaskAddOtherPrice extends BackgroundTaskPrice {
  BackgroundTaskAddOtherPrice._({
    required super.processName,
    required super.uniqueId,
    required super.stamp,
    // single
    required this.proofId,
    required super.date,
    required super.currency,
    required super.locationOSMId,
    required super.locationOSMType,
    // multi
    required super.barcodes,
    required super.categories,
    required super.origins,
    required super.labels,
    required super.pricePers,
    required super.pricesAreDiscounted,
    required super.prices,
    required super.pricesWithoutDiscount,
  });

  BackgroundTaskAddOtherPrice.fromJson(super.json)
      : proofId = json[_jsonTagProofId] as int,
        super.fromJson();

  static const String _jsonTagProofId = 'proofId';

  static const OperationType _operationType = OperationType.addOtherPrice;

  final int proofId;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = super.toJson();
    result[_jsonTagProofId] = proofId;
    return result;
  }

  /// Adds the background task about uploading a product image.
  static Future<void> addTask({
    required final BuildContext context,
    required final int proofId,
    required final DateTime date,
    required final Currency currency,
    required final int locationOSMId,
    required final LocationOSMType locationOSMType,
    required final List<String> barcodes,
    required final List<String> categories,
    required final List<List<String>> origins,
    required final List<List<String>> labels,
    required final List<String> pricePers,
    required final List<bool> pricesAreDiscounted,
    required final List<double> prices,
    required final List<double?> pricesWithoutDiscount,
  }) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final String uniqueId = await _operationType.getNewKey(localDatabase);
    final BackgroundTask task = _getNewTask(
      uniqueId: uniqueId,
      proofId: proofId,
      date: date,
      currency: currency,
      locationOSMId: locationOSMId,
      locationOSMType: locationOSMType,
      barcodes: barcodes,
      categories: categories,
      origins: origins,
      labels: labels,
      pricePers: pricePers,
      pricesAreDiscounted: pricesAreDiscounted,
      prices: prices,
      pricesWithoutDiscount: pricesWithoutDiscount,
    );
    if (!context.mounted) {
      return;
    }
    await task.addToManager(
      localDatabase,
      context: context,
      queue: BackgroundTaskQueue.fast,
    );
  }

  /// Returns a new background task about changing a product.
  static BackgroundTaskAddOtherPrice _getNewTask({
    required final String uniqueId,
    required final int proofId,
    required final DateTime date,
    required final Currency currency,
    required final int locationOSMId,
    required final LocationOSMType locationOSMType,
    required final List<String> barcodes,
    required final List<String> categories,
    required final List<List<String>> origins,
    required final List<List<String>> labels,
    required final List<String> pricePers,
    required final List<bool> pricesAreDiscounted,
    required final List<double> prices,
    required final List<double?> pricesWithoutDiscount,
  }) =>
      BackgroundTaskAddOtherPrice._(
        uniqueId: uniqueId,
        processName: _operationType.processName,
        proofId: proofId,
        date: date,
        currency: currency,
        locationOSMId: locationOSMId,
        locationOSMType: locationOSMType,
        barcodes: barcodes,
        categories: categories,
        origins: origins,
        labels: labels,
        pricePers: pricePers,
        pricesAreDiscounted: pricesAreDiscounted,
        prices: prices,
        pricesWithoutDiscount: pricesWithoutDiscount,
        stamp: BackgroundTaskPrice.getStamp(
          date: date,
          locationOSMId: locationOSMId,
          locationOSMType: locationOSMType,
        ),
      );

  @override
  Future<void> execute(final LocalDatabase localDatabase) async {
    final String bearerToken = await getBearerToken();

    await addPrices(
      bearerToken: bearerToken,
      proofId: proofId,
      localDatabase: localDatabase,
    );

    await closeSession(bearerToken: bearerToken);
  }
}
